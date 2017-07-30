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
            call CombatStat.hero('UAra', ATTACK_TYPE_SIEGE, 115, 2, 12, 50, STAT_AGI)
            call CombatStat.hero('UBAr', ATTACK_TYPE_SIEGE, 115, 2, 12, 50, STAT_AGI)
            call CombatStat.hero('UCav', ATTACK_TYPE_SIEGE, 115, 2, 12, 50, STAT_STR)
            call CombatStat.hero('UDem', ATTACK_TYPE_SIEGE, 115, 2, 12, 50, STAT_STR)
            call CombatStat.hero('UGar', ATTACK_TYPE_SIEGE, 115, 2, 12, 100, STAT_AGI)
            call CombatStat.hero('USke', ATTACK_TYPE_SIEGE, 115, 2, 12, 50, STAT_STR)
            call CombatStat.hero('UVaL', ATTACK_TYPE_SIEGE, 115, 2, 12, 50, STAT_AGI)
            call CombatStat.hero('UWeW', ATTACK_TYPE_SIEGE, 115, 2, 12, 50, STAT_STR)
            call CombatStat.hero('UWeF', ATTACK_TYPE_SIEGE, 115, 2, 12, 50, STAT_STR)
            call CombatStat.hero('UWeH', ATTACK_TYPE_SIEGE, 115, 2, 12, 50, STAT_STR)
            call CombatStat.hero('UWra', ATTACK_TYPE_SIEGE, 115, 2, 12, 50, STAT_INT)
            //Living Forces
            call CombatStat.hero('H001', ATTACK_TYPE_HERO, 30, 2, 12, 100, STAT_INT)
            call CombatStat.hero('H002', ATTACK_TYPE_HERO, 30, 2, 12, 100, STAT_AGI)
            call CombatStat.hero('H003', ATTACK_TYPE_HERO, 30, 2, 12, 100, STAT_STR)
            call CombatStat.hero('H004', ATTACK_TYPE_HERO, 30, 2, 12, 100, STAT_INT)
            call CombatStat.hero('H005', ATTACK_TYPE_HERO, 30, 2, 12, 100, STAT_INT)
            call CombatStat.hero('H006', ATTACK_TYPE_HERO, 30, 2, 12, 100, STAT_INT)
            call CombatStat.hero('H007', ATTACK_TYPE_HERO, 30, 2, 12, 100, STAT_INT)
            call CombatStat.hero('H008', ATTACK_TYPE_HERO, 30, 2, 12, 100, STAT_AGI)
            call CombatStat.hero('H009', ATTACK_TYPE_HERO, 30, 2, 12, 100, STAT_STR)
            call CombatStat.hero('H00A', ATTACK_TYPE_HERO, 30, 2, 12, 100, STAT_INT)
            call CombatStat.hero('H00B', ATTACK_TYPE_HERO, 30, 2, 12, 100, STAT_STR)
            call CombatStat.hero('H00C', ATTACK_TYPE_HERO, 30, 2, 12, 100, STAT_AGI)
            call CombatStat.hero('H00D', ATTACK_TYPE_HERO, 30, 2, 12, 100, STAT_STR)
            call CombatStat.hero('H00E', ATTACK_TYPE_HERO, 30, 2, 12, 100, STAT_AGI)
            call CombatStat.hero('H00F', ATTACK_TYPE_HERO, 30, 2, 12, 100, STAT_AGI)
            call CombatStat.hero('H00G', ATTACK_TYPE_HERO, 30, 2, 12, 100, STAT_INT)
            call CombatStat.hero('H00H', ATTACK_TYPE_HERO, 30, 2, 12, 100, STAT_INT)
            call CombatStat.hero('H00I', ATTACK_TYPE_HERO, 30, 2, 12, 100, STAT_INT)
            call CombatStat.hero('H00J', ATTACK_TYPE_HERO, 30, 2, 12, 100, STAT_STR)
            call CombatStat.hero('H00K', ATTACK_TYPE_HERO, 30, 2, 12, 100, STAT_AGI)
            call CombatStat.hero('H00L', ATTACK_TYPE_HERO, 30, 2, 12, 100, STAT_AGI)
            call CombatStat.hero('H00M', ATTACK_TYPE_HERO, 30, 2, 12, 100, STAT_AGI)
            call CombatStat.hero('H00N', ATTACK_TYPE_HERO, 30, 2, 12, 100, STAT_AGI)
            call CombatStat.hero('H00O', ATTACK_TYPE_HERO, 30, 2, 12, 100, STAT_INT)

            //Default heroes
            call CombatStat.hero('Hmkg', ATTACK_TYPE_HERO, 0, 2, 6, 100, STAT_STR)
            call CombatStat.hero('Hblm', ATTACK_TYPE_HERO, 0, 2, 4, 600, STAT_INT)
            //Default units
            call CombatStat.unit('hpea', ATTACK_TYPE_NORMAL, 4, 1, 2, 90)
            call CombatStat.unit('opeo', ATTACK_TYPE_NORMAL, 6, 1, 2, 90)
            call CombatStat.unit('hTes', ATTACK_TYPE_PIERCE, 4, 1, 1, 700)
            call CombatStat.unit('hsor', ATTACK_TYPE_MAGIC, 7, 1, 3, 600)
            call CombatStat.unit('hrif', ATTACK_TYPE_PIERCE, 16, 2, 4, 400)
            call CombatStat.unit('hmpr', ATTACK_TYPE_MAGIC, 7, 1, 2, 600)
            call CombatStat.unit('unec', ATTACK_TYPE_MAGIC, 7, 1, 2, 600)
        endmethod

    endstruct

endlibrary
