scope CursedContact

    globals
        private constant integer SPELL_ID = 'AHD1'
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
    endglobals

    //In percent of Max HP
    private function DamagePerMaxHP takes integer level returns real
        if level == 11 then
            return 50.0
        endif
        return 2.0*level
    endfunction

    private function Chance takes integer level returns real
        return 20.0 + 0.0*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return IsUnitEnemy(u, p)
    endfunction

    struct CursedContact extends array

        private static method onDamage takes nothing returns nothing
            local integer level = GetUnitAbilityLevel(Damage.target, SPELL_ID)
            if level > 0 and Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.coded and CombatStat.isMelee(Damage.source) and CombatStat.getAttackType(Damage.source) != ATTACK_TYPE_MAGIC and TargetFilter(Damage.source, GetOwningPlayer(Damage.target))  then
                if GetRandomReal(0, 100) <= Chance(level) then
                    call Damage.element.apply(Damage.target, Damage.source, 0.01*DamagePerMaxHP(level)*GetUnitState(Damage.target, UNIT_STATE_MAX_LIFE), ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_NORMAL)
                endif
            endif
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call Damage.register(function thistype.onDamage)
            call SystemTest.end()
        endmethod

    endstruct

endscope