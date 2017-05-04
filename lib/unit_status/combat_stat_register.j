library CombatStatRegister uses CombatStat

/*
    CombatStat.getDamage(unit)
        - Return the average damage of a unit as a real.

    CombatStat.getRange(unit)
        - Return the attack range of a unit as a real.

    CombatStat.unit(unitId, baseDmg, dice, sides, atkRange)
        - Register a unitId's object editor damage data

    CombatStat.hero(unitId, baseDmg, dice, sides, atkRange, attribute)
        - Register a unitId's object editor damage data

*/

    globals
        private constant integer STAT_STR = 1
        private constant integer STAT_AGI = 2
        private constant integer STAT_INT = 3
    endglobals

    private struct CombatStatRegister extends array

        private static method onInit takes nothing returns nothing
            //Ancients
            call CombatStat.hero('UAra', 115, 2, 12, 50, STAT_AGI)
            call CombatStat.hero('UBAr', 115, 2, 12, 50, STAT_AGI)
            call CombatStat.hero('UCav', 115, 2, 12, 50, STAT_STR)
            call CombatStat.hero('UDem', 115, 2, 12, 50, STAT_STR)
            call CombatStat.hero('UGar', 115, 2, 12, 100, STAT_AGI)
            call CombatStat.hero('USke', 115, 2, 12, 50, STAT_STR)
            call CombatStat.hero('UVaL', 115, 2, 12, 50, STAT_AGI)
            call CombatStat.hero('UWeW', 115, 2, 12, 50, STAT_STR)
            call CombatStat.hero('UWeF', 115, 2, 12, 50, STAT_STR)
            call CombatStat.hero('UWeH', 115, 2, 12, 50, STAT_STR)
            call CombatStat.hero('UWra', 115, 2, 12, 50, STAT_INT)
            //Living Forces
            call CombatStat.hero('H001', 30, 2, 12, 100, STAT_INT)
            call CombatStat.hero('HT01', 30, 2, 12, 100, STAT_INT)
            call CombatStat.hero('H002', 30, 2, 12, 100, STAT_AGI)
            call CombatStat.hero('H003', 30, 2, 12, 100, STAT_STR)
            call CombatStat.hero('H004', 30, 2, 12, 100, STAT_INT)
            call CombatStat.hero('H005', 30, 2, 12, 100, STAT_INT)
            call CombatStat.hero('H006', 30, 2, 12, 100, STAT_INT)

            //Default heroes
            call CombatStat.hero('Hmkg', 0, 2, 6, 100, STAT_STR)
            call CombatStat.hero('Hblm', 0, 2, 4, 600, STAT_INT)
            //Default units
            call CombatStat.unit('hpea', 4, 1, 2, 90)
            call CombatStat.unit('opeo', 6, 1, 2, 90)
            call CombatStat.unit('hTes', 4, 1, 1, 700)
            call CombatStat.unit('hsor', 7, 1, 3, 600)
            call CombatStat.unit('hrif', 16, 2, 4, 400)
            call CombatStat.unit('unec', 7, 1, 2, 600)
        endmethod

    endstruct

endlibrary
