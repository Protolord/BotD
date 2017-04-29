scope Tunnel
 
    globals
        private constant integer SPELL_ID = 'A433'
        private constant integer UNIT_ID = 'uTun'
        private constant string SFX = "Objects\\Spawnmodels\\Undead\\ImpaleTargetDust\\ImpaleTargetDust.mdl"
    endglobals
    
    private function Speed takes integer level returns real
        return 0.0*level + 522
    endfunction
    
    private function SightRadius takes integer level returns real
        if level == 11 then
            return GLOBAL_SIGHT
        endif
        return 150.0*level
    endfunction
    
    private function UnitHP takes integer level returns real
        return 0.0*level + 800.0
    endfunction
    
    private function Duration takes integer level returns real
        return 0.0*level + 15.0
    endfunction
    
    struct Tunnel extends array
        

        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local integer lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            local real facing = GetUnitFacing(caster)
            local real x = GetUnitX(caster) + 100*Cos(facing*bj_DEGTORAD)
            local real y = GetUnitY(caster) + 100*Sin(facing*bj_DEGTORAD)
            local real sight = SightRadius(lvl)
            local unit u = CreateUnit(GetTriggerPlayer(), UNIT_ID, x, y, facing)
            if lvl == 11 then
                call SetUnitScale(u, 1.0, 0, 0)
            else
                call SetUnitScale(u, 0.5 + 0.025*lvl, 0, 0)
            endif
            call UnitApplyTimedLife(u, 'BTLF', Duration(lvl))
            call SetUnitMoveSpeed(u, Speed(lvl))
            call IssuePointOrderById(u, ORDER_move, GetSpellTargetX(), GetSpellTargetY())
            call TrueSight.create(u, sight)
            call FlySight.create(u, sight)
            call SetUnitMaxState(u, UNIT_STATE_MAX_LIFE, UnitHP(lvl))
            set caster = null
            set u = null
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