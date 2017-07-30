scope ArcaneBomb

    globals
        private constant integer SPELL_ID = 'AHM3'
        private constant string MODEL = "Models\\Effects\\ArcaneBombMissile.mdx"
        private constant string SFX_HIT = "Models\\Effects\\ArcaneBombExplosion.mdx"
        private constant real SPEED = 800.0
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
    endglobals

    /*private function DamageDealt takes integer level returns real
        return 50.0*level
    endfunction*/

    private function MoveSlow takes integer level returns real
        return 0.5 + 0.0*level
    endfunction

    private function Radius takes integer level returns real
        return 0.0*level + 200.0
    endfunction

    private function Duration takes integer level returns real
        return 0.3*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction

    private struct SpellBuff extends Buff

        private Movespeed ms

        private static constant integer RAWCODE = 'DHM3'
        private static constant integer DISPEL_TYPE = BUFF_NEGATIVE
        private static constant integer STACK_TYPE = BUFF_STACK_PARTIAL

        method onRemove takes nothing returns nothing
            call this.ms.destroy()
        endmethod

        method onApply takes nothing returns nothing
            set this.ms = Movespeed.create(this.target, 0, 0)
        endmethod

        method reapply takes real moveSlow returns nothing
            call this.ms.change(moveSlow, 0)
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod

        implement BuffApply
    endstruct

    struct ArcaneBomb extends array

        private unit caster
        private player owner
        private integer lvl
        private Missile m

        private static group g

        private method destroy takes nothing returns nothing
            call this.m.destroy()
            set this.caster = null
            set this.owner = null
        endmethod

        private static method onHit takes nothing returns nothing
            local thistype this = Missile.getHit()
            local real radius = Radius(this.lvl)
            //local real dmg = DamageDealt(this.lvl)
            local real ms = -MoveSlow(this.lvl)
            local real dur = Duration(this.lvl)
            local SpellBuff b
            local unit u
            call GroupUnitsInArea(thistype.g, this.m.x, this.m.y, Radius(this.lvl))
            call DestroyEffect(AddSpecialEffect(SFX_HIT, this.m.x, this.m.y))
            loop
                set u = FirstOfGroup(thistype.g)
                exitwhen u == null
                call GroupRemoveUnit(thistype.g, u)
                if TargetFilter(u, this.owner) then
                    //call Damage.element.apply(this.caster, u, dmg, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_ARCANE)
                    set b = SpellBuff.add(this.caster, u)
                    call b.reapply(ms)
                    set b.duration = dur
                endif
            endloop
            call this.destroy()
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype(Missile.create())
            local real x = GetSpellTargetX()
            local real y = GetSpellTargetY()
            set this.caster = GetTriggerUnit()
            set this.owner = GetTriggerPlayer()
            set this.lvl = GetUnitAbilityLevel(this.caster, SPELL_ID)
            set this.m = Missile(this)
            set this.m.sourceUnit = this.caster
            call this.m.targetXYZ(x, y, GetPointZ(x, y) + 5.0)
            set this.m.speed = SPEED
            set this.m.model = MODEL
            set this.m.scale = 1.5
            set this.m.autohide = true
            set this.m.projectile = true
            set this.m.arc = 2.5
            call this.m.registerOnHit(function thistype.onHit)
            call this.m.launch()
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            set thistype.g = CreateGroup()
            call SpellBuff.initialize()
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SystemTest.end()
        endmethod

    endstruct
endscope