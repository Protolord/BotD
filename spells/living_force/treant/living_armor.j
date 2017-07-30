scope LivingArmor

    globals
        private constant integer SPELL_ID   = 'AHK1'
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_CHAOS
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_UNIVERSAL
    endglobals

    private function PhysicalDamageReduction takes integer level returns real
        return 0.90 + 0.0*level
    endfunction

    private function NumberOfReducedAttacks takes integer level returns integer
        return level
    endfunction

    private function Duration takes integer level returns real
        return 30.0 + 0.0*level
    endfunction

    private struct SpellBuff extends Buff

        private trigger trg
        private integer instances
        private real physicalFactor
        private BuffDisplay bd

        private static Table tb

        private static constant integer RAWCODE = 'BHK1'
        private static constant integer DISPEL_TYPE = BUFF_POSITIVE
        private static constant integer STACK_TYPE = BUFF_STACK_PARTIAL

        method onRemove takes nothing returns nothing
            call this.bd.destroy()
            call thistype.tb.remove(GetHandleId(this.trg))
            call DestroyTrigger(this.trg)
            set this.trg = null
        endmethod

        private static method onDamage takes nothing returns boolean
            local thistype this = thistype.tb[GetHandleId(Damage.triggeringTrigger)]
            if this > 0 and this.target == Damage.target and this.instances > 0 then
                if Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.coded and CombatStat.getAttackType(Damage.source) != ATTACK_TYPE_MAGIC then
                    set Damage.amount = Damage.amount*this.physicalFactor
                    set this.instances = this.instances - 1
                    set this.bd.value = "|iLIVING_ARMOR|i" + I2S(this.instances)
                    if this.instances == 0 then
                        call this.remove()
                    endif
                endif
            endif
            return false
        endmethod

        method onApply takes nothing returns nothing
            set this.trg = CreateTrigger()
            set this.bd = BuffDisplay.create(this.target)
            call Damage.registerModifierTrigger(this.trg)
            call TriggerAddCondition(this.trg, function thistype.onDamage)
            set thistype.tb[GetHandleId(this.trg)] = this
        endmethod

        method reapply takes real physicalReduction, integer numberOfInstances returns nothing
            set this.physicalFactor = 1.0 - physicalReduction
            set this.instances = numberOfInstances
            set this.bd.value = "|iLIVING_ARMOR|i" + I2S(this.instances)
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
            set thistype.tb = Table.create()
        endmethod

        implement BuffApply
    endstruct

    struct LivingArmor extends array

        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local integer lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            local SpellBuff b = SpellBuff.add(caster, GetSpellTargetUnit())
            call b.reapply(PhysicalDamageReduction(lvl), NumberOfReducedAttacks(lvl))
            set b.duration = Duration(lvl)
            call SystemMsg.create(GetUnitName(caster) + " cast thistype")
            set caster = null
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SpellBuff.initialize()
            call SystemTest.end()
        endmethod

    endstruct

endscope