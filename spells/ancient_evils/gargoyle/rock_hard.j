scope RockHard

    globals
        private constant integer SPELL_ID = 'A623'
        private constant integer BUFF_ID = 'B623'
    endglobals

    //In percent
    private function DamageReduction takes integer level returns real
        if level == 11 then
            return 12.0
        endif
        return 1.5*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return IsUnitEnemy(u, p)
    endfunction

    struct RockHard extends array

        private static method onDamage takes nothing returns nothing
            local integer level = GetUnitAbilityLevel(Damage.target, SPELL_ID)
            if level > 0 and Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.coded and CombatStat.getAttackType(Damage.source) != ATTACK_TYPE_MAGIC and not CombatStat.isMelee(Damage.source) and TargetFilter(Damage.source, GetOwningPlayer(Damage.target))  then
                set Damage.amount = RMaxBJ(Damage.amount - DamageReduction(level), 0)
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
            call Damage.registerModifier(function thistype.onDamage)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_SKILL, function thistype.learn)
            call SystemTest.end()
        endmethod

    endstruct

endscope