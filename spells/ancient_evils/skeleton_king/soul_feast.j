scope SoulFeast

    globals
        private constant integer SPELL_ID = 'A744'
        private constant string SFX = "Abilities\\Spells\\Undead\\Darksummoning\\DarkSummonTarget.mdl"
    endglobals

    //In percent
    private function MaxHPHeal takes integer level returns real
        if level == 11 then
            return 25.0
        endif
        return 5.0 + 1.0*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return IsUnitEnemy(u, p)
    endfunction

    struct SoulFeast extends array

        private static method onDeath takes nothing returns boolean
            local unit killer = GetKillingUnit()
            local unit dying = GetTriggerUnit()
            local integer level = GetUnitAbilityLevel(killer, SPELL_ID)
            if level > 0 and TargetFilter(dying, GetOwningPlayer(killer)) then
                call Heal.unit(killer, killer, MaxHPHeal(level)*GetUnitState(killer, UNIT_STATE_MAX_LIFE)/100.0, 4.0, true)
                call AddSpecialEffectTimer(AddSpecialEffectTarget(SFX, killer, "origin"), 2.0)
            endif
            set killer = null
            set dying = null
            return false
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
            call SystemTest.end()
        endmethod

    endstruct

endscope