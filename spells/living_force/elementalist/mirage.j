scope Mirage

    globals
        private constant integer SPELL_ID = 'AH41'
        private constant string SFX_BUFF = "Models\\Effects\\Mirage.mdx"
    endglobals

    //In Percent
    private function Duration takes integer level returns real
        return 0.6*level + 4
    endfunction

    private struct SpellBuff extends Buff

        private effect sfx

        private static constant integer RAWCODE = 'BH41'
        private static constant integer DISPEL_TYPE = BUFF_POSITIVE
        private static constant integer STACK_TYPE = BUFF_STACK_NONE

        method onRemove takes nothing returns nothing
            call DestroyEffect(this.sfx)
            set this.sfx = null
        endmethod

        private static method onDamage takes nothing returns nothing
            if Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.coded and Buff.has(null, Damage.target, SpellBuff.typeid) then
                set Damage.amount = 0
            endif
        endmethod

        method onApply takes nothing returns nothing
            set this.sfx = AddSpecialEffectTarget(SFX_BUFF, this.target, "origin")
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
            call Damage.registerModifier(function thistype.onDamage)
        endmethod

        implement BuffApply
    endstruct

    struct Mirage extends array

        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local integer lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            local SpellBuff b = SpellBuff.add(caster, GetSpellTargetUnit())
            set b.duration = Duration(lvl)
            set caster = null
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SpellBuff.initialize()
            call SystemTest.end()
        endmethod

    endstruct

endscope