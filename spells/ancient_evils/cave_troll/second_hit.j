scope SecondHit

    globals
        private constant integer SPELL_ID = 'A813'
    endglobals

    private function DamagePercentage takes integer level returns real
        if level == 11 then
            return 50.0
        endif
        return 5.0*level
    endfunction

    //In percent
    private function Chance takes integer level returns real
        if level == 11 then
            return 30.0
        endif
        return 100.0//15.0
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p)
    endfunction

    private struct SpellBuff extends Buff

        private Atkspeed as

        private static constant integer RAWCODE = 'B813'
        private static constant integer DISPEL_TYPE = BUFF_POSITIVE
        private static constant integer STACK_TYPE = BUFF_STACK_NONE

        private static method delay takes nothing returns nothing
            local thistype this = ReleaseTimer(GetExpiredTimer())
            call AddUnitAnimationProperties(this.target, "alternate", true)
        endmethod

        method onRemove takes nothing returns nothing
            call AddUnitAnimationProperties(this.target, "alternate", false)
            call this.as.destroy()
        endmethod

        method onApply takes nothing returns nothing
            set this.as = Atkspeed.create(this.target, 0xFFFF)
            call TimerStart(NewTimerEx(this), 0.25, false, function thistype.delay)
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod

        implement BuffApply
    endstruct

    struct SecondHit extends array
        implement Alloc

        private real dmg
        private unit target
        private trigger trg
        private trigger orderTrg
        private SpellBuff buff

        private static Table tb

        private static method delay takes nothing returns nothing
            local thistype this = ReleaseTimer(GetExpiredTimer())
            call this.buff.remove()
            call this.deallocate()
        endmethod

        private method destroy takes nothing returns nothing
            call thistype.tb.remove(GetHandleId(this.trg))
            call thistype.tb.remove(GetHandleId(this.orderTrg))
            call thistype.tb.boolean.remove(GetHandleId(this.buff.source))
            call Damage.unregisterModifierTrigger(this.trg)
            call DestroyTrigger(this.trg)
            call DestroyTrigger(this.orderTrg)
            set this.target = null
            set this.trg = null
            set this.orderTrg = null
            call TimerStart(NewTimerEx(this), 0.2, false, function thistype.delay)
        endmethod

        private static method expires takes nothing returns nothing
            call thistype(ReleaseTimer(GetExpiredTimer())).destroy()
        endmethod

        private static method onSecondDamage takes nothing returns boolean
            local thistype this = thistype.tb[GetHandleId(GetTriggeringTrigger())]
            local textsplat t
            if this > 0 and Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.coded and Damage.source == this.buff.source then
                if Damage.target == this.target then
                    set Damage.amount = this.dmg
                    call Damage.lockAmount()
                    if Damage.amount >= 1.0 then
                        set t = FloatingTextSplat(Element.string(DAMAGE_ELEMENT_NORMAL) + I2S(R2I(Damage.amount)) + "|r", Damage.target, 2.0)
                        call t.setVisible(GetLocalPlayer() == GetOwningPlayer(Damage.source))
                    endif
                    call TimerStart(NewTimerEx(this), 0.0, false, function thistype.expires)
                else
                    call this.destroy()
                endif
            endif
            return false
        endmethod

        private static method onOrder takes nothing returns boolean
            call thistype(thistype.tb[GetHandleId(GetTriggeringTrigger())]).destroy()
            return false
        endmethod

        private static method onDamage takes nothing returns nothing
            local integer level = GetUnitAbilityLevel(Damage.source, SPELL_ID)
            local thistype this
            if level > 0 and Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.coded and TargetFilter(Damage.target, GetOwningPlayer(Damage.source)) and GetWidgetLife(Damage.target) > Damage.amount then
                if GetRandomReal(0, 100) <= Chance(level) and not thistype.tb.boolean.has(GetHandleId(Damage.source)) then
                    set this = thistype.allocate()
                    set this.target = Damage.target
                    set this.dmg = Damage.amount*DamagePercentage(level)/100
                    set this.buff = SpellBuff.add(Damage.source, Damage.source)
                    set this.trg = CreateTrigger()
                    call Damage.registerModifierTrigger(this.trg)
                    call TriggerAddCondition(this.trg, function thistype.onSecondDamage)
                    set thistype.tb[GetHandleId(this.trg)] = this
                    call IssueTargetOrderById(Damage.source, ORDER_attack, Damage.target)
                    set this.orderTrg = CreateTrigger()
                    call TriggerRegisterUnitEvent(this.orderTrg, Damage.source, EVENT_UNIT_ISSUED_POINT_ORDER)
                    call TriggerRegisterUnitEvent(this.orderTrg, Damage.source, EVENT_UNIT_ISSUED_TARGET_ORDER)
                    call TriggerRegisterUnitEvent(this.orderTrg, Damage.source, EVENT_UNIT_ISSUED_ORDER)
                    call TriggerAddCondition(this.orderTrg, function thistype.onOrder)
                    set thistype.tb[GetHandleId(this.orderTrg)] = this
                    set thistype.tb.boolean[GetHandleId(Damage.source)] = true
                endif
            endif
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call Damage.register(function thistype.onDamage)
            set thistype.tb = Table.create()
            call SpellBuff.initialize()
            call SystemTest.end()
        endmethod

    endstruct

endscope