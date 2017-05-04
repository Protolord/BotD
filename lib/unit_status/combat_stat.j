library CombatStat uses Table

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
        private constant real MELEE_THRESHOLD = 150.0
    endglobals

    struct CombatStat extends array
        implement Alloc

        private integer baseDmg
        private integer dice
        private integer sides
        private integer range
        private integer attribute

        private static Table tb

        static method getRange takes unit u returns real
            local thistype this = thistype.tb[GetUnitTypeId(u)]
            if this > 0 then
                return I2R(this.range)
            endif
            return 0.0
        endmethod

        static method isMelee takes unit u returns boolean
            local real range = thistype.getRange(u)
            return range <= MELEE_THRESHOLD and range > 0
        endmethod

        static method getDamage takes unit u returns real
            local thistype this = thistype.tb[GetUnitTypeId(u)]
            if this > 0 then
                if IsUnitType(u, UNIT_TYPE_HERO) then
                    return I2R(this.baseDmg) + 0.5*(this.dice*this.sides + 1) + I2R(GetHeroStr(u, false))
                endif
                return I2R(this.baseDmg) + 0.5*(this.dice*this.sides + 1)
            endif
            return 0.0
        endmethod

        static method unit takes integer unitId, integer baseDmg, integer dice, integer sides, integer range returns nothing
            local thistype this
            if not thistype.tb.has(unitId) then
                set this = thistype.allocate()
                set this.baseDmg = baseDmg
                set this.dice = dice
                set this.sides = sides
                set this.range = range
                set thistype.tb[unitId] = this
            endif
        endmethod

        static method hero takes integer unitId, integer baseDmg, integer dice, integer sides, integer range, integer attribute returns nothing
            local thistype this
            if not thistype.tb.has(unitId) then
                set this = thistype.allocate()
                set this.baseDmg = baseDmg
                set this.dice = dice
                set this.sides = sides
                set this.range = range
                set this.attribute = attribute
                set thistype.tb[unitId] = this
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            set thistype.tb = Table.create()
        endmethod

    endstruct

endlibrary
