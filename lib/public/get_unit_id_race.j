library GetUnitIdRace 
    /******************************************************************    
                          GetUnitIdRace v1.00
                               by Flux
                                  
        Allows you to get the race of a unit based on the rawcode.
        Only works if the user followed the Blizzard Race rawcode 
        convention:
            H/h: RACE_HUMAN
            O/o: RACE_ORC
            U/u: RACE_UNDEAD
            E/e: RACE_NIGHTELF
        
        API:
            function GetUnitIdRace takes integer unitId returns race
    
    ******************************************************************/

    private struct Data extends array
        
        readonly static integer array raceId
        
        private static method onInit takes nothing returns nothing
            set thistype.raceId[0x48] = 1
            set thistype.raceId[0x68] = 1
            set thistype.raceId[0x4F] = 2
            set thistype.raceId[0x6F] = 2
            set thistype.raceId[0x55] = 3
            set thistype.raceId[0x75] = 3
            set thistype.raceId[0x45] = 4
            set thistype.raceId[0x65] = 4
        endmethod
        
    endstruct
    
    function GetUnitIdRace takes integer unitId returns race
        return ConvertRace(Data.raceId[unitId/(0x01000000)])
    endfunction
    
    
endlibrary