//============================================================================
// SpellEffectEvent
// - Version 1.1.0.0
//
// API
// ---
//     RegisterSpellEffectEvent(integer abil, code onCast)
//      
// 
// Requires
// --------
//     RegisterPlayerUnitEvent: hiveworkshop.com/forums/showthread.php?t=203338
// 
// Optional
// --------
//     Table: hiveworkshop.com/forums/showthread.php?t=188084
//
/*
=============   Why this is important? =================

1. Does not generate 16 events per spell.

2. This uses one trigger evaluation instead of one for each 
   individual spell (some maps have quite a few). This helps keep 
   framerate high and fluid when a spell is cast.
*/
library SpellBeginEvent requires RegisterPlayerUnitEvent, optional Table
 
//============================================================================
private module M
    
    static if LIBRARY_Table then
        static Table tb
    else
        static hashtable ht = InitHashtable()
    endif
    
    static method onCast takes nothing returns nothing
        static if LIBRARY_Table then
            call TriggerEvaluate(.tb.trigger[GetSpellAbilityId()])
        else
            call TriggerEvaluate(LoadTriggerHandle(.ht, 0, GetSpellAbilityId()))
        endif
    endmethod
 
    private static method onInit takes nothing returns nothing
        static if LIBRARY_Table then
            set .tb = Table.create()
        endif
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_CHANNEL, function thistype.onCast)
    endmethod
endmodule
 
//============================================================================
private struct S extends array
    implement M
endstruct
 
//============================================================================
function RegisterSpellBeginEvent takes integer abil, code onCast returns nothing
    static if LIBRARY_Table then
        if not S.tb.handle.has(abil) then
            set S.tb.trigger[abil] = CreateTrigger()
        endif
        call TriggerAddCondition(S.tb.trigger[abil], Filter(onCast))
    else
        if not HaveSavedHandle(S.ht, 0, abil) then
            call SaveTriggerHandle(S.ht, 0, abil, CreateTrigger())
        endif
        call TriggerAddCondition(LoadTriggerHandle(S.ht, 0, abil), Filter(onCast)
    endif
endfunction
 
endlibrary