scope Slow

    globals
        private constant integer SPELL_ID   = 'AH92'
    endglobals

    private function Duration takes integer level returns real
        if level == 11 then
            return 6.0
        endif
        return 0.5*level
    endfunction

    private function MoveSlow takes integer level returns real
        if level == 11 then
            return 0.75
        endif
        return 0.5
    endfunction

    private struct SpellBuff extends Buff

        private Movespeed ms

        private static constant integer RAWCODE = 'DH92'
        private static constant integer DISPEL_TYPE = BUFF_NEGATIVE
        private static constant integer STACK_TYPE = BUFF_STACK_PARTIAL

        method onRemove takes nothing returns nothing
            call this.ms.destroy()
        endmethod

        method onApply takes nothing returns nothing
            set this.ms = Movespeed.create(this.target, 0, 0)
        endmethod

        method reapply takes real moveSlow returns nothing
            call this.ms.change(moveSlow, 0)
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod

        implement BuffApply
    endstruct

    struct Slow extends array

        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local integer lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            local SpellBuff b = SpellBuff.add(caster, GetSpellTargetUnit())
            call b.reapply(-MoveSlow(lvl))
            set b.duration = Duration(lvl)
            call SystemMsg.create(GetUnitName(caster) + " cast thistype")
            set caster = null
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SpellBuff.initialize()
            call SystemTest.end()
        endmethod

    endstruct

endscope