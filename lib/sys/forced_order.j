library ForcedOrder uses TimerUtilsEx

/*
    ForcedOrder.create(unit, orderId, x, y)
        - Forced a unit to issue orderId into (x, y).
    
    this.destroy()
        - Destroy the ForcedOrder instance.
*/
    globals
        private constant real TIMEOUT = 0.5
    endglobals
    
    struct ForcedOrder extends array
        implement Alloc
        implement List
        
        private unit u
        private integer orderId
        private real x
        private real y
        
        readonly trigger trg
        
        private static Table tb
        
        method destroy takes nothing returns nothing
            call this.pop()
            call thistype.tb.remove(GetHandleId(this.u))
            call DestroyTrigger(this.trg)
            set this.u = null
            set this.trg = null
            call this.deallocate()
        endmethod
        
        private static method onOrder takes nothing returns boolean
            local thistype this = thistype.tb[GetHandleId(GetTriggerUnit())]
            if GetIssuedOrderId() == ORDER_smart then
                call DisableTrigger(this.trg)
                call IssuePointOrderById(this.u, this.orderId, this.x, this.y)
                call EnableTrigger(this.trg)
            endif
            return false
        endmethod
        
        private static method onPeriod takes nothing returns nothing
            local thistype this = thistype(0).next
            loop
                exitwhen this == 0
                if not UnitAlive(this.u) then
                    call this.destroy()
                endif
                set this = this.next
            endloop
        endmethod
        
        static method change takes unit u, integer order, real x, real y returns nothing
            local thistype this = thistype.tb[GetHandleId(u)]
            if this > 0 then
                set this.orderId = order
                set this.x = x
                set this.y = y
                call DisableTrigger(this.trg)
                call IssuePointOrderById(this.u, order, x, y)
                call EnableTrigger(this.trg)
            endif
        endmethod
        
        static method create takes unit u, integer order, real x, real y returns thistype
            local thistype this = thistype.allocate()
            set this.u = u
            set this.orderId = order
            set this.x = x
            set this.y = y
            call IssuePointOrderById(u, order, x, y)
            set this.trg = CreateTrigger()
            call TriggerRegisterUnitEvent(this.trg, u, EVENT_UNIT_ISSUED_POINT_ORDER)
            call TriggerRegisterUnitEvent(this.trg, u, EVENT_UNIT_ISSUED_TARGET_ORDER)
            call TriggerRegisterUnitEvent(this.trg, u, EVENT_UNIT_ISSUED_ORDER)
            call TriggerAddCondition(this.trg, function thistype.onOrder)
            set thistype.tb[GetHandleId(u)] = this
            call this.push(TIMEOUT)
            return this
        endmethod
        
        private static method onInit takes nothing returns nothing
            set thistype.tb = Table.create()
        endmethod
    endstruct

endlibrary