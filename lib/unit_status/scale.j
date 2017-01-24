library Scale uses Table

/*
    Scale.create(unit, addedScale)
        - Create a scaling instance to unit.
    
    this.speed = <scaling speed>
        - Sets how fast the scaling happens.
    
    this.duration = <scaling duration>
        - Scale instance duration.
    
    Scale.get(unit)
        - Returns the current scale of a unit.
    
    this.destroy()
        - Destroy Scaling instance.

*/
    globals
        //Scaling Speed per second used as default.
        private constant real DEFAULT_SPEED = 1.0
        private constant real TIMEOUT = 0.05
    endglobals
    
    struct Scale
        
        public real speed
        public real duration
        private unit u
        private real add
        private real subtract
        private integer id
        
        private static Table tb
        private static timer t = CreateTimer()
        
        private thistype next
        private thistype prev
        
        method destroy takes nothing returns nothing
            set this.duration = 0
        endmethod
        
        static method get takes unit u returns real
            local integer id = GetHandleId(u)
            if thistype.tb.has(id) then
                return thistype.tb.real[id]
            endif
            return 1.0
        endmethod
        
        private static method onPeriod takes nothing returns nothing
            local thistype this = thistype(0).next
            local real added
            local real new
            loop
                exitwhen this == 0
                set this.duration = this.duration - TIMEOUT
                if this.duration > 0 then
                    if this.add != 0 then
                        if this.add > 0 then
                            set added = RMinBJ(this.add, this.speed*TIMEOUT)
                        else
                            set added = -RMinBJ(RAbsBJ(this.add), this.speed*TIMEOUT)
                        endif
                        set this.add = this.add - added
                        set this.subtract = this.subtract + added
                        set new = thistype.tb.real[this.id] + added
                        set thistype.tb.real[this.id] = new
                        call SetUnitScale(this.u, new, 0, 0)
                    endif
                else
                    if this.subtract != 0 then
                        if this.subtract > 0 then
                            set added = RMinBJ(this.subtract, this.speed*TIMEOUT)
                        else
                            set added = -RMinBJ(RAbsBJ(this.subtract), this.speed*TIMEOUT)
                        endif
                        set this.subtract = this.subtract - added
                        set new = thistype.tb.real[this.id] - added
                        set thistype.tb.real[this.id] = new
                        call SetUnitScale(this.u, new, 0, 0)
                    else
                        set thistype.tb[this.id] = thistype.tb[this.id] - 1
                        if thistype.tb[this.id] == 0 then
                            call thistype.tb.remove(this.id)
                            call thistype.tb.real.remove(this.id)
                        endif
                        set this.next.prev = this.prev
                        set this.prev.next = this.next
                        if thistype(0).next == 0 then
                            call PauseTimer(thistype.t)
                        endif
                        set this.u = null
                        call this.deallocate()
                    endif
                endif
                set this = this.next
            endloop
        endmethod
        
        static method create takes unit u, real addedScale returns thistype
            local thistype this = thistype.allocate()
            set this.u = u
            set this.id = GetHandleId(u)
            set this.speed = DEFAULT_SPEED
            set this.add = addedScale
            set this.subtract = 0
            set this.duration = 0xFFFFFF
            if thistype.tb.real.has(this.id) then
                set thistype.tb[this.id] = thistype.tb[this.id] + 1
            else
                set thistype.tb.real[this.id] = 1.0
                 set thistype.tb[this.id] = 1
            endif
            set this.next = thistype(0)
            set this.prev = thistype(0).prev
            set this.prev.next = this
            set this.next.prev = this
            if this.prev == 0 then
                call TimerStart(thistype.t, TIMEOUT, true, function thistype.onPeriod)
            endif
            return this
        endmethod
        
        private static method onInit takes nothing returns nothing
            set thistype.tb = Table.create()
        endmethod
        
    endstruct
    
endlibrary