scope Sacrifice

    globals
        private constant integer SPELL_ID = 'AHJ3'
        private constant string SFX_SOURCE = "Objects\\Spawnmodels\\Critters\\Albatross\\CritterBloodAlbatross.mdl"
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
    endglobals

    private function BonusDamage takes integer level returns real
        return 30.0*level
    endfunction

    private function Healthcost takes integer level returns real
        return 15.0*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and IsUnitType(u, UNIT_TYPE_HERO)
    endfunction

    struct Sacrifice extends array
        implement Alloc

        private integer run

        private static trigger trg
        private static Table tb

        private static method onDamage takes nothing returns boolean
            local integer level = GetUnitAbilityLevel(Damage.source, SPELL_ID)
            local thistype this
            local real hp
            local real hc
            local real bd
            local player p
            if level > 0 and Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.coded then
                set this = thistype.tb[GetHandleId(Damage.source)]
                if this > 0 and this.run > 0 then
                    set p = GetOwningPlayer(Damage.source)
                    if TargetFilter(Damage.target, p) then
                        set hp = GetWidgetLife(Damage.source)
                        set hc = Healthcost(level)
                        set bd = BonusDamage(level)
                        call DisableTrigger(thistype.trg)
                        call Damage.apply(Damage.source, Damage.target, bd, ATTACK_TYPE, DAMAGE_TYPE)
                        call FloatingTextSplat(Element.string(DAMAGE_ELEMENT_NORMAL) + "+" + I2S(R2I(bd + 0.5)) + "|r", Damage.target).setVisible(GetLocalPlayer() == GetOwningPlayer(Damage.source))
                        if hp > hc then
                            call SetWidgetLife(Damage.source, hp - hc)
                        else
                            call Damage.kill(Damage.source, Damage.source)
                        endif
                        call EnableTrigger(thistype.trg)
                        call DestroyEffect(AddSpecialEffectTarget(SFX_SOURCE, Damage.source, "chest"))
                    endif
                    set p = null
                endif
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

        static method register takes unit u returns nothing
            local thistype this = thistype.allocate()
            local trigger orderTrg = CreateTrigger()
            set this.run = 0
            call TriggerRegisterUnitEvent(orderTrg, u, EVENT_UNIT_ISSUED_ORDER)
            call TriggerAddCondition(orderTrg, function thistype.onOrder)
            set thistype.tb[GetHandleId(u)] = this
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