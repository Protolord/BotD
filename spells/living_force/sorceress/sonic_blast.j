scope SonicBlast

    globals
        private constant integer SPELL_ID = 'AHI2'
        private constant string SFX = "Models\\Effects\\SonicBlast.mdx"
    endglobals

    private function Radius takes integer level returns real
        return 300.0 + 0.0*level
    endfunction

    struct SonicBlast extends array

        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local integer lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            local Effect e = Effect.createAnyAngle(SFX, GetUnitX(caster), GetUnitY(caster), 20)
            set e.scale = Radius(lvl)/700.0
            call e.destroy()
            call SystemMsg.create(GetUnitName(caster) + " cast thistype")
            set caster = null
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SystemTest.end()
        endmethod

    endstruct

endscope