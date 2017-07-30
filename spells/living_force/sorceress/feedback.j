scope Feedback

    globals
        private constant integer SPELL_ID = 'AHI1'
        private constant string SFX_TARGET = "Abilities\\Spells\\Human\\Feedback\\ArcaneTowerAttack.mdl"
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
    endglobals

    private function ManaBurned takes integer level returns real
        return 3.0*level
    endfunction

    private function DamagePerManaBurned takes integer level returns real
        return 3.0 + 0.0*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE)
    endfunction

    struct Feedback extends array

        private static trigger trg

        private static method onDamage takes nothing returns nothing
            local integer level = GetUnitAbilityLevel(Damage.source, SPELL_ID)
            local real manaBurned
            local real mana
            local real dmg
            if Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.coded and level > 0 and TargetFilter(Damage.target, GetOwningPlayer(Damage.source)) then
                set manaBurned = ManaBurned(level)
                set mana = GetUnitState(Damage.target, UNIT_STATE_MANA)
                if manaBurned > mana then
                    set manaBurned = mana
                endif
                if manaBurned >= 1.0 then
                    call SetUnitState(Damage.target, UNIT_STATE_MANA, mana - manaBurned)
                    set FloatingText.tagExtraHeight = 70.0
                    call FloatingTextTag("|cff0099ff-" + I2S(R2I(manaBurned)) + "|r", Damage.target)
                    set dmg = DamagePerManaBurned(level)*manaBurned
                    call FloatingTextSplat(Element.string(DAMAGE_ELEMENT_ARCANE) + "+" + I2S(R2I(dmg + 0.5)) + "|r", Damage.target).setVisible(GetLocalPlayer() == GetOwningPlayer(Damage.source))
                    call DisableTrigger(thistype.trg)
                    call Damage.apply(Damage.source, Damage.target, dmg, ATTACK_TYPE, DAMAGE_TYPE)
                    call EnableTrigger(thistype.trg)
                    call DestroyEffect(AddSpecialEffectTarget(SFX_TARGET, Damage.target, "chest"))
                endif
            endif
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            set thistype.trg = CreateTrigger()
            call Damage.registerModifierTrigger(thistype.trg)
            call TriggerAddCondition(thistype.trg, function thistype.onDamage)
            call SystemTest.end()
        endmethod

    endstruct

endscope