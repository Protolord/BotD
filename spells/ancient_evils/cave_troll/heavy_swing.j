scope HeavySwing

    globals
        private constant integer SPELL_ID = 'A811'
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_SIEGE
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_NORMAL
    endglobals

    //Percentage of Normal damage
    private function ExtraDamage takes integer level returns real
        if level == 11 then
            return 100.0
        endif
        return 50.0 + 0.0*level
    endfunction

    private function StunDuration takes integer level returns real
        if level == 11 then
            return 4.0
        endif
        return 0.2*level
    endfunction

    private function Manacost takes integer level returns real
        if level == 11 then
            return 200.0
        endif
        return 10.0*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE)
    endfunction

    struct HeavySwing extends array
        implement Alloc

        private integer run
        private boolean hasMana
        private trigger manaTrg

        private static Table tb

        static method get takes unit u returns real
            local integer id = GetHandleId(u)
            local integer level = GetUnitAbilityLevel(u, SPELL_ID)
            local thistype this = thistype.tb[id]
            if level > 0 and this.run > 0 and this.hasMana then
                return 1.0 + ExtraDamage(level)/100.0
            endif
            return 1.0
        endmethod

        private static method onDamage takes nothing returns boolean
            local integer level = GetUnitAbilityLevel(Damage.source, SPELL_ID)
            local thistype this = thistype.tb[GetHandleId(Damage.source)]
            local player p
            if this > 0 and level > 0 and Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.coded and this.run > 0 and this.hasMana then
                set p = GetOwningPlayer(Damage.source)
                if TargetFilter(Damage.target, p) then
                    call Stun.create(Damage.target, StunDuration(level), false)
                    set Damage.amount = (1.0 + ExtraDamage(level)/100.0)*Damage.amount
                    call FloatingTextSplat(Element.string(DAMAGE_ELEMENT_NORMAL) + "+" + I2S(R2I((CombatStat.getDamage(Damage.source) + AtkDamage.get(Damage.source))*ExtraDamage(level)/100.0 + 0.5)) + "|r", Damage.target, 1.0).setVisible(GetLocalPlayer() == p)
                endif
                set p = null
            endif
            return false
        endmethod

        private static method castDelay takes nothing returns nothing
            local thistype this = ReleaseTimer(GetExpiredTimer())
            set this.run = this.run - 1
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.tb[GetHandleId(GetTriggerUnit())]
            set this.run = this.run + 1
            call TimerStart(NewTimerEx(this), 0.01, false, function thistype.castDelay) //Because of missile delay
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod

        private static method onOrder takes nothing returns boolean
            local integer order = GetIssuedOrderId()
            local thistype this = thistype.tb[GetHandleId(GetTriggerUnit())]
            if order == ORDER_flamingarrows then
                set this.run = this.run + 1
            elseif order == ORDER_unflamingarrows then
                set this.run = this.run - 1
            endif
            return false
        endmethod

        private static method manaDelay takes nothing returns nothing
            local thistype this = ReleaseTimer(GetExpiredTimer())
            set this.hasMana = not this.hasMana
        endmethod

        private static method onMana takes nothing returns boolean
            local unit u = GetTriggerUnit()
            local thistype this = thistype.tb[GetHandleId(u)]
            call DestroyTrigger(this.manaTrg)
            set this.manaTrg = CreateTrigger()
            if this.hasMana then
                call TriggerRegisterUnitStateEvent(this.manaTrg, u, UNIT_STATE_MANA, GREATER_THAN_OR_EQUAL, Manacost(GetUnitAbilityLevel(u, SPELL_ID)))
            else
                call TriggerRegisterUnitStateEvent(this.manaTrg, u, UNIT_STATE_MANA, LESS_THAN, Manacost(GetUnitAbilityLevel(u, SPELL_ID)))
            endif
            call TriggerAddCondition(this.manaTrg, function thistype.onMana)
            call TimerStart(NewTimerEx(this), 0.01, false, function thistype.manaDelay)
            return false
        endmethod

        private static method onLevel takes nothing returns nothing
            local unit u
            local thistype this
            local integer lvl
            if GetLearnedSkill() == SPELL_ID then
                set u = GetTriggerUnit()
                set this = thistype.tb[GetHandleId(u)]
                set lvl = GetUnitAbilityLevel(u, SPELL_ID)
                if this.manaTrg != null then
                    call DestroyTrigger(this.manaTrg)
                endif
                set this.manaTrg = CreateTrigger()
                if GetUnitState(u, UNIT_STATE_MANA) >= Manacost(lvl) then
                    set this.hasMana = true
                    call TriggerRegisterUnitStateEvent(this.manaTrg, u, UNIT_STATE_MANA, LESS_THAN, Manacost(lvl))
                else
                    set this.hasMana = false
                    call TriggerRegisterUnitStateEvent(this.manaTrg, u, UNIT_STATE_MANA, GREATER_THAN_OR_EQUAL, Manacost(lvl))
                endif
                call TriggerAddCondition(this.manaTrg, function thistype.onMana)
                set u = null
            endif
        endmethod

        static method register takes unit u returns nothing
            local thistype this = thistype.allocate()
            local trigger orderTrg = CreateTrigger()
            set this.run = 0
            set this.manaTrg = null
            call TriggerRegisterUnitEvent(orderTrg, u, EVENT_UNIT_ISSUED_ORDER)
            call TriggerAddCondition(orderTrg, function thistype.onOrder)
            set thistype.tb[GetHandleId(u)] = this
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            set thistype.tb = Table.create()
            call Damage.registerModifier(function thistype.onDamage)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_SKILL, function thistype.onLevel)
            call thistype.register(PlayerStat.initializer.unit)
            call SystemTest.end()
        endmethod

    endstruct

endscope