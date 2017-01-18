module List
    
/*
    this.push(timeout)
        - Push an instance to the linked list with a timer. Every <timeout>, thistype.onPeriod is called.

    this.pop()
        - Remove instance from the list.
*/

    readonly thistype next
    readonly thistype prev
    
    private static timer t
    
    method push takes real timeout returns nothing
        set this.next = thistype(0)
        set this.prev = thistype(0).prev
        set this.next.prev = this
        set this.prev.next = this
        if this.prev == 0 then
            set thistype.t = NewTimer()
            call TimerStart(thistype.t, timeout, true, function thistype.onPeriod)
        endif
    endmethod
    
    method pop takes nothing returns nothing
        set this.prev.next = this.next
        set this.next.prev = this.prev
        if thistype(0).next == 0 then
            call ReleaseTimer(thistype.t)
            set thistype.t = null
        endif
    endmethod
    
endmodule