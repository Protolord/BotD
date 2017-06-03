scope Bloodthirst

    globals
        private constant integer SPELL_ID = 'A242'
        private constant string LIGHTNING_CODE = "HWPB"
        private constant real LIGHTNING_DURATION = 0.75
    endglobals

    private function HealFixed takes integer level returns real
        if level == 11 then
            return 2000.0
        endif
        return 250.0*level
    endfunction

    private function HealPerUnit takes integer level returns real
        if level == 11 then
            return 1000.0
        endif
        return 50.0*level
    endfunction

    private function Radius takes integer level returns real
        return 800.0 + 0.0*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and IsUnitEnemy(u, p)
    endfunction

    struct Bloodthirst extends array
        implement Alloc

        private unit u

        private static method debuff takes nothing returns nothing
            local thistype this = ReleaseTimer(GetExpiredTimer())
            call UnitRemoveAbility(this.u, 'Bbsk')
            set this.u = null
            call this.deallocate()
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            local unit caster = GetTriggerUnit()
            local integer level = GetUnitAbilityLevel(caster, SPELL_ID)
            local real amount = HealFixed(level)
            local real inc = HealPerUnit(level)
            local group g = NewGroup()
            local real x = GetUnitX(caster)
            local real y = GetUnitY(caster)
            local real z = GetUnitZ(caster)
            local player p = GetTriggerPlayer()
            local Lightning l
            local unit u
            call GroupUnitsInArea(g, x, y, Radius(level))
            loop
                set u = FirstOfGroup(g)
                exitwhen u == null
                call GroupRemoveUnit(g, u)
                if TargetFilter(u, p) then
                    set l = Lightning.createUnits(LIGHTNING_CODE, u, caster)
                    set l.duration = LIGHTNING_DURATION
                    call l.startColor(1.0, 0.0, 0.0, 1.0)
                    call l.endColor(1.0, 0.0, 0.0, 0.0)
                    set amount = amount + inc
                endif
            endloop
            call Heal.unit(caster, caster, amount, 4.0, true)
            set this.u = caster
            call TimerStart(NewTimerEx(this), 0.00, false, function thistype.debuff)
            call ReleaseGroup(g)
            set g = null
            set caster = null
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SystemTest.end()
        endmethod

    endstruct

endscope