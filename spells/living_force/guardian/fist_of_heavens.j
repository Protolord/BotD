scope FistOfHeavens

    globals
        private constant integer    SPELL_ID            = 'AH94'

        private constant string     MISSILE_MODEL       = "Abilities\\Weapons\\FarseerMissile\\FarseerMissile.mdl"

        //strike effect after missile hits
        private constant string     SFX                 = "Models\\Effects\\FistOfHeavensEffect.mdx"

        private constant attacktype ATTACK_TYPE         = ATTACK_TYPE_NORMAL

        private constant damagetype DAMAGE_TYPE         = DAMAGE_TYPE_MAGIC

        private constant integer    DAMAGE_ELEMENT_TYPE = DAMAGE_ELEMENT_ELECTRIC

        private constant real       MISSILE_SPEED       = 1000.
    endglobals

    private function SpellDamage takes real targetMaxHp, integer level returns real
        return targetMaxHp*0.125*level
    endfunction

    //unit u : target unit
    //player p : owner of triggering unit
    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction

    struct FistOfHeavens extends array
        private unit    triggerUnit
        private unit    target

        private integer spellLevel

        private real targetMaxHp

        private Missile m

        private static method onHit takes nothing returns nothing
            local thistype this = Missile.getHit()
            if not SpellBlock.has(this.target) and TargetFilter(this.target, GetOwningPlayer(this.triggerUnit)) then
                call DestroyEffect(AddSpecialEffectTarget(SFX, this.target, "origin"))
                call Damage.element.apply(this.triggerUnit, this.target, SpellDamage(this.targetMaxHp, this.spellLevel), ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_TYPE)
            endif

            set this.triggerUnit    = null
            set this.target         = null

            call this.m.destroy()
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this     = thistype(Missile.create())

            set this.triggerUnit    = GetTriggerUnit()
            set this.target         = GetSpellTargetUnit()
            set this.spellLevel     = GetUnitAbilityLevel(this.triggerUnit, SPELL_ID)
            set this.targetMaxHp    = GetUnitState(this.target, UNIT_STATE_MAX_LIFE)

            set this.m = Missile(this)
            set this.m.sourceUnit   = this.triggerUnit
            set this.m.targetUnit   = this.target
            set this.m.model        = MISSILE_MODEL
            set this.m.speed        = MISSILE_SPEED
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