scope SongOfTheSiren

    globals
        private constant integer SPELL_ID = 'AHH1'
        private constant string SFX_UNIT = "Abilities\\Spells\\Human\\DispelMagic\\DispelMagicTarget.mdl"
        private constant string SFX = "Models\\Effects\\SongOfTheSiren.mdx"
        private constant real SPACING = 100.0
    endglobals

    private function Radius takes integer level returns real
        return 100.0 + 50.0*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitAlly(u, p)
    endfunction

    struct SongOfTheSiren extends array

        private static group g

        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local integer lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            local real x = GetSpellTargetX()
            local real y = GetSpellTargetY()
            local player p = GetTriggerPlayer()
            local real radius = Radius(lvl)
            local unit u
            local real da
            local real angle
            local real endAngle
            call GroupUnitsInArea(thistype.g, x, y, radius)
            loop
                set u = FirstOfGroup(thistype.g)
                exitwhen u == null
                call GroupRemoveUnit(thistype.g, u)
                if TargetFilter(u, p) then
                    call Buff.dispel(u, BUFF_NEGATIVE)
                    call DestroyEffect(AddSpecialEffectTarget(SFX_UNIT, u, "chest"))
                endif
            endloop
            call DestroyEffect(AddSpecialEffect(SFX, x, y))
            set da = 2*bj_PI/R2I(2*bj_PI*radius/SPACING)
            if da > bj_PI/3 then
                set da = bj_PI/3
            endif
            set angle = da
            set endAngle = da + 2*bj_PI - 0.0001
            loop
                exitwhen angle >= endAngle
                call DestroyEffect(AddSpecialEffect(SFX, x + radius*Cos(angle), y + radius*Sin(angle)))
                set angle = angle + da
            endloop
            call SystemMsg.create(GetUnitName(caster) + " cast thistype")
            set caster = null
            set p = null
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            set thistype.g = CreateGroup()
            call SystemTest.end()
        endmethod

    endstruct

endscope