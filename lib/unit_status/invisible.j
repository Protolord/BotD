library Invisible uses Table, TimerUtilsEx

/*
    Invisible.create(unit, duration)
        - Add invisibility to a unit for a period of time.
    
    this.destroy()
        - Destroy the Invisibility instance.
*/

    globals
        private constant integer PERMA_INVI = 'AInS'
    endglobals
    
    struct Invisible extends array
        implement Alloc
        
        readonly unit u
        readonly thistype next
        readonly thistype prev
        
        private static Table counter
        
        static method has takes unit u returns boolean
            return GetUnitAbilityLevel(u, PERMA_INVI) > 0
        endmethod
        
        method destroy takes nothing returns nothing
            local integer id = GetHandleId(this.u)
            set thistype.counter[id] = thistype.counter[id] - 1
            if thistype.counter[id] == 0 then
                call UnitRemoveAbility(this.u, PERMA_INVI)
                set this.prev.next = this.next
                set this.next.prev = this.prev
                //call SystemMsg.create("Removed Invisibility from " + GetUnitName(this.u))
            endif
            set this.u = null
            call this.deallocate()
        endmethod
        
        private static method expire takes nothing returns nothing
            call thistype(ReleaseTimer(GetExpiredTimer())).destroy()
        endmethod
        
        static method create takes unit u, real duration returns thistype
            local thistype this = thistype.allocate()
            local integer id = GetHandleId(u)
            set this.u = u
            if thistype.counter[id] == 0 then
                call UnitMakeAbilityPermanent(u, true, PERMA_INVI)
                call UnitAddAbility(u, PERMA_INVI)
                set this.next = thistype(0)
                set this.prev = thistype(0).prev
                set this.next.prev = this
                set this.prev.next = this
                //call SystemMsg.create("Added Invisibility to " + GetUnitName(u))
            endif
            set thistype.counter[id] = thistype.counter[id] + 1
            if duration > 0 then
                call TimerStart(NewTimerEx(this), duration, false, function thistype.expire)
            endif
            return this
        endmethod
        
        static if DEBUG_MODE then
            private static method register takes nothing returns nothing
                local group g = CreateGroup()
                local unit u
                call GroupEnumUnitsInRect(g, bj_mapInitialPlayableArea, null)
                loop
                    set u = FirstOfGroup(g)
                    exitwhen u == null
                    call GroupRemoveUnit(g, u)
                    if GetUnitAbilityLevel(u, 'Agho') > 0 or GetUnitAbilityLevel(u, 'Apiv') > 0 then
                        call Invisible.create(u, 0)
                    endif
                endloop
                call DestroyGroup(g)
                set g = null
                call DestroyTimer(GetExpiredTimer())
            endmethod
        endif
        
        private static method onInit takes nothing returns nothing
            set thistype.counter = Table.create()
            debug call TimerStart(CreateTimer(), 0.0, false, function thistype.register)
        endmethod
        
    endstruct
    
endlibrary