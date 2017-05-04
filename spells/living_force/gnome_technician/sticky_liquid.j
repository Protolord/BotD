scope StickyLiquid
 
    globals
        private constant integer SPELL_ID = 'AH63'
        private constant string SFX = "Models\\Effects\\WebSpin.mdx"
        private constant string SFX_BUFF = ""
    endglobals
    
    private function Radius takes integer level returns real
        return 0.0*level + 350.0
    endfunction
    
    private function Slow takes integer level returns real
        return 0.0*level + 0.9
    endfunction
    
    private function Duration takes integer level returns real
        return 2.0*level + 10.0
    endfunction
    
    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction
    
    private struct SpellBuff extends Buff
    
        private effect sfx
        readonly Movespeed ms

        private static constant integer RAWCODE = 'DH63'
        private static constant integer DISPEL_TYPE = BUFF_NONE
        private static constant integer STACK_TYPE = BUFF_STACK_FULL
        
        method onRemove takes nothing returns nothing
            call DestroyEffect(this.sfx)
            call this.ms.destroy()
            set this.sfx = null
        endmethod
        
        method onApply takes nothing returns nothing
            set this.sfx = AddSpecialEffectTarget(SFX_BUFF, this.target, "chest")
            set this.ms = Movespeed.create(this.target, 0, 0)
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod
        
        implement BuffApply
    endstruct
    
    struct StickyLiquid extends array
        
        private unit caster
        private player owner
        private Effect e
        private group g
        private real radius
        private real duration
        private real x
        private real y
        private real slow
        private SpellBuff b
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
            call this.tb.destroy()
            call ReleaseGroup(this.g)
            call this.e.destroy()
            set this.g = null
            set this.caster = null
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
            set this.e = Effect.createAnyAngle(SFX, this.x, this.y, 0)
            set this.tb = Table.create()
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            set thistype.enumG = CreateGroup()
            call SpellBuff.initialize()
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope