scope UnstoppableHunger

    globals
        private constant integer SPELL_ID = 'A144'
        private constant real HEAL_DELAY = 0.10
        private constant string HEAL_EFFECT = "Models\\Effects\\BloodHeal.mdx"
    endglobals

    //Fixed healing per level
    private function HealConstant takes integer level returns real
        return 0.0 + 0.0*level
    endfunction

    //Heal will be equal to DamageTaken*HealFactor
    private function HealFactor takes integer level returns real
        if level == 11 then
            return 50.0
        endif
        return 2.5*level
    endfunction

    private function Chance takes integer level returns real
        return 100.0//3.0 + 0.0*level
    endfunction

    struct UnstoppableHunger extends array
        implement Alloc

        private real heal
        private unit u

        private static method expires takes nothing returns nothing
            local thistype this = ReleaseTimer(GetExpiredTimer())
            if UnitAlive(this.u) then
                call Heal.unit(this.u, this.u, this.heal, 1.0, true)
                call DestroyEffect(AddSpecialEffectTarget(HEAL_EFFECT, u, "chest"))
            endif
            set this.u = null
            call this.deallocate()
        endmethod

        private static method onDamage takes nothing returns nothing
            local integer level = GetUnitAbilityLevel(Damage.target, SPELL_ID)
            local thistype this
            if level > 0 and Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.coded and CombatStat.getAttackType(Damage.source) != ATTACK_TYPE_MAGIC then
                if GetRandomReal(0, 100) <= Chance(level) then
                    set this = thistype.allocate()
                    set this.heal = HealFactor(level)*Damage.amount + HealConstant(level)
                    set this.u = Damage.target
                    call TimerStart(NewTimerEx(this), HEAL_DELAY, false, function thistype.expires)
                    call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " procs thistype")
                endif
            endif
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call Damage.register(function thistype.onDamage)
            call SystemTest.end()
        endmethod

    endstruct

endscope