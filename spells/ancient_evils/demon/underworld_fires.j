scope UnderworldFires

    globals
        private constant integer SPELL_ID = 'A524'
        private constant real TIMEOUT = 0.125
        private constant string SFX_TARGET = "Abilities\\Spells\\Other\\ImmolationRed\\ImmolationRedDamage.mdl"
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
    endglobals

    private function DamagePerSecond takes integer level returns real
        if level == 11 then
            return 600.0
        endif
        return 30.0*level
    endfunction

    private function Radius takes integer level returns real
        return 160.0 + 0.0*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction

    struct UnderworldFires extends array
        implement Alloc

        private unit caster
        private player owner
        private real dmg
        private real radius
        private trigger manaTrg
        private timer t

        private static trigger trg
        private static Table tb
        private static group g

        private method destroy takes nothing returns nothing
            call DestroyTrigger(this.manaTrg)
            call ReleaseTimer(this.t)
            call thistype.tb.remove(GetHandleId(this.caster))
            call thistype.tb.remove(GetHandleId(this.manaTrg))
            set this.t = null
            set this.caster = null
            set this.manaTrg = null
            call this.deallocate()
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            local unit u
            call FloatingText.setSplatProperties(TIMEOUT)
            call GroupEnumUnitsInRange(thistype.g, GetUnitX(this.caster), GetUnitY(this.caster), this.radius, null)
            loop
                set u = FirstOfGroup(thistype.g)
                exitwhen u == null
                call GroupRemoveUnit(thistype.g, u)
                if TargetFilter(u, this.owner) then
                    call AddSpecialEffectTimer(AddSpecialEffectTarget(SFX_TARGET, u, "head"), TIMEOUT)
                    call Damage.element.apply(this.caster, u, this.dmg, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_FIRE)
                endif
            endloop
            call FloatingText.resetSplatProperties()
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
            local integer lvl
            set this.caster = GetTriggerUnit()
            set this.owner = GetTriggerPlayer()
            set lvl = GetUnitAbilityLevel(this.caster, SPELL_ID)
            set this.radius = Radius(lvl)
            set this.dmg = DamagePerSecond(lvl)*TIMEOUT
            set this.manaTrg = CreateTrigger()
            call TriggerAddCondition(this.manaTrg, function thistype.onManaDeplete)
            call TriggerRegisterUnitStateEvent(this.manaTrg, this.caster, UNIT_STATE_MANA, LESS_THAN, 1.0)
            set thistype.tb[GetHandleId(this.caster)] = this
            set thistype.tb[GetHandleId(this.manaTrg)] = this
            set this.t = NewTimerEx(this)
            call TimerStart(this.t, TIMEOUT, true, function thistype.onPeriod)
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
            set thistype.g = CreateGroup()
            call TriggerAddCondition(thistype.trg, function thistype.unCast)
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call thistype.add(PlayerStat.initializer.unit)
            call SystemTest.end()
        endmethod

    endstruct

endscope