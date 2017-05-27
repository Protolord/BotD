scope SilencingPain

    globals
        private constant integer SPELL_ID = 'AHA4'
        private constant string SFX_DAMAGE = "Models\\Effects\\SilencingPainDamage.mdx"
        private constant string SFX_APPEAR = "Models\\Effects\\SilencingPainAppear.mdx"
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
    endglobals

    private function Duration takes integer level returns real
        return 10.0*level
    endfunction

    //In Percent
    private function DamagerPerManacost takes integer level returns real
        return 100.0 + 0.0*level
    endfunction

    //In Percent
    private function DamagePerManacostInc takes integer level returns real
        return 100.0 + 0.0*level
    endfunction

    private struct SpellBuff extends Buff

        private trigger trg
        private real manaBefore
        private real startDuration
        private real dmg
        private real dmgInc

        private static Table tb

        private static constant integer RAWCODE = 'DHA4'
        private static constant integer DISPEL_TYPE = BUFF_NEGATIVE
        private static constant integer STACK_TYPE = BUFF_STACK_PARTIAL

        method onRemove takes nothing returns nothing
            call thistype.tb.remove(GetHandleId(this.trg))
            call DestroyTrigger(this.trg)
            set this.trg = null
        endmethod

        private static method onManaReduce takes nothing returns nothing
            local thistype this = ReleaseTimer(GetExpiredTimer())
            local real manacost = this.manaBefore - GetUnitState(this.target, UNIT_STATE_MANA)
            if manacost > 0 then
                call DestroyEffect(AddSpecialEffect(SFX_DAMAGE, GetUnitX(this.target), GetUnitY(this.target)))
                call Damage.element.apply(this.source, this.target, this.dmg*manacost, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_ARCANE)
                set this.dmg = this.dmg + this.dmgInc
                set this.duration = this.startDuration
            endif
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.tb[GetHandleId(GetTriggeringTrigger())]
            if this > 0 then
                set this.manaBefore = GetUnitState(this.target, UNIT_STATE_MANA)
                call TimerStart(NewTimerEx(this), 0.0, false, function thistype.onManaReduce)
            endif
        endmethod

        method onApply takes nothing returns nothing
            set this.trg = CreateTrigger()
            call TriggerRegisterUnitEvent(this.trg, this.target, EVENT_UNIT_SPELL_EFFECT)
            call TriggerAddCondition(this.trg, function thistype.onCast)
            set thistype.tb[GetHandleId(this.trg)] = this
        endmethod

        method reapply takes integer level returns nothing
            set this.dmg = 0.01*DamagerPerManacost(level)
            set this.dmgInc = 0.01*DamagePerManacostInc(level)
            set this.startDuration = Duration(level)
            set this.duration = this.startDuration
            call DestroyEffect(AddSpecialEffectTarget(SFX_APPEAR, this.target, "origin"))
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
            set thistype.tb = Table.create()
        endmethod

        implement BuffApply
    endstruct

    struct SilencingPain extends array

        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local SpellBuff b = SpellBuff.add(caster, GetSpellTargetUnit())
            call b.reapply(GetUnitAbilityLevel(caster, SPELL_ID))
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
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