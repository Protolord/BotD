scope Revitalize
    
    globals
        private constant integer SPELL_ID = 'A244'
        private constant string HEAL_ATTACHED = "Models\\Effects\\Revitalize.mdx"
    endglobals
    
    private function HealBase takes integer level returns real
        if level == 11 then
            return 66.0
        endif
        return 3.0 + 3.0*level
    endfunction

    struct Revitalize extends array
        implement Alloc
        
        private unit u
        
        private static method debuff takes nothing returns nothing
            local thistype this = ReleaseTimer(GetExpiredTimer())
            call UnitRemoveAbility(this.u, 'Bbsk')
            set this.u = null
        endmethod
        
        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            set this.u = GetTriggerUnit()
            call Heal.unit(this.u, 0.01*HealBase(GetUnitAbilityLevel(this.u, SPELL_ID))*GetUnitState(this.u, UNIT_STATE_MAX_LIFE), 4)
            call DestroyEffect(AddSpecialEffectTarget(HEAL_ATTACHED, this.u, "origin"))
            call TimerStart(NewTimerEx(this), 0.00, false, function thistype.debuff)
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope