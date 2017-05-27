scope FleshHunger

    globals
        private constant integer SPELL_ID = 'A214'
    endglobals

    private function SlowDuration takes integer level returns real
        if level == 11 then
            return 20.0
        endif
        return 1.0*level
    endfunction

    private function SlowEffect takes integer level returns real
        return -0.85 + 0.0*level
    endfunction

    private struct SpellBuff extends Buff

        public Movespeed ms

        private static constant integer RAWCODE = 'D214'
        private static constant integer DISPEL_TYPE = BUFF_NEGATIVE
        private static constant integer STACK_TYPE = BUFF_STACK_PARTIAL

        method onRemove takes nothing returns nothing
            call this.ms.destroy()
        endmethod

        method onApply takes nothing returns nothing
            set this.ms = Movespeed.create(this.target, 0, 0)
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod

        implement BuffApply
    endstruct

    struct FleshHunger extends array

        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local integer lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            local SpellBuff b = SpellBuff.add(caster, GetSpellTargetUnit())
            set b.duration = SlowDuration(lvl)
            call b.ms.change(SlowEffect(lvl), 0)
            set caster = null
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype on " + GetUnitName(GetSpellTargetUnit()))
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SpellBuff.initialize()
            call SystemTest.end()
        endmethod

    endstruct

endscope