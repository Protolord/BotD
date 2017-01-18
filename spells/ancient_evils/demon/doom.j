scope Doom
 
    globals
        private constant integer SPELL_ID = 'A511'
        private constant integer BUFF_ID = 'a511'
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
        private constant real TIMEOUT = 1.0
    endglobals
    
    private function DamagePerSecond takes integer level returns real
        return 0.0*level + 50.0
    endfunction
    
    private function Duration takes integer level returns real
        return 1.0*level
    endfunction
    
    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction
    
    struct Doom extends array
        implement Alloc
        
        private unit caster
        private unit target
        private real dmg
        private real time
        private real duration
        private timer t
        
        private method destroy takes nothing returns nothing
            call UnitRemoveAbility(this.target, BUFF_ID)
            call ReleaseTimer(this.t)
            set this.t = null
            set this.caster = null
            set this.target = null
            call this.deallocate()
        endmethod
        
        private static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            set this.time = this.time - TIMEOUT
            if this.time >= 0 then
                if TargetFilter(this.target, GetOwningPlayer(this.caster)) then
                    call Damage.element.apply(this.caster, this.target, this.dmg, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_FIRE)
                endif
            else
                call this.destroy()
            endif
        endmethod
        
        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            local integer lvl
            set this.caster = GetTriggerUnit()
            set this.target = GetSpellTargetUnit()
            set lvl = GetUnitAbilityLevel(this.caster, SPELL_ID)
            set this.dmg = DamagePerSecond(lvl)*TIMEOUT
            set this.time = Duration(lvl)
            set this.duration = this.time
            set this.t = NewTimerEx(this)
            call TimerStart(this.t, TIMEOUT, true, function thistype.onPeriod)
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope