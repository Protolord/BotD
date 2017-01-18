library Phase uses Table, TimerUtilsEx

/*
    Phase.create(unit)
        - Roots a unit, preventing it from moving.
    
    this.duration = <time duration>
        - Add an expiration timer to a Root instance.

    this.destroy()
        - Destroy the Phase instance.
*/

    struct Phase extends array
        implement Alloc
        
        private unit u
        private static Table tb
        
        private static constant integer PHASE_ITEM = 'IPhS'
        private static constant integer PHASE_BUFF = 'BPhS'

        
        method destroy takes nothing returns nothing
            local integer id = GetHandleId(this.u)
            set thistype.tb[id] = thistype.tb[id] - 1
            if thistype.tb[id] == 0 then
                call UnitRemoveAbility(this.u, PHASE_BUFF)
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
                call UnitAddItemById(u, PHASE_ITEM)
            endif
            return this
        endmethod
        
        private static method onInit takes nothing returns nothing
            set thistype.tb = Table.create()
        endmethod
        
    endstruct
    
endlibrary
