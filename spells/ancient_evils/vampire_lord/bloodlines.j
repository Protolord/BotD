scope Bloodlines

    globals
        private constant integer SPELL_ID = 'A142'
        private constant string HEAL_AREA = "Models\\Effects\\Bloodlines.mdx"
        private constant string HEAL_ATTACHED = "Models\\Effects\\BloodHeal.mdx"
    endglobals

    private function HealAmount takes integer level returns real
        if level == 11 then
            return 10000.0
        endif
        return 500.0*level
    endfunction

    private function Radius takes integer level returns real
        return 800.0 + 0.0*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitAlly(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE)
    endfunction

    struct Bloodlines extends array
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
            local player p = GetTriggerPlayer()
            local integer level = GetUnitAbilityLevel(caster, SPELL_ID)
            local real amount = HealAmount(level)
            local real x = GetUnitX(caster)
            local real y = GetUnitY(caster)
            local group g = NewGroup()
            local unit u = GetRecycledDummyAnyAngle(x, y, 50)
            set this.u = caster
            call SetUnitScale(u, Radius(level)/700, 0, 0)
            call DestroyEffect(AddSpecialEffectTarget(HEAL_AREA, u, "origin"))
            call DummyAddRecycleTimer(u, 5.0)
            call GroupUnitsInArea(g, x, y, Radius(level))
            loop
                set u = FirstOfGroup(g)
                exitwhen u == null
                call GroupRemoveUnit(g, u)
                if TargetFilter(u, p) then
                    call Heal.unit(caster, u, amount, 4.0, true)
                    call DestroyEffect(AddSpecialEffectTarget(HEAL_ATTACHED, u, "chest"))
                endif
            endloop
            call ReleaseGroup(g)
            call TimerStart(NewTimerEx(this), 0.00, false, function thistype.debuff)
            set g = null
            set caster = null
            set p = null
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SystemTest.end()
        endmethod

    endstruct

endscope