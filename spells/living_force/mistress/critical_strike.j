scope CriticalStrike

    globals
        private constant integer SPELL_ID = 'AHC4'
        private constant string SFX_BLOOD = "Models\\Effects\\CriticalStrikeBlood.mdx"
    endglobals

    private function Multiplier takes integer level returns real
        return 1.25*level
    endfunction

    //In percent
    private function Chance takes integer level returns real
        return 100.0//35 + 0.0*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE)
    endfunction

    struct CriticalStrike extends array

        private static unit target

        private static method onDamage takes nothing returns nothing
            local textsplat t
            if Damage.target == thistype.target then
                set t = FloatingTextSplat(Element.string(DAMAGE_ELEMENT_NORMAL) + I2S(R2I(Damage.amount + 0.5)) + "|r", Damage.target, 1.0)
                call t.setVisible(GetLocalPlayer() == GetOwningPlayer(Damage.source) and IsUnitVisible(Damage.source, GetLocalPlayer()))
                set thistype.target = null
            endif
        endmethod

        private static method onDamageModify takes nothing returns nothing
            local integer level = GetUnitAbilityLevel(Damage.source, SPELL_ID)
            if Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.coded and level > 0 and TargetFilter(Damage.target, GetOwningPlayer(Damage.source)) and GetRandomReal(0, 100) <= Chance(level) then
                set Damage.amount = Multiplier(level)*Damage.amount
                call DestroyEffect(AddSpecialEffect(SFX_BLOOD, GetUnitX(Damage.target), GetUnitY(Damage.target)))
                set thistype.target = Damage.target
            endif
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call Damage.registerModifier(function thistype.onDamageModify)
            call Damage.register(function thistype.onDamage)
            set thistype.target = null
            call SystemTest.end()
        endmethod

    endstruct

endscope