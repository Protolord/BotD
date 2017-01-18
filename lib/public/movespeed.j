library Movespeed /*

                    Movespeed v1.11
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
    
    ******************************
                   API
    ******************************
    
    struct Movespeed
    
        static method create(unit, percentBonus, flatBonus)
            - Create a Movespeed modification.
            
        static method createTimed(unit, percentBonus, flatBonus, duration)
            - Timed movespeed modification.
            
        method change(newPercentBonus, newFlatBonus)
            - Change the movespeed modification of a certain instance
        
        method destroy()
            - Remove an instance of movespeed modification.
    
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
        Table by Bribe

*/    
    struct Movespeed extends array
        implement Alloc
        
        readonly real pb
        readonly real fb
        readonly unit u
        
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
            if head.count == 0 then
                static if LIBRARY_Table then
                    call thistype.tb.remove(GetHandleId(this.u))
                else
                    call RemoveSavedInteger(thistype.hash, GetHandleId(this.u), 0)
                endif
                call head.deallocate()
            endif
            call SetUnitMoveSpeed(u, (GetUnitDefaultMoveSpeed(u) + head.fb)*(1 + head.pb))
            call this.deallocate()
        endmethod
        
        method change takes real newPercentBonus, integer newFlatBonus returns nothing
            local thistype head = this.head
            set head.pb = head.pb + newPercentBonus - this.pb
            set head.fb = head.fb + newFlatBonus - this.fb
            set this.pb = newPercentBonus
            set this.fb = newFlatBonus
            call SetUnitMoveSpeed(u, (GetUnitDefaultMoveSpeed(u) + head.fb)*(1 + head.pb))
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
                    call SaveInteger(thistype.hash, id, 0, head)
                endif
            endif
            set this.u = u
            set this.pb = percentBonus
            set this.fb = flatBonus
            set this.head = head
            set head.pb = head.pb + this.pb
            set head.fb = head.fb + this.fb
            call SetUnitMoveSpeed(u, (GetUnitDefaultMoveSpeed(u) + head.fb)*(1 + head.pb))
            return this
        endmethod
        
        private static method expired takes nothing returns nothing
            local timer t = GetExpiredTimer()
            static if LIBRARY_Table then
                call thistype(thistype.tb[GetHandleId(t)]).destroy()
            else
                call thistype(LoadInteger(thistype.hash, GetHandleId(t), 0)).destroy()
            endif
            call DestroyTimer(t)
            set t = null
        endmethod
        
        static method createTimed takes unit u, real multiplier, integer flatBonus, real duration returns thistype
            local thistype this = thistype.create(u, multiplier, flatBonus)
            local timer t = CreateTimer()
            static if LIBRARY_Table then
                set thistype.tb[GetHandleId(t)] = this
            else
                call SaveInteger(thistype.hash, GetHandleId(t), 0, this)
            endif
            call TimerStart(t, duration, false, function thistype.expired)
            return this
        endmethod
        
        static if LIBRARY_Table then
            private static method onInit takes nothing returns nothing
                set thistype.tb = Table.create()
            endmethod
        endif
        
    endstruct
endlibrary
