scope FuryOfTheLycan

    globals
        private constant integer SPELL_ID = 'A243'
        private constant integer SPELL_BUFF = 'B243'
    endglobals

    private function Duration takes integer level returns real
        return 9.0 + 0.0*level
    endfunction

    private struct SpellBuff extends Buff

        private static constant integer RAWCODE = 'B243'
        private static constant integer DISPEL_TYPE = BUFF_POSITIVE
        private static constant integer STACK_TYPE = BUFF_STACK_NONE

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod

        implement BuffApply
    endstruct

    struct FuryOfTheLycan extends array
        implement Alloc

        private unit caster

        private static method debuff takes nothing returns nothing
            local thistype this = ReleaseTimer(GetExpiredTimer())
            call UnitRemoveAbility(this.caster, 'Bbsk')
            set this.caster = null
            call this.deallocate()
        endmethod

        private static method onDamage takes nothing returns nothing
            if Buff.has(null, Damage.target, SpellBuff.typeid) then
                call Heal.unit(Damage.target, Damage.target, 2.0*Damage.amount, 1.0, true)
                set Damage.amount = 0
                call Damage.lockAmount()
            endif
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            local unit caster = GetTriggerUnit()
            local SpellBuff b = SpellBuff.add(caster, caster)
            set b.duration = Duration(GetUnitAbilityLevel(caster, SPELL_ID))
            set this.caster = caster
            call TimerStart(NewTimerEx(this), 0.00, false, function thistype.debuff)
            set caster = null
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call Damage.registerModifier(function thistype.onDamage)
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SpellBuff.initialize()
            call SystemTest.end()
        endmethod

    endstruct

endscope