scope ShadowStrike

    globals
        private constant integer SPELL_ID = 'AHF2'
        private constant string MODEL = "Models\\Effects\\ShadowStrike.mdl"
        private constant string SFX = "Models\\Effects\\ShadowStrikeSlow.mdl"
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
    endglobals

    private function MoveSlow takes integer level returns real
        if level == 11 then
            return 0.5
        endif
        return 0.4
    endfunction

    private function Speed takes integer level returns real
        return 1000.0 + 0.0*level
    endfunction

    private function DamageDealt takes integer level returns real
        if level == 11 then
            return 1100.0
        endif
        return 80.0*level
    endfunction

    private function Duration takes integer level returns real
        if level == 11 then
            return 6.0
        endif
        return 0.5*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction

    private struct SpellBuff extends Buff

        private Movespeed ms

        private static constant integer RAWCODE = 'DHF2'
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

    struct ShadowStrike extends array

        private unit caster
        private unit target
        private integer lvl
        private player owner
        private Missile m
        private effect sfx

        private method destroy takes nothing returns nothing
            call DestroyEffect(this.sfx)
            call this.m.destroy()
            set this.caster = null
            set this.target = null
            set this.owner = null
        endmethod

        private static method onHit takes nothing returns nothing
            local thistype this = Missile.getHit()
            local SpellBuff b
            if SpellBlock.has(this.target) then
                call this.m.show(false)
            elseif TargetFilter(this.target, this.owner) then
                call Damage.element.apply(this.caster, this.target, DamageDealt(this.lvl), ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_POISON)
                set b = SpellBuff.add(this.caster, this.target)
                call b.reapply(-MoveSlow(this.lvl))
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
            set this.m.model = MODEL
            set this.m.speed = Speed(this.lvl)
            call this.m.registerOnHit(function thistype.onHit)
            call this.m.launch()
            set this.sfx = AddSpecialEffectTarget(SFX, this.m.u, "origin")
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