scope EarthShatter

    globals
        private constant integer SPELL_ID = 'A612'
        private constant string SFX = "Models\\Effects\\EarthShatter.mdx"
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
    endglobals

    private function AttackSpeedSlow takes integer level returns real
        return 0.5 + 0.0*level
    endfunction

    private function MoveSpeedSlow takes integer level returns real
        return 0.5 + 0.0*level
    endfunction

    private function Duration takes integer level returns real
        if level == 11 then
            return 4.0
        endif
        return 0.2*level
    endfunction

    private function DamageDealt takes integer level returns real
        if level == 11 then
            return 1000.0
        endif
        return 50.0*level
    endfunction

    private function Radius takes integer level returns real
        return 400.0 + 0.0*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction

    private struct SpellBuff extends Buff

        readonly Movespeed ms
        readonly Atkspeed as

        private static constant integer RAWCODE = 'D612'
        private static constant integer DISPEL_TYPE = BUFF_NEGATIVE
        private static constant integer STACK_TYPE = BUFF_STACK_PARTIAL

        method onRemove takes nothing returns nothing
            call this.as.destroy()
            call this.ms.destroy()
        endmethod

        method onApply takes nothing returns nothing
            set this.as = Atkspeed.create(this.target, 0)
            set this.ms = Movespeed.create(this.target, 0, 0)
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod

        implement BuffApply
    endstruct

    struct EarthShatter extends array

        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local player owner = GetTriggerPlayer()
            local integer lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            local real duration = Duration(lvl)
            local real atkSlow = AttackSpeedSlow(lvl)
            local real moveSlow = MoveSpeedSlow(lvl)
            local real dmg = DamageDealt(lvl)
            local real x = GetUnitX(caster)
            local real y = GetUnitY(caster)
            local group g = NewGroup()
            local unit dummy = GetRecycledDummyAnyAngle(x, y, 50)
            local unit u
            local SpellBuff b
            call DummyAddRecycleTimer(dummy, 2.5)
            call SetUnitScale(dummy, Radius(lvl)/300.0, 0, 0)
            call DestroyEffect(AddSpecialEffectTarget(SFX, dummy, "origin"))
            call GroupUnitsInArea(g, x, y, Radius(lvl))
            loop
                set u = FirstOfGroup(g)
                exitwhen u == null
                call GroupRemoveUnit(g, u)
                if TargetFilter(u, owner) then
                    set b = SpellBuff.add(caster, u)
                    set b.duration = duration
                    call b.as.change(-atkSlow)
                    call b.ms.change(-moveSlow, 0)
                    call Damage.element.apply(caster, u, dmg, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_EARTH)
                endif
            endloop
            call ReleaseGroup(g)
            set g = null
            set u = null
            set dummy = null
            set owner = null
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SpellBuff.initialize()
            call SystemTest.end()
        endmethod

    endstruct
endscope