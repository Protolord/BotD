library Movespeed /*

                    Movespeed v1.21
                       by Flux
       
        Applies a stacking movespeed modification to a unit
        through code.
       
        Formula:
        New Movespeed = (Default Movespeed + Total FlatBonus)*(1 + Total PercentBonus)
   
    */ requires /*
       (nothing)
   
    */ optional Table /*
       If not found, the system will create 1 hashtable. Hashtables are
       limited to 255 per map.
       
    */ optional TimerUtils /*
       If found, timers for duration will be recycled.
       
   
    ******************************
                   API
    ******************************
   
    struct Movespeed
   
        static method create(unit, percentBonus, flatBonus)
            - Create a Movespeed modification.
            EXAMPLE: local Movespeed ms = Movespeed.create(GetTriggerUnit(), 0.15, 0)
           
        method operator duration= 
            - Sets the current duration of the Movespeed instace.
            EXAMPLE: set ms.duration = 5
       
        method operator duration
            - Reads the current duration of the Movespeed instance.
            - Returns zero if the instance has no duration
            EXAMPLE: call BJDebugMsg("Time left: " + R2S(ms.duration))
           
        method change(newPercentBonus, newFlatBonus)
            - Change the movespeed modification of a certain instance
            EXAMPLE: call ms.change(0.20, 0)
       
        method destroy()
            - Remove an instance of movespeed modification.
            - Not needed if thhe Movespeed instance has a duration.
   
    -------------------
           NOTE: 
    -------------------
        All in-game movespeed modifiers such as Boots of Speed, Endurance Aura, Slow Aura, etc.
        will still work with this system, but all of them are always applied last.  
       
        Formula:
        New Movespeed = ((Default Movespeed + Total FlatBonus)*(1 + Total PercentBonus) + Total in-game FlatBonus)*(1 + Total in-game PercentBonus)
       
    -----------
      CREDITS
    -----------
        Bribe    - Table
        Vexorian - TimerUtils
        Aniki    - For the movespeed formula used by Warcraft 3

*/    
    struct Movespeed
       
        readonly real pb
        readonly real fb
        readonly unit u
        private real default
        private timer t
       
        private thistype head
        private integer count
       

        static if LIBRARY_Table then
            private static Table tb
        else
            private static hashtable hash = InitHashtable()
        endif
       
       
        method destroy takes nothing returns nothing
            local thistype head = this.head
            set head.pb = head.pb - this.pb
            set head.fb = head.fb - this.fb
            set head.count = head.count - 1
            if this.t != null then
                static if LIBRARY_TimerUtils then
                    call ReleaseTimer(this.t)
                else
                    static if LIBRARY_Table then
                        call thistype.tb.remove(GetHandleId(this.t))
                    else
                        call RemoveSavedInteger(thistype.hash, GetHandleId(this.t), 0)
                    endif
                    call DestroyTimer(this.t)
                endif
                set this.t = null
            endif
            if head.count == 0 then
                static if LIBRARY_Table then
                    call thistype.tb.remove(GetHandleId(this.u))
                else
                    call RemoveSavedInteger(thistype.hash, GetHandleId(this.u), 0)
                endif
                call head.deallocate()
            endif
            call SetUnitMoveSpeed(this.u, (head.default + head.fb)*(1 + head.pb))
            set this.u = null
            call this.deallocate()
        endmethod
       
        method change takes real newPercentBonus, integer newFlatBonus returns nothing
            local thistype head = this.head
            set head.pb = head.pb + newPercentBonus - this.pb
            set head.fb = head.fb + newFlatBonus - this.fb
            set this.pb = newPercentBonus
            set this.fb = newFlatBonus
            call SetUnitMoveSpeed(u, (head.default + head.fb)*(1 + head.pb))
        endmethod
       
        static method create takes unit u, real percentBonus, integer flatBonus returns thistype
            local thistype this = thistype.allocate()
            local integer id = GetHandleId(u)
            local thistype head
            static if LIBRARY_Table then
                if thistype.tb.has(id) then
                    set head = thistype.tb[id]
                    set head.count = head.count + 1
                else
                    set head = thistype.allocate()
                    set head.pb = 0
                    set head.fb = 0
                    set head.count = 1
                    set head.default = GetUnitDefaultMoveSpeed(u)
                    set thistype.tb[id] = head
                endif
            else
                if HaveSavedInteger(thistype.hash, id, 0) then
                    set head = LoadInteger(thistype.hash, id, 0)
                    set head.count = head.count + 1
                else
                    set head = thistype.allocate()
                    set head.pb = 0
                    set head.fb = 0
                    set head.count = 1
                    set head.default = GetUnitDefaultMoveSpeed(u)
                    call SaveInteger(thistype.hash, id, 0, head)
                endif
            endif
            set this.u = u
            set this.pb = percentBonus
            set this.fb = flatBonus
            set this.head = head
            set head.pb = head.pb + this.pb
            set head.fb = head.fb + this.fb
            call SetUnitMoveSpeed(u, (head.default + head.fb)*(1 + head.pb))
            return this
        endmethod
       
        private static method expired takes nothing returns nothing
            static if LIBRARY_TimerUtils then
                call thistype(GetTimerData(GetExpiredTimer())).destroy()
            elseif LIBRARY_Table then
                call thistype(thistype.tb[GetHandleId(GetExpiredTimer())]).destroy()
            else
                call thistype(LoadInteger(thistype.hash, GetHandleId(GetExpiredTimer()), 0)).destroy()
            endif
        endmethod
       
        method operator duration takes nothing returns real
            if this.t == null then
                return 0.0
            endif
            return TimerGetRemaining(this.t)
        endmethod
       
        method operator duration= takes real time returns nothing
            if this.t == null then
                static if LIBRARY_TimerUtils then
                    set this.t = NewTimerEx(this)
                else
                    set this.t = CreateTimer()
                    static if LIBRARY_Table then
                        set thistype.tb[GetHandleId(t)] = this
                    else
                        call SaveInteger(thistype.hash, GetHandleId(t), 0, this)
                    endif
                endif
            endif
            call TimerStart(this.t, time, false, function thistype.expired)
        endmethod
       
       
        static if LIBRARY_Table then
            private static method onInit takes nothing returns nothing
                set thistype.tb = Table.create()
            endmethod
        endif
       
    endstruct
endlibrary