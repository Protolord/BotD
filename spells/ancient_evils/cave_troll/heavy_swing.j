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

    struct HeavySwing extends array

        private static trigger trg
        private static Table tb

        static method get takes unit u returns real
            local integer id = GetHandleId(u)
            local integer level = GetUnitAbilityLevel(u, SPELL_ID)
            if level > 0 and thistype.tb[id] > 0 then
                return 1.0 + ExtraDamage(level)/100.0
            endif
            return 1.0
        endmethod
        
        private static method onDamage takes nothing returns boolean
            local integer level = GetUnitAbilityLevel(Damage.source, SPELL_ID)
            local real dmg
            if level > 0 and Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.coded and thistype.tb[GetHandleId(Damage.source)] > 0 and GetUnitState(Damage.source, UNIT_STATE_MANA) >= Manacost(level) then
                set dmg = DamageStat.get(Damage.source)*ExtraDamage(level)/100.0
                call DisableTrigger(thistype.trg)
                call Stun.create(Damage.target, StunDuration(level), false)
                set Damage.amount = (1.0 + ExtraDamage(level)/100.0)*Damage.amount
                call EnableTrigger(thistype.trg)
                call FloatingTextSplat(Element.string(DAMAGE_ELEMENT_NORMAL) + "+" + I2S(R2I(dmg + 0.5)) + "|r", Damage.target, 1.0).setVisible(GetLocalPlayer() == GetOwningPlayer(Damage.source))
            endif
            return false
        endmethod

        private static method delay takes nothing returns nothing
            local integer id = ReleaseTimer(GetExpiredTimer())
            set thistype.tb[id] = thistype.tb[id] - 1
        endmethod

        private static method onCast takes nothing returns nothing
            local integer id = GetHandleId(GetTriggerUnit())
            set thistype.tb[id] = thistype.tb[id] + 1
            call TimerStart(NewTimerEx(id), 0.01, false, function thistype.delay) //Because of missile delay
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod

        private static method onOrder takes nothing returns boolean
            local integer order = GetIssuedOrderId()
            local integer id = GetHandleId(GetTriggerUnit())
            local thistype this
            if order == ORDER_flamingarrows then
                set thistype.tb[id] = thistype.tb[id] + 1
            elseif order == ORDER_unflamingarrows then
                set thistype.tb[id] = thistype.tb[id] - 1
            endif
            return false
        endmethod

        static method register takes unit u returns nothing
            local trigger orderTrg = CreateTrigger()
			call TriggerRegisterUnitEvent(orderTrg, u, EVENT_UNIT_ISSUED_ORDER)
            call TriggerAddCondition(orderTrg, function thistype.onOrder)
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            set thistype.tb = Table.create()
            set thistype.trg = CreateTrigger()
            call Damage.registerModifierTrigger(thistype.trg)
            call TriggerAddCondition(thistype.trg, function thistype.onDamage)
            call thistype.register(PlayerStat.initializer.unit)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope