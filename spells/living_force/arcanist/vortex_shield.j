scope VortexShield

    globals
        private constant integer SPELL_ID = 'AHE1'
        private constant real TIMEOUT = 0.03125
    endglobals

    private function NumberOfCharges takes integer level returns integer
        return level
    endfunction

    private struct SpellBuff extends Buff

        private integer charges
        private BuffDisplay bd
        private static Table tb

        private static constant integer RAWCODE = 'BHE1'
        private static constant integer DISPEL_TYPE = BUFF_POSITIVE
        private static constant integer STACK_TYPE = BUFF_STACK_NONE

        method onRemove takes nothing returns nothing
            call thistype.tb.remove(GetHandleId(this.target))
            call this.bd.destroy()
        endmethod

        static method onDamage takes nothing returns nothing
            local thistype this = thistype.tb[GetHandleId(Damage.target)]
            if Damage.type == DAMAGE_TYPE_PHYSICAL and this > 0 and not Damage.coded and CombatStat.getAttackType(Damage.source) != ATTACK_TYPE_MAGIC then
                set Damage.amount = 0
                set this.charges = this.charges - 1
                set this.bd.value = "|iVORTEX_SHIELD|i" + I2S(this.charges)
                if this.charges == 0 then
                    call this.remove()
                endif
            endif
        endmethod

        method onApply takes nothing returns nothing
            set thistype.tb[GetHandleId(this.target)] = this
            set this.bd = BuffDisplay.create(this.target)
        endmethod

        method reapply takes integer newCharges returns nothing
            set this.charges = newCharges
            set this.bd.value = "|iVORTEX_SHIELD|i" + I2S(newCharges)
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
            call Damage.registerModifier(function thistype.onDamage)
            set thistype.tb = Table.create()
        endmethod

        implement BuffApply
    endstruct

    struct VortexShield extends array

        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local integer lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            local SpellBuff b = SpellBuff.add(caster, caster)
            call b.reapply(NumberOfCharges(lvl))
            call SystemMsg.create(GetUnitName(caster) + " cast thistype")
            set caster = null
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call SpellBuff.initialize()
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SystemTest.end()
        endmethod

    endstruct

endscope