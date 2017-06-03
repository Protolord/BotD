library Invisible uses Table, TimerUtilsEx

/*
    Invisible.create(unit, duration)
        - Add invisibility to a unit for a period of time.

    this.destroy()
        - Destroy the Invisibility instance.
*/

    globals
        private constant integer PERMA_INVI = 'AInS'

        private constant integer REFRESH_COUNT = 20
    endglobals

    struct Invisible extends array
        implement Alloc

        public boolean autoDestroy
        readonly unit u
        readonly thistype next
        readonly thistype prev

        private static trigger deathTrg = CreateTrigger()
        private static Table counter
        private static integer count = 0
        private static group g = CreateGroup()

        static method has takes unit u returns boolean
            return GetUnitAbilityLevel(u, PERMA_INVI) > 0
        endmethod

        private static method reAdd takes nothing returns nothing
            call TriggerRegisterUnitEvent(thistype.deathTrg, GetEnumUnit(), EVENT_UNIT_DEATH)
        endmethod

        method destroy takes nothing returns nothing
            local integer id = GetHandleId(this.u)
            set thistype.counter[id] = thistype.counter[id] - 1
            if thistype.counter[id] == 0 then
                call UnitRemoveAbility(this.u, PERMA_INVI)
                set this.prev.next = this.next
                set this.next.prev = this.prev
            endif
            call GroupRemoveUnit(thistype.g, this.u)
            //Death trigger refresh
            set thistype.count = thistype.count + 1
            if thistype.count >= REFRESH_COUNT then
                call DestroyTrigger(thistype.deathTrg)
                set thistype.deathTrg = CreateTrigger()
                call TriggerAddCondition(thistype.deathTrg, Condition(function thistype.onDeath))
                call ForGroup(thistype.g, function thistype.reAdd)
                set thistype.count = 0
            endif
            set this.u = null
            call this.deallocate()
        endmethod

        private static method onDeath takes nothing returns boolean
            local thistype this = thistype(0).next
            local unit dying = GetTriggerUnit()
            loop
                exitwhen this == 0
                if this.u == dying and this.autoDestroy then
                    call this.destroy()
                endif
                set this = this.next
            endloop
            return false
        endmethod

        private static method expire takes nothing returns nothing
            call thistype(ReleaseTimer(GetExpiredTimer())).destroy()
        endmethod

        static method create takes unit u, real duration returns thistype
            local thistype this = thistype.allocate()
            local integer id = GetHandleId(u)
            set this.u = u
            set this.autoDestroy = false
            if thistype.counter[id] == 0 then
                call UnitAddAbility(u, PERMA_INVI)
                call UnitMakeAbilityPermanent(u, true, PERMA_INVI)
                set this.next = thistype(0)
                set this.prev = thistype(0).prev
                set this.next.prev = this
                set this.prev.next = this
            endif
            set thistype.counter[id] = thistype.counter[id] + 1
            call GroupAddUnit(thistype.g, this.u)
            call TriggerRegisterUnitEvent(thistype.deathTrg, this.u, EVENT_UNIT_DEATH)
            if duration > 0 then
                call TimerStart(NewTimerEx(this), duration, false, function thistype.expire)
            endif
            return this
        endmethod

        private static method onInit takes nothing returns nothing
            set thistype.counter = Table.create()
            call TriggerAddCondition(thistype.deathTrg, Condition(function thistype.onDeath))
        endmethod

    endstruct

endlibrary