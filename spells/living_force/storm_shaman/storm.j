scope Storm

    globals
        private constant integer SPELL_ID = 'AH14'
        private constant string SFX = "Models\\Effects\\Storm.mdx"
        private constant string SFX_HIT = "Abilities\\Weapons\\Bolt\\BoltImpact.mdl"
        private constant string LIGHTNING_CODE = "CLSB"
        private constant real LIGHTNING_DURATION = 0.8
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
    endglobals

    private function Duration takes integer level returns real
        return 10.0*level
    endfunction

    private function Radius takes integer level returns real
        return 900.0 + 0.0*level
    endfunction

    private function DamagePerAttack takes integer level returns real
        return 1000.0 + 0.0*level
    endfunction

    private function AttackCooldown takes integer level returns real
        return 1.0 + 0.0*level
    endfunction

    private function MovementSlow takes integer level returns real
        return 0.2 + 0.0*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and IsUnitVisible(u, p)
    endfunction

    private struct SpellBuff extends Buff

        private effect sfx
        private timer t
        private real dmg
        private real radius
        private Movespeed ms

        private static group g

        private static constant integer RAWCODE = 'BH14'
        private static constant integer DISPEL_TYPE = BUFF_POSITIVE
        private static constant integer STACK_TYPE = BUFF_STACK_NONE

        method onRemove takes nothing returns nothing
            call AddUnitAnimationProperties(this.target, "alternate", false)
            call this.ms.destroy()
            call ReleaseTimer(this.t)
            call DestroyEffect(this.sfx)
            set this.t = null
            set this.sfx = null
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            local player p = GetOwningPlayer(this.source)
            local unit u
            local Lightning l
            call GroupEnumUnitsInRange(thistype.g, GetUnitX(this.source), GetUnitY(this.source), this.radius, null)
            loop
                set u = FirstOfGroup(thistype.g)
                exitwhen u == null
                call GroupRemoveUnit(thistype.g, u)
                if TargetFilter(u, p) then
                    set l = Lightning.createUnits(LIGHTNING_CODE, this.source, u)
                    set l.sourceZ = 300.0
                    set l.duration = LIGHTNING_DURATION
                    call l.startColor(1.0, 1.0, 1.0, 1.0)
                    call l.endColor(1.0, 1.0, 1.0, 0.1)
                    call DestroyEffect(AddSpecialEffectTarget(SFX_HIT, u, "overhead"))
                    call Damage.element.apply(this.source, u, this.dmg, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_ELECTRIC)
                endif
            endloop
            set p = null
        endmethod

        method onApply takes nothing returns nothing
            set this.sfx = AddSpecialEffectTarget(SFX, this.target, "overhead")
            set this.ms = Movespeed.create(this.target, 0, 0)
            call AddUnitAnimationProperties(this.target, "alternate", true)
            set this.t = NewTimerEx(this)
        endmethod

        method reapply takes integer level returns nothing
            set this.duration = Duration(level)
            set this.dmg = DamagePerAttack(level)
            set this.radius = Radius(level)
            call this.ms.change(-MovementSlow(level), 0)
            call TimerStart(this.t, AttackCooldown(level), true, function thistype.onPeriod)
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
            set thistype.g = CreateGroup()
        endmethod

        implement BuffApply
    endstruct

    struct Storm extends array
        implement Alloc

        private unit u

        private static method expires takes nothing returns nothing
            local thistype this = ReleaseTimer(GetExpiredTimer())
            call UnitRemoveAbility(this.u, 'Bbsk')
            set this.u = null
            call this.deallocate()
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            local unit caster = GetTriggerUnit()
            local integer lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            local SpellBuff b = SpellBuff.add(caster, caster)
            call b.reapply(lvl)
            set this.u = caster
            call TimerStart(NewTimerEx(this), 0.00, false, function thistype.expires)
            set caster = null
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