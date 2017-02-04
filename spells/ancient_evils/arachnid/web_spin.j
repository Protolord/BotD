scope WebSpin
 
    globals
        private constant integer SPELL_ID = 'A432'
        private constant integer SPELL_BUFF = 'B432'
        private constant integer SPELL_DEBUFF = 'D432'
        private constant string WEB_MODEL = "Models\\Effects\\WebSpin.mdx"
        private constant string BUFF_SFX = "Models\\Effects\\StickyShellBuff.mdx"
        private constant string BONUS_SFX = "Models\\Effects\\Haste.mdx"
    endglobals
    
    private function Radius takes integer level returns real
        return 0.0*level + 350.0
    endfunction
    
    private function SightRadius takes integer level returns real
        if level == 11 then
            return GLOBAL_SIGHT
        endif
        return 350.0
    endfunction
    
    private function Slow takes integer level returns real
        return 0.0*level + 0.9
    endfunction
    
    private function Duration takes integer level returns real
        if level == 11 then
            return 60.0
        endif
        return 2.0*level + 10.0
    endfunction
    
    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction
    
    private struct Bonus extends Buff
        
        private effect sfx
        readonly Movespeed ms
            
        method rawcode takes nothing returns integer
            return SPELL_BUFF
        endmethod
        
        method dispelType takes nothing returns integer
            return BUFF_POSITIVE
        endmethod
        
        method stackType takes nothing returns integer
            return BUFF_STACK_FULL //Do not change
        endmethod
        
        method onRemove takes nothing returns nothing
            call this.ms.destroy()
            call DestroyEffect(this.sfx)
            set this.sfx = null
        endmethod
        
        method onApply takes nothing returns nothing
            set this.ms = Movespeed.create(this.target, 999.9, 999)
            set this.sfx = AddSpecialEffectTarget(BONUS_SFX, this.target, "chest")
        endmethod
        
        implement BuffApply
    endstruct
    
    private struct SpellBuff extends Buff
    
        private effect sfx
        readonly Movespeed ms
            
        method rawcode takes nothing returns integer
            return SPELL_DEBUFF
        endmethod
        
        method dispelType takes nothing returns integer
            return BUFF_NONE
        endmethod
        
        method stackType takes nothing returns integer
            return BUFF_STACK_FULL  //Do not change
        endmethod
        
        method onRemove takes nothing returns nothing
            call DestroyEffect(this.sfx)
            call this.ms.destroy()
            set this.sfx = null
        endmethod
        
        method onApply takes nothing returns nothing
            set this.sfx = AddSpecialEffectTarget(BUFF_SFX, this.target, "chest")
            set this.ms = Movespeed.create(this.target, 0, 0)
        endmethod
        
        implement BuffApply
    endstruct
    
    struct WebSpin extends array
        
        private unit caster
        private unit dummy
        private player owner
        private effect sfx
        private group g
        private real radius
        private real duration
        private real x
        private real y
        private real slow
        private fogmodifier fm
        private Bonus bonus
        private TrueSight ts
        private Table tb
        
        private static thistype global
        private static group enumG
        
        private method remove takes nothing returns nothing
            local unit u
            loop
                set u = FirstOfGroup(this.g)
                exitwhen u == null
                call GroupRemoveUnit(this.g, u)
                call Buff(this.tb[GetHandleId(u)]).remove()
            endloop
            if this.bonus > 0 then
                call this.bonus.remove()
                set this.bonus = 0
            endif
            call this.tb.destroy()
            call this.ts.destroy()
            call DestroyFogModifier(this.fm)
            call ReleaseGroup(this.g)
            call DummyAddRecycleTimer(this.dummy, 3.0)
            call SetUnitVertexColor(this.dummy, 255, 255, 255, 75)
            call DestroyEffect(this.sfx)
            set this.fm = null
            set this.g = null
            set this.caster = null
            set this.dummy = null
            set this.sfx = null
            call this.destroy()
        endmethod
        
        private static method picked takes nothing returns nothing
            local unit u = GetEnumUnit()
            local SpellBuff b
            local integer id
            if not TargetFilter(u, global.owner) or not IsUnitInRangeXY(u, global.x, global.y, global.radius) then
                call GroupRemoveUnit(global.g, u)
                set id = GetHandleId(u)
                if Buff.has(global.caster, u, SpellBuff.typeid) then
                    call Buff(global.tb[id]).remove()
                endif
            endif
            set u = null
        endmethod
        
        implement CTL
            local unit u
            local SpellBuff b
        implement CTLExpire
            set this.duration = this.duration - CTL_TIMEOUT
            if this.duration > 0 then
                call GroupUnitsInArea(thistype.enumG, this.x, this.y, this.radius)
                set thistype.global = this
                loop
                    set u = FirstOfGroup(thistype.enumG)
                    exitwhen u == null
                    call GroupRemoveUnit(thistype.enumG, u)
                    if TargetFilter(u, this.owner) and not IsUnitInGroup(u, this.g) then
                        set b = SpellBuff.add(this.caster, u)
                        call b.ms.change(this.slow, 0)
                        set this.tb[GetHandleId(u)] = b
                        call GroupAddUnit(this.g, u)
                    endif
                endloop
                call ForGroup(this.g, function thistype.picked)
                if this.bonus == 0 then
                    if FirstOfGroup(this.g) != null then
                        set this.bonus = Bonus.add(this.caster, this.caster)
                    endif
                else    
                    if FirstOfGroup(this.g) == null then
                        call this.bonus.remove()
                        set this.bonus = 0
                    endif
                endif
            else
                call this.remove()
            endif
        implement CTLEnd
        
        private static method onCast takes nothing returns nothing
            local thistype this = thistype.create()
            local integer lvl
            set this.caster = GetTriggerUnit()
            set this.g = NewGroup()
            set this.owner = GetTriggerPlayer()
            set lvl = GetUnitAbilityLevel(this.caster, SPELL_ID)
            set this.x = GetUnitX(this.caster)
            set this.y = GetUnitY(this.caster)
            set this.radius = Radius(lvl)
            set this.duration = Duration(lvl)
            set this.slow = -Slow(lvl)
            set this.dummy = GetRecycledDummyAnyAngle(this.x, this.y, 0)
            set this.sfx = AddSpecialEffectTarget(WEB_MODEL, this.dummy, "origin")
            set this.tb = Table.create()
            set this.fm = CreateFogModifierRadius(this.owner, FOG_OF_WAR_VISIBLE, this.x, this.y, RMaxBJ(SightRadius(lvl), 385), true, false)
            set this.ts = TrueSight.create(this.dummy, SightRadius(lvl))
            call FogModifierStart(this.fm)
            call SetUnitScale(this.dummy, this.radius/100.0 + 0.2, 0, 0) 
            call SetUnitVertexColor(this.dummy, 255, 255, 255, 125)
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            set thistype.enumG = CreateGroup()
            call PreloadSpell(SPELL_BUFF)
            call PreloadSpell(SPELL_DEBUFF)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope