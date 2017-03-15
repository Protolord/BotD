scope StonyPath
 
    globals
        private constant integer SPELL_ID = 'A633'
        private constant integer TERRAIN_TILE = 'Lrok'
        private constant string SFX = "Objects\\Spawnmodels\\Undead\\ImpaleTargetDust\\ImpaleTargetDust.mdl"
    endglobals
    
    private function Sight takes integer level returns real
        if level == 11 then
            return 1000.0
        endif
        return 100.0*level
    endfunction

    struct StonyPath extends array
        
        private static method nearestTile takes real x returns real
            local integer i
            if x > 0 then
                set i = 128*(R2I(x + 64)/128)
            else
                set i = 128*(R2I(x - 64)/128)
            endif
            return I2R(i)
        endmethod

        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local real x = thistype.nearestTile(GetUnitX(caster))
            local real y = thistype.nearestTile(GetUnitY(caster))
            local unit u = CreateUnit(GetTriggerPlayer(), 'dumi', x, y, 0)
            local integer lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            local real sight = Sight(lvl)
            local real d = -sight
            call TrueSight.create(u, sight)
            call FlySight.create(u, sight)
            loop
                exitwhen d > sight
                call SetTerrainType(x + d, y, TERRAIN_TILE, -1, 1, 0)
                call SetTerrainType(x, y + d, TERRAIN_TILE, -1, 1, 0)
                call DestroyEffect(AddSpecialEffect(SFX, x + d, y))
                call DestroyEffect(AddSpecialEffect(SFX, x, y + d))
                set d = d + 42
            endloop
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