scope MistOfDarkness

    globals
        private constant integer SPELL_ID = 'A312'
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_CHAOS
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_UNIVERSAL
        private constant string SFX = "Models\\Effects\\MistOfDarkness.mdx"
    endglobals

    private function DamageAmount takes integer level returns real
        if level == 11 then
            return 700.0
        endif
        return 35.0*level
    endfunction

    private function SilenceDuration takes integer level returns real
        if level == 11 then
            return 10.0
        endif
        return 0.5*level
    endfunction

    private function Radius takes integer level returns real
        return 400.0 + 0.0*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE)
    endfunction

    struct MistOfDarkness extends array

        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local player owner = GetTriggerPlayer()
            local integer lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            local group g = NewGroup()
            local real duration = SilenceDuration(lvl)
            local real x = GetUnitX(caster)
            local real y = GetUnitY(caster)
            local unit u
            call GroupUnitsInArea(g, x, y, Radius(lvl))
            call DestroyEffect(AddSpecialEffect(SFX, x, y))
            loop
                set u = FirstOfGroup(g)
                exitwhen u == null
                call GroupRemoveUnit(g, u)
                if TargetFilter(u, owner) then
                    call Damage.element.apply(caster, u, DamageAmount(lvl), ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_DARK)
                    call Silence.create(u, duration)
                endif
            endloop
            call ReleaseGroup(g)
            set g = null
            set caster = null
            set owner = null
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SystemTest.end()
        endmethod

    endstruct

endscope