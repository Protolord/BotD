library PreloadSystem uses TimerUtilsEx, DummyRecycler

/*
    PreloadSpell(spellId)
        - Preload a spell so it won't lag the first time it's used.

    PreloadUnit(unitId)
        - Preload a unit so it won't lag the first time it appeared.
*/

    globals
        private constant player NEUTRAL = Player(14)
    endglobals

    private struct S extends array
        public static timer t = CreateTimer()
        public static unit u = null
    endstruct

    private function PreloaderDestroy takes nothing returns nothing
        call RecycleDummy(S.u)
        set S.u = null
    endfunction

    function PreloadSpell takes integer id returns nothing
        if S.u == null then
            set S.u = GetRecycledDummyAnyAngle(WorldBounds.maxX, WorldBounds.maxY, 0)
            call TimerStart(S.t, 5.0, false, function PreloaderDestroy)
        endif
        call UnitAddAbility(S.u, id)
        call UnitRemoveAbility(S.u, id)
    endfunction

    function PreloadUnit takes integer id returns nothing
        call RemoveUnit(CreateUnit(NEUTRAL, id, WorldBounds.playMaxX, WorldBounds.playMaxY, 0))
    endfunction

endlibrary