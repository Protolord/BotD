scope DeathPact

    globals
        private constant integer SPELL_ID = 'A723'
        private constant string SFX = "Models\\Effects\\DeathPact.mdx"
    endglobals

    private function HealthThreshold takes integer level returns real
        if level == 11 then
            return 25.0
        endif
        return 2.0*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE)
    endfunction

    struct DeathPact extends array

        private static method onDamage takes nothing returns nothing
            local integer level = GetUnitAbilityLevel(Damage.source, SPELL_ID)
            local real percent
            if Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.coded and level > 0 and TargetFilter(Damage.target, GetOwningPlayer(Damage.source)) then
                if 100*(GetWidgetLife(Damage.target) - Damage.amount)/GetUnitState(Damage.target, UNIT_STATE_MAX_LIFE) <= HealthThreshold(level) then
                    set Effect.create(SFX, GetUnitX(Damage.target), GetUnitY(Damage.target), GetUnitZ(Damage.target), GetUnitFacing(Damage.source)).duration = 1.10
                    call FloatingTextSplat(Element.string(DAMAGE_ELEMENT_SPIRIT) + I2S(R2I(GetWidgetLife(Damage.target))) + "|r", Damage.target).setVisible(GetLocalPlayer() == GetOwningPlayer(Damage.source))
                    call Damage.kill(Damage.source, Damage.target)
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