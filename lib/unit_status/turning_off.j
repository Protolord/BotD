library TurningOff uses Table, TimerUtilsEx
    
/*
    TurningOff.create(unit)
        - Prevents a unit from turning (change facing angle).
    
    this.duration = <time duration>
        - Add an expiration timer to a TurningOff instance.

    this.destroy()
        - Destroy the TurningOff instance.
*/
    
    struct TurningOff extends array
        implement Alloc
        
        private unit u
        private static Table tb
        
        method destroy takes nothing returns nothing
            local integer id = GetHandleId(this.u)
            set thistype.tb[id] = thistype.tb[id] - 1
            if thistype.tb[id] == 0 then
                call SetUnitTurnSpeed(this.u, thistype.tb.real[id])
                call thistype.tb.real.remove(id)
                call thistype.tb.remove(id)
            endif
            set this.u = null
            call this.deallocate()
        endmethod
        
        static method create takes unit u returns thistype
            local thistype this = thistype.allocate()
            local integer id = GetHandleId(u)
            set this.u = u
            if thistype.tb.has(id) then
                set thistype.tb[id] = thistype.tb[id] + 1
            else
                set thistype.tb[id] = 1
                set thistype.tb.real[id] = GetUnitTurnSpeed(u)
                call SetUnitTurnSpeed(u, 0.0)
            endif
            return this
        endmethod
        
        private static method expires takes nothing returns nothing
            call thistype(ReleaseTimer(GetExpiredTimer())).destroy()
        endmethod
        
        method operator duration= takes real time returns nothing
            call TimerStart(NewTimerEx(this), time, false, function thistype.expires)
        endmethod
        
        private static method onInit takes nothing returns nothing
            set thistype.tb = Table.create()
        endmethod
        
    endstruct
    
    
endlibrary
