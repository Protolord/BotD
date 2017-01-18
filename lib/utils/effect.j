library Effect uses TimerUtilsEx

/*
    function AddSpecialEffectTimer(effect, duration)
        - Add a destroy timer to an effect.
*/
    
    private struct S extends array
        public static Table tb
        
        private static method onInit takes nothing returns nothing
            set thistype.tb = Table.create()
        endmethod
    endstruct
    
    private function EffectExpires takes nothing returns nothing
        local timer t = GetExpiredTimer()
        local integer id = GetHandleId(t) 
        call DestroyEffect(S.tb.effect[id])
        call S.tb.effect.remove(id)
        call ReleaseTimer(t)
        set t = null
    endfunction
    
    function AddSpecialEffectTimer takes effect e, real time returns nothing
        local timer t = NewTimer()
        set S.tb.effect[GetHandleId(t)] = e
        call TimerStart(t, time, false, function EffectExpires)
    endfunction

endlibrary