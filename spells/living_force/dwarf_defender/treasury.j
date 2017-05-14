scope Treasury

    globals
        private constant integer SPELL_ID = 'AH33'
        private constant integer UNIT_ID1 = 'hbew'
        private constant integer UNIT_ID2 = 'hbew'
    endglobals

    private function Chance takes integer level returns real
        return 0.1*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and (GetUnitTypeId(u) == UNIT_ID1 or GetUnitTypeId(u) == UNIT_ID2)
    endfunction

    struct Treasury extends array

        private static method onDamage takes nothing returns nothing
            local integer lvl = GetUnitAbilityLevel(Damage.source, SPELL_ID)
            if lvl > 0 and Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.coded and TargetFilter(Damage.target, GetOwningPlayer(Damage.source)) and GetRandomReal(0, 100) <= Chance(lvl) then
                call Damage.kill(Damage.source, Damage.target)
            endif
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call Damage.register(function thistype.onDamage)
            call SystemTest.end()
        endmethod

    endstruct
endscope