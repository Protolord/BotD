scope UnholyAura

    globals
        private constant integer SPELL_ID = 'A714'
        private constant real TIMEOUT = 1.0
        private constant real MIN_RANGE = 150 //Range that will deal max damage
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
        private constant string SFX = "Abilities\\Weapons\\AvengerMissile\\AvengerMissile.mdl"
    endglobals

    //When unit is at this range, the damage is minimum
    //Units farther than this range takes no dmg
    private function Range takes integer level returns real
        return 0.0*level + 750.0
    endfunction

    //In percent
    private function HealthPercentDamage_Max takes integer level returns real
        if level == 11 then
            return 10.0
        endif
        return 0.5*level
    endfunction

    //In percent
    private function HealthPercentDamage_Min takes integer level returns real
        if level == 11 then
            return 2.0
        endif
        return 0.1*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction

    struct UnholyAura extends array
        implement Alloc

        private unit caster
        private trigger manaTrg
        private real range
        private real maxDmg
        private real minDmg
        private real m
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
            local player p = GetOwningPlayer(this.caster)
            local real x = GetUnitX(this.caster)
            local real y = GetUnitY(this.caster)
            local real dx
            local real dy
            local real d
            local real dmg
            local unit u
            call GroupEnumUnitsInRange(thistype.g, x, y, this.range, null)
            loop
                set u = FirstOfGroup(thistype.g)
                exitwhen u == null
                call GroupRemoveUnit(thistype.g, u)
                if TargetFilter(u, p) then
                    set dx = x - GetUnitX(u)
                    set dy = y - GetUnitY(u)
                    set d = SquareRoot(dx*dx + dy*dy)
                    if d <= MIN_RANGE then
                        set dmg = this.maxDmg
                    else
                        set dmg = this.maxDmg - this.m*(d - MIN_RANGE)
                    endif
                    call Damage.element.apply(this.caster, u, 0.01*dmg*GetWidgetLife(u), ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_SPIRIT)
                    call DestroyEffect(AddSpecialEffectTarget(SFX, u, "chest"))
                endif
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
            set this.maxDmg = HealthPercentDamage_Max(lvl)
            set this.minDmg = HealthPercentDamage_Min(lvl)
            set this.m = (this.maxDmg - this.minDmg)/(this.range - MIN_RANGE)
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