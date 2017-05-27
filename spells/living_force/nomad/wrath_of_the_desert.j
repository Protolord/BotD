scope WrathOfTheDesert

    globals
        private constant integer SPELL_ID = 'AHD4'
        private constant integer UNIT_ID = 'HT0D'
        private constant string SFX = "Models\\Effects\\WrathOfTheDesertEffect.mdx"
    endglobals

    struct WrathOfTheDesert extends array

        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            call DestroyEffect(AddSpecialEffect(SFX, GetUnitX(caster), GetUnitY(caster)))
            if GetUnitTypeId(caster) != UNIT_ID then
                call SystemMsg.create(GetUnitName(caster) + " cast thistype")
            endif
            set caster = null
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call Root.registerTransform(SPELL_ID, 0.0)
            call Movespeed.registerTransform(SPELL_ID, 0.0)
            call PreloadUnit(UNIT_ID)
            call SystemTest.end()
        endmethod

    endstruct

endscope