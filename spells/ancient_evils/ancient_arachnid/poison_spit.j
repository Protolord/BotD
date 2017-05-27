scope PoisonSpit

    globals
        private constant integer SPELL_ID = 'A413'
        private constant boolean SILENCE_STACK = false //If true, targeting a silenced unit will result to additive duration
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
        private constant string MISSILE_MODEL = "Abilities\\Weapons\\snapMissile\\snapMissile.mdl"
    endglobals

    private function Duration takes integer level returns real
        if level == 11 then
            return 20.0
        endif
        return 1.0*level
    endfunction

    private function DamagePerSecond takes integer level returns real
        return 0.0*level + 40.0
    endfunction

    private function Speed takes integer level returns real
        return 0.0*level + 800.0
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction

    private struct SpellBuff extends Buff

        private timer t
        private player owner
        private Silence s
        public real dmg

        private static constant integer RAWCODE = 'D413'
        private static constant integer DISPEL_TYPE = BUFF_NEGATIVE
        private static constant integer STACK_TYPE = BUFF_STACK_PARTIAL

        method onRemove takes nothing returns nothing
            call ReleaseTimer(this.t)
            call this.s.destroy()
            set this.t = null
        endmethod

        static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            if TargetFilter(this.target, GetOwningPlayer(this.source)) then
                call Damage.element.apply(this.source, this.target, this.dmg, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_POISON)
            endif
        endmethod

        method onApply takes nothing returns nothing
            set this.t = NewTimerEx(this)
            set this.s = Silence.create(this.target, 0, SILENCE_STACK)
            call TimerStart(this.t, 1.00, true, function thistype.onPeriod)
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod

        implement BuffApply
    endstruct

    struct PoisonSpit extends array

        private unit caster
        private unit target
        private integer lvl
        private player owner
        private Missile m

        private method destroy takes nothing returns nothing
            call this.m.destroy()
            set this.caster = null
            set this.target = null
            set this.owner = null
        endmethod

        private static method onHit takes nothing returns nothing
            local thistype this = Missile.getHit()
            local SpellBuff b
            if not SpellBlock.has(this.target) and TargetFilter(this.target, this.owner) then
                set b = SpellBuff.add(this.caster, this.target)
                set b.dmg = DamagePerSecond(this.lvl)
                set b.duration = Duration(this.lvl)
            endif
            call this.destroy()
        endmethod


        private static method onCast takes nothing returns nothing
            local thistype this = thistype(Missile.create())
            set this.caster = GetTriggerUnit()
            set this.owner = GetTriggerPlayer()
            set this.target = GetSpellTargetUnit()
            set this.lvl = GetUnitAbilityLevel(this.caster, SPELL_ID)
            set this.m = Missile(this)
            set this.m.sourceUnit = this.caster
            set this.m.targetUnit = this.target
            set this.m.speed = Speed(this.lvl)
            set this.m.model = MISSILE_MODEL
            call this.m.registerOnHit(function thistype.onHit)
            call this.m.launch()
            call SetUnitScale(this.m.u, 2.0, 0, 0)
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype on " + GetUnitName(GetSpellTargetUnit()))
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SpellBuff.initialize()
            call SystemTest.end()
        endmethod

    endstruct

endscope