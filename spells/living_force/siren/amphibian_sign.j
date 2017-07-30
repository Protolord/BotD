scope AmphibianSign

    globals
        private constant integer SPELL_ID   = 'AHH4'
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_CHAOS
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_UNIVERSAL
    endglobals

    private function Duration takes integer level returns real
        return 5.0*level
    endfunction

    private function ExtraPhysical takes integer level returns real
        return 0.5 + 0.0*level
    endfunction

    private function ExtraMagical takes integer level returns real
        return 0.2 + 0.0*level
    endfunction

    private function MoveSlow takes integer level returns real
        return 0.25 + 0.0*level
    endfunction

    private struct SpellBuff extends Buff

        private Movespeed ms
        private trigger trg
        private real physicalFactor
        private real magicalFactor

        private static Table tb

        private static constant integer RAWCODE = 'DHH4'
        private static constant integer DISPEL_TYPE = BUFF_NEGATIVE
        private static constant integer STACK_TYPE = BUFF_STACK_PARTIAL

        method onRemove takes nothing returns nothing
            call thistype.tb.remove(GetHandleId(this.trg))
            call this.ms.destroy()
            call DestroyTrigger(this.trg)
            set this.trg = null
        endmethod

        private static method onDamage takes nothing returns boolean
            local thistype this = thistype.tb[GetHandleId(Damage.triggeringTrigger)]
            local real r
            if this > 0 and this.target == Damage.target then
                if Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.coded and CombatStat.getAttackType(Damage.source) != ATTACK_TYPE_MAGIC then
                    set r = Damage.amount
                    set Damage.amount = Damage.amount*this.physicalFactor
                    call FloatingTextSplat(Element.string(DAMAGE_ELEMENT_WATER) + "+" + I2S(R2I(Damage.amount - r + 0.5)) + "|r", Damage.target).setVisible(GetLocalPlayer() == GetOwningPlayer(Damage.source))
                else
                    set Damage.amount = Damage.amount*this.magicalFactor
                endif
            endif
            return false
        endmethod

        method onApply takes nothing returns nothing
            set this.ms = Movespeed.create(this.target, 0, 0)
            set this.trg = CreateTrigger()
            call Damage.registerModifierTrigger(this.trg)
            call TriggerAddCondition(this.trg, function thistype.onDamage)
            set thistype.tb[GetHandleId(this.trg)] = this
        endmethod

        method reapply takes real moveSlow, real physicalBonus, real magicalBonus returns nothing
            call this.ms.change(moveSlow, 0)
            set this.physicalFactor = 1.0 + physicalBonus
            set this.magicalFactor = 1.0 + magicalBonus
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
            set thistype.tb = Table.create()
        endmethod

        implement BuffApply
    endstruct

    struct AmphibianSign extends array

        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local integer lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            local SpellBuff b = SpellBuff.add(caster, GetSpellTargetUnit())
            call b.reapply(-MoveSlow(lvl), ExtraPhysical(lvl), ExtraMagical(lvl))
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