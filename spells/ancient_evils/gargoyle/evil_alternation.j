scope EvilAlternation

    globals
        private constant integer SPELL_ID = 'A643'
    endglobals

    private function DamageFactor takes integer level returns real
        if level == 11 then
            return 2.0
        endif
        return 0.75 + 0.05*level
    endfunction

    struct EvilAlternation extends array
        implement Alloc

        private unit caster
        private real absorbed
        private integer lvl
        private trigger manaTrg

        private static trigger trg
        private static Table tb

        private method destroy takes nothing returns nothing
            call DestroyTrigger(this.manaTrg)
            call Heal.unit(this.caster, this.caster, this.absorbed, 1.0, true)
            call thistype.tb.remove(GetHandleId(this.caster))
            call thistype.tb.remove(GetHandleId(this.manaTrg))
            set this.caster = null
            set this.manaTrg = null
            call this.deallocate()
        endmethod

        private static method onDamage takes nothing returns nothing
            local integer lvl = GetUnitAbilityLevel(Damage.target, SPELL_ID)
            local integer id = GetHandleId(Damage.target)
            local thistype this
            if lvl > 0 and thistype.tb.has(id) then
                set this = thistype.tb[id]
                set this.absorbed = this.absorbed + Damage.amount*DamageFactor(this.lvl)
            endif
        endmethod

        private static method onManaDeplete takes nothing returns boolean
            local integer id = GetHandleId(GetTriggeringTrigger())
            if thistype.tb.has(id) then
                call thistype(thistype.tb[id]).destroy()
                call SetUnitState(GetTriggerUnit(), UNIT_STATE_MANA, 0.0)
                call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " deactivates thistype")
            endif
            return false
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            set this.caster = GetTriggerUnit()
            set this.absorbed = 0
            set this.lvl = GetUnitAbilityLevel(this.caster, SPELL_ID)
            set this.manaTrg = CreateTrigger()
            call TriggerAddCondition(this.manaTrg, function thistype.onManaDeplete)
            call TriggerRegisterUnitStateEvent(this.manaTrg, this.caster, UNIT_STATE_MANA, LESS_THAN, 1.0)
            set thistype.tb[GetHandleId(this.caster)] = this
            set thistype.tb[GetHandleId(this.manaTrg)] = this
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " activates thistype")
        endmethod

        private static method unCast takes nothing returns boolean
            local integer id = GetHandleId(GetTriggerUnit())
            if GetIssuedOrderId() == ORDER_unimmolation and thistype.tb.has(id) then
                call thistype(thistype.tb[id]).destroy()
                call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " deactivates thistype")
            endif
            return false
        endmethod

        private static method add takes unit u returns nothing
            call TriggerRegisterUnitEvent(thistype.trg, u, EVENT_UNIT_ISSUED_ORDER)
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            set thistype.trg = CreateTrigger()
            set thistype.tb = Table.create()
            call TriggerAddCondition(thistype.trg, function thistype.unCast)
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call thistype.add(PlayerStat.initializer.unit)
            call Damage.register(function thistype.onDamage)
            call SystemTest.end()
        endmethod

    endstruct

endscope