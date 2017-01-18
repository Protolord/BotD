scope Hellguard
 
    globals
        private constant integer SPELL_ID = 'A543'
    endglobals
    
    struct Hellguard extends array
        
        private static method onCast takes nothing returns nothing
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope