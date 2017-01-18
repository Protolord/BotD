scope Repression  
 
    globals
        private constant integer SPELL_ID = 'A332'
        private constant integer UNIT_ID = 'uSco'
        private constant real OFFSET = 100.0
    endglobals
    
    private function Duration takes integer level returns real
        return 0.0*level
    endfunction
    
    private function ScoutHealth takes integer level returns real
        if level == 11 then
            return 2000.0
        endif
        return 100.0*level
    endfunction
    
    private function SightRadius takes integer level returns real
        if level == 11 then
            return GLOBAL_SIGHT
        endif
        return 100.0*level + 200.0
    endfunction
    
    private function Speed takes integer level returns real
        return 0.0*level + 250.0
    endfunction
    
    struct Repression extends array
        
        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local real angle = GetUnitFacing(caster)*bj_DEGTORAD
            local integer lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            local real x = GetUnitX(caster) + OFFSET*Cos(angle)
            local real y = GetUnitY(caster) + OFFSET*Sin(angle)
            local unit scout = CreateUnit(GetTriggerPlayer(), UNIT_ID, x, y, GetUnitFacing(caster))
            local real radius = SightRadius(lvl)
            local real duration= Duration(lvl)
            call SetUnitScale(scout, 0.95 + 0.05*lvl, 0, 0)
            call SetUnitMoveSpeed(scout, Speed(lvl))
            call TrueSight.create(scout, radius)
            call FlySight.create(scout, radius)
            call SetUnitMaxState(scout, UNIT_STATE_MAX_LIFE, ScoutHealth(lvl))
            call UnitApplyTimedLife(scout, 'BTLF', Duration(lvl))
            call SetUnitAnimation(scout, "birth")
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call PreloadUnit(UNIT_ID)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope