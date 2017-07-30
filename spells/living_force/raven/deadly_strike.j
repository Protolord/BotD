scope DeadlyStrike

    globals
        private constant integer SPELL_ID = 'AHF4'
        private constant string SFX_BLOOD = "Models\\Effects\\CriticalStrikeBlood.mdx"
        private constant string SFX_ATTACH = "Models\\Effects\\DeadlyStrikeAttach.mdx"
    endglobals

    //In percent
    private function Chance takes integer level returns real
        return 0.5*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE)
    endfunction

    struct DeadlyStrike extends array

        private static method onDamage takes nothing returns nothing
            local integer level = GetUnitAbilityLevel(Damage.source, SPELL_ID)
            if Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.coded and level > 0 and TargetFilter(Damage.target, GetOwningPlayer(Damage.source)) and GetRandomReal(0, 100) <= Chance(level) then
                set Damage.amount = GetWidgetLife(Damage.target)
                call Damage.lockAmount()
                call FloatingTextSplat(Element.string(DAMAGE_ELEMENT_NORMAL) + I2S(R2I(Damage.amount+ 0.5)) + "|r", Damage.target).setVisible(GetLocalPlayer() == GetOwningPlayer(Damage.source))
                call AddSpecialEffectTimer(AddSpecialEffectTarget(SFX_ATTACH, Damage.source, "weapon"), 1.5)
                call DestroyEffect(AddSpecialEffect(SFX_BLOOD, GetUnitX(Damage.target), GetUnitY(Damage.target)))
            endif
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call Damage.registerModifier(function thistype.onDamage)
            call SystemTest.end()
        endmethod

    endstruct

endscope