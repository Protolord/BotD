scope InnerResistance

    globals
        private constant integer SPELL_ID = 'A823'
        private constant integer BUFF_ID = 'B823'
    endglobals

    //In percent
    private function DurationReduction takes integer level returns real
        if level == 11 then
            return 75.0
        endif
        return 5.0*level
    endfunction

    struct InnerResistance extends array

        private static method onBuff takes nothing returns nothing
            local integer level = GetUnitAbilityLevel(BuffEvent.buff.target, SPELL_ID)
            if level > 0 and BuffEvent.buff.dispelType == BUFF_NEGATIVE then
                set BuffEvent.buff.duration = BuffEvent.buff.duration*(100 - DurationReduction(level))/100
            endif
        endmethod

        private static method learn takes nothing returns nothing
            local unit u = GetTriggerUnit()
            if GetLearnedSkill() == SPELL_ID then
                call UnitAddAbility(u, BUFF_ID)
                call UnitMakeAbilityPermanent(u, true, BUFF_ID)
            endif
            set u = null
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call BuffEvent.create(function thistype.onBuff)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_SKILL, function thistype.learn)
            call SystemTest.end()
        endmethod

    endstruct

endscope