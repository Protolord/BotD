scope DeadlyLink

    globals
        private constant integer SPELL_ID = 'AHG2'
        private constant string LIGHTNING_CODE = "DLNK"
        private constant real LIGHTNING_DURATION = 1.0
        private constant string SFX = "Abilities\\Spells\\Undead\\DeathPact\\DeathPactTarget.mdl"
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
    endglobals

    private function DamageDealt takes integer level returns real
        if level == 11 then
            return 700.0
        endif
        return 50.0*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction

    struct DeadlyLink extends array

        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local unit target = GetSpellTargetUnit()
            local Lightning l1 = Lightning.createUnits(LIGHTNING_CODE, caster, target)
            local Lightning l2 = Lightning.createUnits(LIGHTNING_CODE, caster, target)
            local integer lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            call Damage.element.apply(caster, target, DamageDealt(lvl), ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_DARK)
            call IssueImmediateOrderById(target, ORDER_stop)
            call DestroyEffect(AddSpecialEffectTarget(SFX, target, "origin"))
            set l1.duration = LIGHTNING_DURATION
            call l1.startColor(1.0, 1.0, 1.0, 1.0)
            call l1.endColor(1.0, 1.0, 1.0, 0.1)
            set l2.duration = LIGHTNING_DURATION
            call l2.startColor(1.0, 1.0, 1.0, 1.0)
            call l2.endColor(1.0, 1.0, 1.0, 0.1)
            call SystemMsg.create(GetUnitName(caster) + " cast thistype")
            set caster = null
            set target = null
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SystemTest.end()
        endmethod

    endstruct

endscope