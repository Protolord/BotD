scope SoulMark

    globals
        private constant integer SPELL_ID = 'A732'
        private constant string MODEL = "Models\\Effects\\SoulBreak.mdx"
        private constant real TIMEOUT = 0.05
        private constant integer TRUE_SIGHT_ABILITY = 'ATSS'
        private constant real RADIUS = 300.0
    endglobals

    private function Duration takes integer level returns real
        return 0.0*level + 300.0
    endfunction

    private struct SpellBuff extends Buff

        private unit dummy

        private static constant integer RAWCODE = 'D732'
        private static constant integer DISPEL_TYPE = BUFF_NEGATIVE
        private static constant integer STACK_TYPE = BUFF_STACK_PARTIAL

        method onRemove takes nothing returns nothing
            call this.pop()
            call UnitClearBonus(this.dummy, BONUS_SIGHT_RANGE)
            call UnitRemoveAbility(this.dummy, TRUE_SIGHT_ABILITY)
            call RecycleDummy(this.dummy)
            set this.dummy = null
        endmethod

        static method onPeriod takes nothing returns nothing
            local thistype this = thistype(0).next
            loop
                exitwhen this == 0
                call SetUnitX(this.dummy, GetUnitX(this.target))
                call SetUnitY(this.dummy, GetUnitY(this.target))
                set this = this.next
            endloop
        endmethod

        implement List

        method onApply takes nothing returns nothing
            set this.dummy = GetRecycledDummyAnyAngle(GetUnitX(this.target), GetUnitY(this.target), 0)
            call SetUnitOwner(this.dummy, GetOwningPlayer(this.source), false)
            call PauseUnit(this.dummy, false)
            call UnitSetBonus(this.dummy, BONUS_SIGHT_RANGE, R2I(RADIUS))
            call UnitAddAbility(this.dummy, TRUE_SIGHT_ABILITY)
            call this.push(TIMEOUT)
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod

        implement BuffApply
    endstruct


    struct SoulMark extends array

        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local SpellBuff b = SpellBuff.add(caster, GetSpellTargetUnit())
            set b.duration = Duration(GetUnitAbilityLevel(caster, SPELL_ID))
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