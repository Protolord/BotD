scope Bash

    globals
        private constant integer SPELL_ID = 'AHB4'
        private constant string SFX = "Abilities\\Spells\\Human\\DispelMagic\\DispelMagicTarget.mdl"
        private constant string SFX_ATTACH = "Models\\Effects\\BashAttach.mdx"
    endglobals

    private function Duration takes integer level returns real
        return 2.0 + 0.0*level
    endfunction

    //In percent
    private function Chance takes integer level returns real
        return 7.5*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE)
    endfunction

    struct Bash extends array

        private static method onDamage takes nothing returns nothing
            local integer level = GetUnitAbilityLevel(Damage.source, SPELL_ID)
            if Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.coded and level > 0 and TargetFilter(Damage.target, GetOwningPlayer(Damage.source)) and GetRandomReal(0, 100) <= Chance(level) then
                call Stun.create(Damage.target, Duration(level), false)
                call DestroyEffect(AddSpecialEffectTarget(SFX, Damage.target, "origin"))
                call AddSpecialEffectTimer(AddSpecialEffectTarget(SFX_ATTACH, Damage.source, "hand left"), 0.25)
            endif
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call Damage.register(function thistype.onDamage)
            call SystemTest.end()
        endmethod

    endstruct

endscope