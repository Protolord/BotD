scope Blocking

    globals
        private constant integer SPELL_ID = 'AHD3'
        private constant string SFX = "Abilities\\Spells\\Human\\Defend\\DefendCaster.mdl"
    endglobals

    //In percent
    private function DamageReduction takes integer level returns real
        return 30.0 + 5.0*level
    endfunction

    private function AttackSlow takes integer level returns real
        return 1.0 - 0.1*level
    endfunction

    private function MoveSlow takes integer level returns real
        return 1.0 - 0.1*level
    endfunction

    struct Blocking extends array
        implement Alloc

        private unit caster
        private trigger manaTrg
        private Movespeed ms
        private Atkspeed as

        private static trigger trg
        private static Table tb

        private method destroy takes nothing returns nothing
            call this.ms.destroy()
            call this.as.destroy()
            call DestroyTrigger(this.manaTrg)
            call thistype.tb.remove(GetHandleId(this.caster))
            call thistype.tb.remove(GetHandleId(this.manaTrg))
            set this.caster = null
            set this.manaTrg = null
            call this.deallocate()
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

        private static method onDamage takes nothing returns nothing
            local integer lvl = GetUnitAbilityLevel(Damage.target, SPELL_ID)
            local Effect e
            local real tx
            local real ty
            if Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.coded and lvl > 0 and CombatStat.getAttackType(Damage.source) != ATTACK_TYPE_MAGIC and thistype.tb.has(GetHandleId(Damage.target)) and CombatStat.isMelee(Damage.source) then
                set Damage.amount = 0.01*(100 - DamageReduction(lvl))*Damage.amount
                set tx = GetUnitX(Damage.target)
                set ty = GetUnitY(Damage.target)
                set e = Effect.create(SFX, tx, ty, GetUnitFlyHeight(Damage.target) + 30, bj_RADTODEG*Atan2(GetUnitY(Damage.source) - ty, GetUnitX(Damage.source) - tx))
                set e.scale = 1.5
                set e.duration = 0.5
            endif
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            local integer lvl
            set this.caster = GetTriggerUnit()
            set lvl = GetUnitAbilityLevel(this.caster, SPELL_ID)
            set this.as = Atkspeed.create(this.caster, -AttackSlow(lvl))
            set this.ms = Movespeed.create(this.caster, -MoveSlow(lvl), 0)
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
            call Damage.registerModifier(function thistype.onDamage)
            call TriggerAddCondition(thistype.trg, function thistype.unCast)
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call thistype.add(PlayerStat.initializer.unit)
            call SystemTest.end()
        endmethod

    endstruct

endscope