scope Fear

    globals
        private constant integer SPELL_ID = 'A724'
        private constant real TIMEOUT = 0.125
        private constant real ANGLE_TOLERANCE = 30.0 //In degrees
    endglobals

    private function Range takes integer level returns real
        return 0.0*level + 500.0
    endfunction

    //In Percent
    private function DamageReduction takes integer level returns real
        if level == 11 then
            return 50.0
        endif
        return 3.0*level
    endfunction

    private function ManacostPerSecond takes integer level returns real
        return 10.0 + 0.0*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction

    private struct SpellBuff extends Buff

        private AtkDamagePercent adp

        private static constant integer RAWCODE = 'D724'
        private static constant integer DISPEL_TYPE = BUFF_NEGATIVE
        private static constant integer STACK_TYPE = BUFF_STACK_NONE

        method onRemove takes nothing returns nothing
            call this.adp.destroy()
        endmethod

        method onApply takes nothing returns nothing
            set this.adp = AtkDamagePercent.create(this.target, -DamageReduction(GetUnitAbilityLevel(this.source, SPELL_ID))/100)
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod

        implement BuffApply
    endstruct

    struct Fear extends array
        implement Alloc
        implement List

        private unit caster
        private trigger manaTrg
        private real range
        private real mc
        private group affected

        private static trigger trg
        private static Table tb
        private static thistype global
        private static group g
        private static real tempX
        private static real tempY

        private method destroy takes nothing returns nothing
            local unit u
            call this.pop()
            loop
                set u = FirstOfGroup(this.affected)
                exitwhen u == null
                call GroupRemoveUnit(this.affected, u)
                call Buff.get(this.caster, u, SpellBuff.typeid).remove()
            endloop
            call DestroyTrigger(this.manaTrg)
            call ReleaseGroup(this.affected)
            call thistype.tb.remove(GetHandleId(this.caster))
            call thistype.tb.remove(GetHandleId(this.manaTrg))
            set this.caster = null
            set this.manaTrg = null
            set this.affected = null
            call this.deallocate()
        endmethod

        private static method picked takes nothing returns nothing
            local thistype this = thistype.global
            local unit u = GetEnumUnit()
            local SpellBuff b = Buff.get(this.caster, u, SpellBuff.typeid)
            local real angle
            if b > 0  then
                set angle = Atan2(GetUnitY(u) - thistype.tempY, GetUnitX(u) - thistype.tempX)*bj_RADTODEG
                if angle < 0 then
                    set angle = angle + 360
                endif
                if RAbsBJ(GetUnitFacing(u) - angle) > ANGLE_TOLERANCE then
                    call b.remove()
                    call GroupRemoveUnit(this.affected, u)
                endif
            endif
            set u = null
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this = thistype(0).next
            local player p
            local real angle
            local unit u
            loop
                exitwhen this == 0
                set thistype.tempX = GetUnitX(this.caster)
                set thistype.tempY = GetUnitY(this.caster)
                set thistype.global = this
                call ForGroup(this.affected, function thistype.picked)
                if UnitAlive(this.caster) then
                    call GroupEnumUnitsInRange(thistype.g, thistype.tempX, thistype.tempY, this.range, null)
                    set p = GetOwningPlayer(this.caster)
                    loop
                        set u = FirstOfGroup(thistype.g)
                        exitwhen u == null
                        call GroupRemoveUnit(thistype.g, u)
                        if TargetFilter(u, p) and not Buff.has(this.caster, u, SpellBuff.typeid) and IsUnitVisible(this.caster, GetOwningPlayer(u)) then
                            set angle = Atan2(thistype.tempY - GetUnitY(u), thistype.tempX - GetUnitX(u))*bj_RADTODEG
                            if angle < 0 then
                                set angle = angle + 360
                            endif
                            if RAbsBJ(GetUnitFacing(u) - angle) <= ANGLE_TOLERANCE then
                                call SpellBuff.add(this.caster, u)
                                call GroupAddUnit(this.affected, u)
                            endif
                        endif
                    endloop
                endif
                call SetUnitState(this.caster, UNIT_STATE_MANA, GetUnitState(this.caster, UNIT_STATE_MANA) - this.mc)
                set this = this.next
            endloop
            set p = null
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
            set lvl = GetUnitAbilityLevel(this.caster, SPELL_ID)
            set this.range = Range(lvl)
            set this.affected = NewGroup()
            set this.mc = ManacostPerSecond(lvl)*TIMEOUT
            set this.manaTrg = CreateTrigger()
            call TriggerAddCondition(this.manaTrg, function thistype.onManaDeplete)
            call TriggerRegisterUnitStateEvent(this.manaTrg, this.caster, UNIT_STATE_MANA, LESS_THAN, 1.0)
            set thistype.tb[GetHandleId(this.caster)] = this
            set thistype.tb[GetHandleId(this.manaTrg)] = this
            call this.push(TIMEOUT)
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " activates thistype")
        endmethod

        private static method unCast takes nothing returns boolean
            local integer id = GetHandleId(GetTriggerUnit())
            if GetIssuedOrderId() == ORDER_manashieldoff and thistype.tb.has(id) then
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
            call SpellBuff.initialize()
            call SystemTest.end()
        endmethod

    endstruct

endscope