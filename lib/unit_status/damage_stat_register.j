library DamageStatRegister uses DamageStat  

/*
    DamageStat.get(unit)
        - Return the average damage of a unit as an integer.
            
    DamageStat.unit(unitId, baseDmg, dice, sides)
		- Register a unitId's object editor damage data
		
    DamageStat.hero(unitId, baseDmg, dice, sides, attribute)
		- Register a unitId's object editor damage data

*/    
    globals
		private constant integer STAT_STR = 1
		private constant integer STAT_AGI = 2
		private constant integer STAT_INT = 3
	endglobals

    private struct DamageStatRegister extends array
 
        private static method onInit takes nothing returns nothing
			//Ancients
            call DamageStat.hero('UAra', 115, 2, 12, STAT_AGI)
			call DamageStat.hero('UBAr', 115, 2, 12, STAT_AGI)
            call DamageStat.hero('UCav', 115, 2, 12, STAT_STR)
            call DamageStat.hero('UDem', 115, 2, 12, STAT_STR)
            call DamageStat.hero('UGar', 115, 2, 12, STAT_AGI)
            call DamageStat.hero('USke', 115, 2, 12, STAT_STR)
            call DamageStat.hero('UVaL', 115, 2, 12, STAT_AGI)
            call DamageStat.hero('UWeW', 115, 2, 12, STAT_STR)
            call DamageStat.hero('UWeF', 115, 2, 12, STAT_STR)
            call DamageStat.hero('UWeH', 115, 2, 12, STAT_STR)
            call DamageStat.hero('UWra', 115, 2, 12, STAT_INT)
			//Living Forces
			
			//Default units
            call DamageStat.hero('HDwa', 0, 2, 6, STAT_STR)
            call DamageStat.hero('Hmkg', 0, 2, 6, STAT_STR)

            call DamageStat.unit('hpea', 4, 1, 2)
            call DamageStat.unit('hTes', 4, 1, 1)
			call DamageStat.unit('hsor', 7, 1, 3)
            call DamageStat.unit('hrif', 16, 2, 4)
            call DamageStat.unit('unec', 7, 1, 2)
        endmethod
        
    endstruct
    
endlibrary
