scope RainOfFire
 
    globals
        private constant integer SPELL_ID = 'A521'
        private constant string MISSILE_SFX = "Abilities\\Weapons\\LavaSpawnMissile\\LavaSpawnMissile.mdl"
    endglobals
    
    struct RainOfFire extends array
        
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