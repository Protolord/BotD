library Silence uses Table, TimerUtilsEx, AbilityTimer

/*
    Silence.create(unit, duration)
        - Silences a unit at a certain duration.

    this.destroy()
        - Destroy the Silence instance.
*/

    globals
        private constant integer SILENCE_SPELL = 'ASil'
        private constant integer SILENCE_BUFF = 'BSil'
    endglobals

    struct Silence extends array
        implement Alloc

        private unit u
        private static Table tb

        method destroy takes nothing returns nothing
            local integer id = GetHandleId(this.u)
            set thistype.tb[id] = thistype.tb[id] - 1
            if thistype.tb[id] == 0 then
                call UnitRemoveAbility(this.u, SILENCE_BUFF)
                call thistype.tb.remove(id)
            endif
            set this.u = null
            call this.deallocate()
        endmethod

        private static method expires takes nothing returns nothing
            call thistype(ReleaseTimer(GetExpiredTimer())).destroy()
        endmethod

        static method create takes unit u, real time returns thistype
            local thistype this = thistype.allocate()
            local integer id = GetHandleId(u)
            local unit dummy
            set this.u = u
            if thistype.tb.has(id) then
                set thistype.tb[id] = thistype.tb[id] + 1
            else
                set thistype.tb[id] = 1
                set dummy = GetRecycledDummyAnyAngle(GetUnitX(u), GetUnitY(u), 0)
                call SetUnitOwner(dummy, GetOwningPlayer(u), false)
                call PauseUnit(dummy, false)
                call AbilityTimer.create(dummy, SILENCE_SPELL, 0.5)
                call IssueTargetOrderById(dummy, ORDER_drunkenhaze, u)
                call DummyAddRecycleTimer(dummy, 1.0)
            endif
            if time > 0 then
                call TimerStart(NewTimerEx(this), time, false, function thistype.expires)
            endif
            return this
        endmethod

        private static method onInit takes nothing returns nothing
            set thistype.tb = Table.create()
        endmethod

    endstruct

endlibrary
