scope SeamansWill

    globals
        private constant integer SPELL_ID = 'AHL2'
        private constant string SFX = "Models\\Effects\\SeamansWillExplode.mdx"
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
    endglobals

    private function MovementSlow takes integer level returns real
        return 0.50 + 0.0*level
    endfunction

    private function DamageDealt takes integer level returns real
        if level == 11 then
            return 500.0
        endif
        return 35.0*level
    endfunction

    private function Duration takes integer level returns real
        if level == 11 then
            return 6.0
        endif
        return 0.4*level
    endfunction

    private function Radius takes integer level returns real
        return 350.0 + 0.0*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction

    private struct SpellBuff extends Buff

        private Movespeed ms

        private static constant integer RAWCODE = 'DHL2'
        private static constant integer DISPEL_TYPE = BUFF_NEGATIVE
        private static constant integer STACK_TYPE = BUFF_STACK_NONE

        method onRemove takes nothing returns nothing
            call this.ms.destroy()
        endmethod

        method onApply takes nothing returns nothing
            set this.ms = Movespeed.create(this.target, 0, 0)
        endmethod

        method reapply takes real slow returns nothing
            call this.ms.change(slow, 0)
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod

        implement BuffApply
    endstruct

    struct SeamansWill extends array

        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local player owner = GetTriggerPlayer()
            local integer lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            local real x = GetUnitX(caster)
            local real y = GetUnitY(caster)
            local group g = NewGroup()
            local Effect e = Effect.createAnyAngle(SFX, x, y, GetUnitFlyHeight(caster) + 50)
            local real duration = Duration(lvl)
            local real ms = -MovementSlow(lvl)
            local real dmg = DamageDealt(lvl)
            local SpellBuff b
            local unit u
            set e.scale = Radius(lvl)/300.0
            call GroupUnitsInArea(g, x, y, Radius(lvl))
            loop
                set u = FirstOfGroup(g)
                exitwhen u == null
                call GroupRemoveUnit(g, u)
                if TargetFilter(u, owner) then
                    call Damage.element.apply(caster, u, dmg, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_WATER)
                    set b = SpellBuff.add(caster, u)
                    call b.reapply(ms)
                    set b.duration = duration
                endif
            endloop
            call ReleaseGroup(g)
            call e.destroy()
            set g = null
            set u = null
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