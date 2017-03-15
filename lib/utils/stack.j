module Stack
    
/*
    this.push(timeout)
        - Push an instance to the linked list with a timer. Every <timeout>, thistype.onPeriod is called.

    this.pop()
        - Remove instance from the list.
*/

    readonly thistype next
    
    readonly static thistype top = 0
    private static timer t
    
    method push takes real timeout returns nothing
        if thistype.top == 0 then
            set thistype.t = NewTimer()
            call TimerStart(thistype.t, timeout, true, function thistype.onPeriod)
        endif
        set this.next = thistype.top
        set thistype.top = this
    endmethod
    
    method pop takes nothing returns nothing
        set thistype.top = thistype.top.next
        if thistype.top == 0 then
            call ReleaseTimer(thistype.t)
            set thistype.t = null
        endif
    endmethod
    
endmodule