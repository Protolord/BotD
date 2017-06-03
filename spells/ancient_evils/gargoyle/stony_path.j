scope StonyPath

    globals
        private constant integer SPELL_ID = 'A633'
        private constant integer TERRAIN_TILE = 'Lrok'
        private constant string SFX = "Objects\\Spawnmodels\\Undead\\ImpaleTargetDust\\ImpaleTargetDust.mdl"
        private constant string SFX2 = "Abilities\\Spells\\Human\\slow\\slowtarget.mdl"
    endglobals

    private function Sight takes integer level returns real
        if level == 11 then
            return 1000.0
        endif
        return 100.0*level
    endfunction

    struct StonyPath extends array

        private static method closestTile takes real r returns real
            if r > 0 then
                return I2R(128*R2I((r + 64)/128) + 0)
            else
                return I2R(128*R2I((r - 64)/128) + 0)
            endif
        endmethod

        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local real x = thistype.closestTile(GetUnitX(caster))
            local real y = thistype.closestTile(GetUnitY(caster))
            local unit u = CreateUnit(GetTriggerPlayer(), 'dumi', x, y, 0)
            local integer lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            local real sight = Sight(lvl)
            call DestroyEffect(AddSpecialEffect(SFX, x, y))
            call AddSpecialEffectTarget(SFX2, u, "origin")
            call TrueSight.create(u, sight)
            call FlySight.create(u, sight)
            call SetTerrainType(x, y, TERRAIN_TILE, -1, 1, 0)
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