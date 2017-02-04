scope DeadlyRepulse
 
    globals
        private constant integer SPELL_ID = 'A6XX'
        private constant integer UNIT_ID = 'uDeR'
        private constant real OFFSET = 100.0
    endglobals
    
    struct DeadlyRepulse extends array

        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local real angle = GetUnitFacing(caster)*bj_DEGTORAD
            set Invisible.create(CreateUnit(GetTriggerPlayer(), UNIT_ID, GetUnitX(caster) + OFFSET*Cos(angle), GetUnitY(caster) + OFFSET*Sin(angle), angle*bj_RADTODEG + 25), 0).autoDestroy = true
            set caster = null
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call PreloadUnit(UNIT_ID)
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope