scope Destinction

    globals
        private constant integer SPELL_ID = 'AH21'
        private constant string SFX = "Abilities\\Spells\\Human\\DivineShield\\DivineShieldTarget.mdl"
    endglobals

    private function Duration takes integer level returns real
        return 0.5*level
    endfunction

    private struct SpellBuff extends Buff

        private effect sfx
        private Disarm d
        private Invulnerable i

        private static constant integer RAWCODE = 'BH21'
        private static constant integer DISPEL_TYPE = BUFF_POSITIVE
        private static constant integer STACK_TYPE = BUFF_STACK_NONE

        method onRemove takes nothing returns nothing
            call this.i.destroy()
            call this.d.destroy()
            call DestroyEffect(this.sfx)
            set this.sfx = null
        endmethod

        method onApply takes nothing returns nothing
            set this.i = Invulnerable.create(this.target)
            set this.d = Disarm.create(this.target)
            set this.sfx = AddSpecialEffectTarget(SFX, this.target, "origin")
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod

        implement BuffApply
    endstruct

    struct Destinction extends array

        private static method onCast takes nothing returns nothing
            set SpellBuff.add(GetTriggerUnit(), GetSpellTargetUnit()).duration = Duration(GetUnitAbilityLevel(GetTriggerUnit(), SPELL_ID))
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