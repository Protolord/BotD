scope ShatteredEarth
 
    globals
        private constant integer SPELL_ID = 'A533'
        private constant string SFX = "Models\\Effects\\ShatteredEarth.mdx"
    endglobals
    
    private function Sight takes integer level returns real
        if level == 11 then
            return GLOBAL_SIGHT
        endif
        return 0.0*level + 1500.0
    endfunction
    
    private function NumberOfExplosions takes integer level returns integer
        if level == 11 then
            return 1
        endif
        return level
    endfunction
    
    private function Duration takes integer level returns real
        return 15.0 + 0.0*level
    endfunction
    
    struct ShatteredEarth extends array
        
        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local integer lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            local real sight = Sight(lvl)
            local real i = NumberOfExplosions(lvl)
            local real duration = Duration(lvl)
            local player p = GetTriggerPlayer()
            local unit u
            loop
                exitwhen i == 0
                set u = GetRecycledDummyAnyAngle(GetRandomReal(WorldBounds.playMinX, WorldBounds.playMaxX), GetRandomReal(WorldBounds.playMinY, WorldBounds.playMaxY), 0)
                call DestroyEffect(AddSpecialEffectTarget(SFX, u, "origin"))
                call TrueSight.createEx(u, sight, duration)
                call FlySight.createEx(u, sight, duration)
                set i = i - 1
            endloop
            set u = null
            set caster = null
            set p = null
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope