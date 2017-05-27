scope SoulCorruption

    globals
        private constant integer SPELL_ID = 'A113'
        private constant string MODEL = "Abilities\\Spells\\Undead\\DarkSummoning\\DarkSummonMissile.mdl"
        private constant string SFX_HIT = "Models\\Effects\\SoulCorruption.mdx"
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
    endglobals

    private function Duration takes integer level returns real
        if level == 11 then
            return 5.0
        endif
        return 0.25*level
    endfunction

    private function DamageDealt takes integer level returns real
        if level == 11 then
            return 700.0
        endif
        return 35.0*level
    endfunction

    private function Speed takes integer level returns real
        return 800.0 + 0.0*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction

    struct SoulCorruption extends array

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
            if not SpellBlock.has(this.target) and TargetFilter(this.target, this.owner) then
                call DestroyEffect(AddSpecialEffectTarget(SFX_HIT, this.target, "chest"))
                call Stun.create(this.target, Duration(this.lvl), false)
                call Damage.element.apply(this.caster, this.target, DamageDealt(this.lvl), ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_SPIRIT)
            endif
            call this.destroy()
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype(Missile.create())
            set this.caster = GetTriggerUnit()
            set this.target = GetSpellTargetUnit()
            set this.owner = GetTriggerPlayer()
            set this.lvl = GetUnitAbilityLevel(this.caster, SPELL_ID)
            set this.m = Missile(this)
            set this.m.sourceUnit = this.caster
            set this.m.targetUnit = this.target
            set this.m.speed = Speed(this.lvl)
            set this.m.model = MODEL
            call this.m.registerOnHit(function thistype.onHit)
            call this.m.launch()
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SystemTest.end()
        endmethod

    endstruct
endscope