scope EngulfedFires

    globals
        private constant integer SPELL_ID = 'A544'
        private constant integer SET_MAX_LIFE = 'ASML'
    endglobals

    private function Duration takes integer level returns real
        if level == 11 then
            return 20.0
        endif
        return 0.5*level + 5.0
    endfunction

    private struct SpellBuff extends Buff

        private real hp
        private trigger trg
        private trigger dmgTrg

        private static Table tb

        private static constant integer RAWCODE = 'B544'
        private static constant integer DISPEL_TYPE = BUFF_POSITIVE
        private static constant integer STACK_TYPE = BUFF_STACK_NONE

        method onRemove takes nothing returns nothing
            call thistype.tb.remove(GetHandleId(this.dmgTrg))
            call thistype.tb.remove(GetHandleId(this.trg))
            call DestroyTrigger(this.dmgTrg)
            call DestroyTrigger(this.trg)
            set this.dmgTrg = null
            set this.trg = null
        endmethod

        private static method onChange takes nothing returns boolean
            local thistype this = thistype.tb[GetHandleId(GetTriggeringTrigger())]
            call SetWidgetLife(this.target, this.hp)
            return false
        endmethod

        private static method enable takes nothing returns nothing
            local thistype this = ReleaseTimer(GetExpiredTimer())
            call EnableTrigger(this.trg)
        endmethod

        private static method onDamage takes nothing returns boolean
            local thistype this = thistype.tb[GetHandleId(GetTriggeringTrigger())]
            set Damage.amount = 0
            call DisableTrigger(this.trg)
            call TimerStart(NewTimerEx(this), 0.0, false, function thistype.enable)
            return false
        endmethod

        method onApply takes nothing returns nothing
            set this.hp = RMinBJ(I2R(R2I(GetWidgetLife(this.target))) + 0.5, GetUnitState(this.target, UNIT_STATE_MAX_LIFE))
            set this.dmgTrg = CreateTrigger()
            set this.trg = CreateTrigger()
            call Damage.registerModifierTrigger(this.dmgTrg)
            call TriggerAddCondition(this.dmgTrg, function thistype.onDamage)
            call TriggerRegisterUnitStateEvent(this.trg, this.target, UNIT_STATE_LIFE, LESS_THAN, this.hp - 0.1 )
            call TriggerRegisterUnitStateEvent(this.trg, this.target, UNIT_STATE_LIFE, GREATER_THAN, this.hp + 0.1)
            call TriggerAddCondition(this.trg, function thistype.onChange)
            call SetWidgetLife(this.target, this.hp)
            set thistype.tb[GetHandleId(this.dmgTrg)] = this
            set thistype.tb[GetHandleId(this.trg)] = this
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
            set thistype.tb = Table.create()
        endmethod

        implement BuffApply
    endstruct

    struct EngulfedFires extends array
        implement Alloc

        private unit u

        private static method expires takes nothing returns nothing
            local thistype this = ReleaseTimer(GetExpiredTimer())
            call UnitRemoveAbility(this.u, 'Bbsk')
            set this.u = null
            call this.deallocate()
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            local unit caster = GetTriggerUnit()
            local integer lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            local SpellBuff b = SpellBuff.add(caster, caster)
            set b.duration = Duration(lvl)
            set this.u = caster
            call TimerStart(NewTimerEx(this), 0.00, false, function thistype.expires)
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