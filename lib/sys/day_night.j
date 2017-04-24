library DayNight
    
/*
    DayNight.registerDay(code)
        - Registers code that will execute when it becomes day time.

    DayNight.registerNight(code)
        - Registers code that will execute when it becomes night time.
    
    DayNight.get()
        - Returns TIME_DAY for day time and TIME_NIGHT for night time.
*/

    globals
        constant integer TIME_DAY = 1
        constant integer TIME_NIGHT = 2
    endglobals

    struct DayNight
        
        private string exec
        private static trigger trgDay = CreateTrigger()
        private static trigger trgNight= CreateTrigger()
        
        static method get takes nothing returns integer 
            local real time = GetFloatGameState(GAME_STATE_TIME_OF_DAY)
            if (time >= 6.00 and time < 18.00) then
                return TIME_DAY
            endif
            return TIME_NIGHT
        endmethod

        private static method run takes nothing returns boolean
            local thistype this
            if GetFloatGameState(GAME_STATE_TIME_OF_DAY) == 6.00 then
                call TriggerEvaluate(thistype.trgDay)
            elseif GetFloatGameState(GAME_STATE_TIME_OF_DAY) == 18.00 then
                call TriggerEvaluate(thistype.trgNight)
            endif
            return false
        endmethod
        
        static method registerDay takes code c returns nothing
            call TriggerAddCondition(trgDay, Condition(c))
        endmethod
        
        static method registerNight takes code c returns nothing
            call TriggerAddCondition(trgNight, Condition(c))
        endmethod
        
        private static method onInit takes nothing returns nothing
            local trigger t = CreateTrigger()
            call TriggerRegisterGameStateEvent(t, GAME_STATE_TIME_OF_DAY, EQUAL, 6.00)
            call TriggerRegisterGameStateEvent(t, GAME_STATE_TIME_OF_DAY, EQUAL, 18.00)
            call TriggerAddCondition(t, Condition(function thistype.run))
            set t = null
        endmethod
        
    endstruct
    
endlibrary
