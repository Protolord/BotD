scope Zeal

    globals
        private constant integer SPELL_ID = 'AHC3'
        private constant integer TRANSFORM_ID = 'THC3'
    endglobals

    private function NumberOfAttacks takes integer level returns integer
        return level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p)
    endfunction

    private struct SpellBuff extends Buff

        private Atkspeed as
        private Transform tr

        private static constant integer RAWCODE = 'BHC3'
        private static constant integer DISPEL_TYPE = BUFF_POSITIVE
        private static constant integer STACK_TYPE = BUFF_STACK_NONE

        method onRemove takes nothing returns nothing
            call this.tr.destroy()
            call this.as.destroy()
        endmethod

        method onApply takes nothing returns nothing
            set this.tr = Transform.create(this.target, TRANSFORM_ID)
            set this.as = Atkspeed.create(this.target, 0xFFFF)
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod

        implement BuffApply
    endstruct

    struct Zeal extends array
        implement Alloc

        private unit target
        private integer count
        private trigger trg
        private trigger orderTrg
        private SpellBuff b

        private static Table tb

        private method destroy takes nothing returns nothing
            call thistype.tb.remove(GetHandleId(this.target))
            call thistype.tb.remove(GetHandleId(this.trg))
            call thistype.tb.remove(GetHandleId(this.orderTrg))
            call Damage.unregisterTrigger(this.trg)
            call this.b.remove()
            call DestroyTrigger(this.trg)
            call DestroyTrigger(this.orderTrg)
            set this.target = null
            set this.trg = null
            set this.orderTrg = null
            call this.deallocate()
        endmethod

        private static method expires takes nothing returns nothing
            call thistype(ReleaseTimer(GetExpiredTimer())).destroy()
        endmethod

        private static method onDamage takes nothing returns boolean
            local thistype this = thistype.tb[GetHandleId(GetTriggeringTrigger())]
            if this > 0 and Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.coded and Damage.source == this.b.source then
                set this.count = this.count - 1
                if this.count <= 0 then
                    call this.destroy()
                endif
            endif
            return false
        endmethod

        private static method onOrder takes nothing returns boolean
            call thistype(thistype.tb[GetHandleId(GetTriggeringTrigger())]).destroy()
            return false
        endmethod

        private static method onDeath takes nothing returns nothing
            local integer id = GetHandleId(GetTriggerUnit())
            if thistype.tb.has(id) then
                call thistype(thistype.tb[id]).destroy()
            endif
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            local unit caster = GetTriggerUnit()
            local integer lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            set this.target = GetSpellTargetUnit()
            set this.count = NumberOfAttacks(lvl)
            set this.b = SpellBuff.add(caster, caster)
            set this.trg = CreateTrigger()
            call Damage.registerTrigger(this.trg)
            call TriggerAddCondition(this.trg, function thistype.onDamage)
            call IssueTargetOrderById(caster, ORDER_attack, this.target)
            set this.orderTrg = CreateTrigger()
            call TriggerRegisterUnitEvent(this.orderTrg, caster, EVENT_UNIT_ISSUED_POINT_ORDER)
            call TriggerRegisterUnitEvent(this.orderTrg, caster, EVENT_UNIT_ISSUED_TARGET_ORDER)
            call TriggerRegisterUnitEvent(this.orderTrg, caster, EVENT_UNIT_ISSUED_ORDER)
            call TriggerAddCondition(this.orderTrg, function thistype.onOrder)
            set thistype.tb[GetHandleId(this.trg)] = this
            set thistype.tb[GetHandleId(this.orderTrg)] = this
            set thistype.tb[GetHandleId(this.target)] = this
            set caster = null
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
            set thistype.tb = Table.create()
            call SpellBuff.initialize()
            call SystemTest.end()
        endmethod

    endstruct

endscope