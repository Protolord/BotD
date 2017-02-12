scope StonyPath
 
    globals
        private constant integer SPELL_ID = 'A633'
        private constant string SFX = "Models\\Effects\\StonyPath.mdx"
    endglobals
    
    private function Sight takes integer level returns real
        if level == 11 then
            return 1000.0
        endif
        return 100.0*level
    endfunction

    struct StonyPath extends array
        
        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local unit u = CreateUnit(GetTriggerPlayer(), 'dumi', GetUnitX(caster), GetUnitY(caster), 0)
            local integer lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            local real sight = Sight(lvl)
            call TrueSight.create(u, sight)
            call FlySight.create(u, sight)
            call AddSpecialEffectTarget(SFX, u, "origin")
            call SetUnitFlyHeight(u, 50, 50)
            call SetUnitScale(u, 0.75 + sight/1500, 0, 0)
            set caster = null
            set u = null
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope