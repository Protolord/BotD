library UnitTimer uses TimerUtilsEx

/*
    function RemoveUnitTimed(unit, duration)
        - Add a remove timer to a unit.
*/

    private struct S extends array
        public static Table tb

        private static method onInit takes nothing returns nothing
            set thistype.tb = Table.create()
        endmethod
    endstruct

    private function UnitExpires takes nothing returns nothing
        local timer t = GetExpiredTimer()
        local integer id = GetHandleId(t)
        call RemoveUnit(S.tb.unit[id])
        call S.tb.unit.remove(id)
        call ReleaseTimer(t)
        set t = null
    endfunction

    function RemoveUnitTimed takes unit u, real time returns nothing
        local timer t = NewTimer()
        set S.tb.unit[GetHandleId(t)] = u
        call TimerStart(t, time, false, function UnitExpires)
    endfunction

endlibrary