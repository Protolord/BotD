library PathingOff requires Table

/*
    PathingOff.create(unit)
        - Turns off the pathing of a unit.

    this.destroy()
        - Destroy the PathingOff instance.
*/
    struct PathingOff extends array
        implement Alloc
        
        private unit u
        private static Table tb
        
        method destroy takes nothing returns nothing
            local integer id = GetHandleId(this.u)
            set thistype.tb[id] = thistype.tb[id] - 1
            if thistype.tb[id] == 0 then
                call SetUnitPathing(this.u, true)
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
                call SetUnitPathing(u, false)
            endif
            return this
        endmethod
        
        private static method onInit takes nothing returns nothing
            set thistype.tb = Table.create()
        endmethod
        
    endstruct

endlibrary