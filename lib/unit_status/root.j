library Root uses Table, TimerUtilsEx

/*
    Root.create(unit)
        - Roots a unit, preventing it from moving.

    this.duration = <time duration>
        - Add an expiration timer to a Root instance.

    this.destroy()
        - Destroy the Root instance.
*/

    struct Root extends array
        implement Alloc

        private unit u
        private static Table tb

        method destroy takes nothing returns nothing
            local integer id = GetHandleId(this.u)
            set thistype.tb[id] = thistype.tb[id] - 1
            if thistype.tb[id] == 0 then
                call SetUnitPropWindow(this.u, GetUnitDefaultPropWindow(this.u))
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
                call SetUnitPropWindow(u, 0)
            endif
            return this
        endmethod

        private static method expires takes nothing returns nothing
            call thistype(ReleaseTimer(GetExpiredTimer())).destroy()
        endmethod

        method operator duration= takes real time returns nothing
            call TimerStart(NewTimerEx(this), time, false, function thistype.expires)
        endmethod

        private static method reapply takes nothing returns nothing
            local thistype this = ReleaseTimer(GetExpiredTimer())
            local integer id = GetHandleId(this.u)
            if thistype.tb.has(id) then
                call SetUnitPropWindow(this.u, 0)
            endif
            set this.u = null
            call this.deallocate()
        endmethod

        private static method onTransform takes nothing returns nothing
            local thistype this = thistype.allocate()
            set this.u = GetTriggerUnit()
            call TimerStart(NewTimerEx(this), thistype.tb.real[GetSpellAbilityId()] + 0.01, false, function thistype.reapply)
        endmethod

        static method check takes unit u returns nothing
            local integer id = GetHandleId(u)
            if thistype.tb.has(id) then
                call SetUnitPropWindow(u, 0)
            endif
        endmethod

        static method registerTransform takes integer spellId, real delay returns nothing
            call RegisterSpellEffectEvent(spellId, function thistype.onTransform)
            set thistype.tb.real[spellId] = delay
        endmethod

        private static method onInit takes nothing returns nothing
            set thistype.tb = Table.create()
        endmethod

    endstruct

endlibrary
