scope Lycanthrope

    globals
        private constant integer SPELL_ID = 'A224'
        private constant string CAST_SFX = "Models\\Effects\\LycanthropeEffect.mdx"
        private constant string BUFF_SFX = "Abilities\\Spells\\Orc\\Bloodlust\\BloodLustSpecial.mdl"
    endglobals

    private function Duration takes integer level returns real
        if level == 11 then
            return 10.0
        endif
        return 0.5*level
    endfunction

    private struct SpellBuff extends Buff

        private effect handLeft
        private effect handRight

        private static constant integer RAWCODE = 'B224'
        private static constant integer DISPEL_TYPE = BUFF_POSITIVE
        private static constant integer STACK_TYPE = BUFF_STACK_NONE

        method onRemove takes nothing returns nothing
            call UnitRemoveAbility(this.target, 'a224')
            call DestroyEffect(this.handLeft)
            call DestroyEffect(this.handRight)
            set this.handLeft = null
            set this.handRight = null
        endmethod

        method onApply takes nothing returns nothing
            set this.handLeft = AddSpecialEffectTarget(BUFF_SFX, this.target, "hand left")
            set this.handRight = AddSpecialEffectTarget(BUFF_SFX, this.target, "hand right")
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod

        implement BuffApply
    endstruct

    struct Lycanthrope extends array

        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local thistype id = GetUnitTypeId(caster)
            local SpellBuff b
            if id == 'UWeW' or id == 'UWeH' then
                set b = SpellBuff.add(caster, caster)
                set b.duration = Duration(GetUnitAbilityLevel(caster, SPELL_ID))
                call DestroyEffect(AddSpecialEffect(CAST_SFX, GetUnitX(caster), GetUnitY(caster)))
                call SystemMsg.create(GetUnitName(caster) + " cast thistype")
            endif
            set caster = null
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call Root.registerTransform(SPELL_ID, 0.0)
            call Movespeed.registerTransform(SPELL_ID, 0.0)
            call SpellBuff.initialize()
            call SystemTest.end()
        endmethod

    endstruct

endscope