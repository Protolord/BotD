scope Pitfall
 
    globals
        private constant integer SPELL_ID = 'A512'
        private constant integer SPELL_BUFF = 'D512'
        private constant integer PITFALL_ID = 'B512'
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
        private constant string SFX_BUFF = "Abilities\\Spells\\Human\\FlameStrike\\FlameStrikeDamageTarget.mdl"
        private constant real TIMEOUT = 1.0
    endglobals
    
    private function AttackSlow takes integer level returns real
        return 0.0*level + 0.50
    endfunction
    
    private function MoveSlow takes integer level returns real
        return 0.0*level + 0.50
    endfunction
    
    private function DamagePerSecond takes integer level returns real
        return 30.0*level
    endfunction
    
    private function Duration takes integer level returns real
        return 0.0*level + 10.0
    endfunction
    
    private function Radius takes integer level returns real
        return 0.0*level + 300.0
    endfunction
    
    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction
    
    private struct SpellBuff extends Buff
        
        readonly Movespeed ms
        readonly Atkspeed as
        private effect sfx
        private timer t
        public real dmg
        
        method rawcode takes nothing returns integer
            return SPELL_BUFF
        endmethod
        
        method dispelType takes nothing returns integer
            return BUFF_NONE
        endmethod
        
        method stackType takes nothing returns integer
            return BUFF_STACK_FULL
        endmethod
        
        method onRemove takes nothing returns nothing
            call this.ms.destroy()
            call this.as.destroy()
            call DestroyEffect(this.sfx)
            call ReleaseTimer(this.t)
            set this.sfx = null
            set this.t = null
        endmethod
        
        private static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            if TargetFilter(this.target, GetOwningPlayer(this.source)) then
                call Damage.element.apply(this.source, this.target, this.dmg, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_FIRE)
            else
                call this.remove()
            endif
        endmethod
        
        method onApply takes nothing returns nothing
            set this.ms = Movespeed.create(this.target, 0, 0)
            set this.as = Atkspeed.create(this.target, 0)
            set this.sfx = AddSpecialEffectTarget(SFX_BUFF, this.target, "chest")
            set this.t = NewTimerEx(this)
            call TimerStart(this.t, TIMEOUT, true, function thistype.onPeriod)
        endmethod
        
        implement BuffApply
    endstruct

    struct Pitfall extends array
        
        private unit caster
        private destructable pit
        private real x
        private real y
        private real dmg
        private group g
        private real duration
        private real radius
        private real moveSlow
        private real atkSlow
        private Table tb
        
        private static group enumG
        
        private method remove takes nothing returns nothing
            local unit u
            loop
                set u = FirstOfGroup(this.g)
                exitwhen u == null
                call GroupRemoveUnit(this.g, u)
                call Buff(this.tb[GetHandleId(u)]).remove()
            endloop
            call KillDestructable(this.pit)
            call this.tb.destroy()
            call ReleaseGroup(this.g)
            set this.pit = null
            set this.g = null
            set this.caster = null
            call this.destroy()
        endmethod
        
        private static method picked takes nothing returns nothing
            local unit u = GetEnumUnit()
            local SpellBuff b
            local integer id
            if not TargetFilter(u, GetOwningPlayer(global.caster)) or not IsUnitInRangeXY(u, global.x, global.y, global.radius) then
                call GroupRemoveUnit(global.g, u)
                set id = GetHandleId(u)
                if Buff.has(global.caster, u, SpellBuff.typeid) then
                    call Buff(global.tb[id]).remove()
                endif
            endif
            set u = null
        endmethod
        
        private static thistype global
        
        implement CTL
            local unit u
            local SpellBuff b
            local player owner
        implement CTLExpire
            set this.duration = this.duration - CTL_TIMEOUT
            if this.duration > 0 then
                call GroupUnitsInArea(thistype.enumG, this.x, this.y, this.radius)
                set thistype.global = this
                set owner = GetOwningPlayer(this.caster)
                loop
                    set u = FirstOfGroup(thistype.enumG)
                    exitwhen u == null
                    call GroupRemoveUnit(thistype.enumG, u)
                    if TargetFilter(u, owner) and not IsUnitInGroup(u, this.g) then
                        set b = SpellBuff.add(this.caster, u)
                        set b.dmg = this.dmg
                        call b.ms.change(this.moveSlow, 0)
                        call b.as.change(this.atkSlow)
                        set this.tb[GetHandleId(u)] = b
                        call GroupAddUnit(this.g, u)
                    endif
                endloop
                call ForGroup(this.g, function thistype.picked)
            else
                call this.remove()
            endif
        implement CTLNull
            set owner = null
        implement CTLEnd
        
        
        private static method onCast takes nothing returns nothing
            local thistype this = thistype.create()
            local integer lvl
            set this.caster = GetTriggerUnit()
            set this.g = NewGroup()
            set lvl = GetUnitAbilityLevel(this.caster, SPELL_ID)
            set this.x = GetUnitX(this.caster)
            set this.y = GetUnitY(this.caster)
            set this.duration = Duration(lvl)
            set this.radius = Radius(lvl)
            set this.atkSlow = -AttackSlow(lvl)
            set this.moveSlow = -MoveSlow(lvl)
            set this.dmg = DamagePerSecond(lvl)*TIMEOUT
            set this.tb = Table.create()
            set this.pit = CreateDestructable(PITFALL_ID, this.x, this.y, GetRandomReal(0, 360), this.radius/80, 0)
            call SetDestructableAnimation(this.pit, "birth")
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            set thistype.enumG = CreateGroup()
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope