scope ViciousStrike

    //issue : "attack slam" animation is not fully played before that damage dealt
    globals
        private constant integer SPELL_ID               = 'AH84'

        private constant attacktype ATTACK_TYPE         = ATTACK_TYPE_NORMAL

        private constant damagetype DAMAGE_TYPE         = DAMAGE_TYPE_MAGIC

        private constant integer    DAMAGE_ELEMENT_TYPE = DAMAGE_ELEMENT_NORMAL

        //effect time for it to expire (Hunter "attack slam" animation time till lands of hammer)
        //also spell will then deal damage after DELAY_TIME passed
        private constant real       DELAY_TIME          = 0.7

        //effect appear while damage applied to target
        private constant string     SFX                 = "Objects\\Spawnmodels\\Human\\HumanLargeDeathExplode\\HumanLargeDeathExplode.mdl"
    endglobals

	private function SpellDamage takes real missingHealth, integer level returns real
		return missingHealth*0.5*level
	endfunction

    struct ViciousStrike extends array
        implement Alloc

        private unit triggerUnit
        private unit target

        private integer spellLevel

        private real missingHealth

        private static method onExpire takes nothing returns nothing
            local thistype this         = ReleaseTimer(GetExpiredTimer())

            call DestroyEffect(AddSpecialEffectTarget(SFX, this.target, "origin"))
            call Damage.element.apply(this.triggerUnit, this.target, SpellDamage(this.missingHealth, this.spellLevel), ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_TYPE)
            call IssueImmediateOrder(this.triggerUnit, "stop")
            call PauseUnit(this.triggerUnit, false)

            set this.triggerUnit        = null
            set this.target             = null

            call this.deallocate()
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this         = thistype.allocate()
            set this.triggerUnit        = GetTriggerUnit()
			set this.target             = GetSpellTargetUnit()
			set this.spellLevel         = GetUnitAbilityLevel(triggerUnit, SPELL_ID)
            set this.missingHealth      = GetUnitState(triggerUnit, UNIT_STATE_MAX_LIFE) - GetUnitState(triggerUnit, UNIT_STATE_LIFE)

            call PauseUnit(this.triggerUnit, true)
            call SetUnitAnimationByIndex(this.triggerUnit, 11)

            call TimerStart(NewTimerEx(this), DELAY_TIME, false, function thistype.onExpire)

            call SystemMsg.create(GetUnitName(triggerUnit) + " cast thistype")
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SystemTest.end()
        endmethod

    endstruct

endscope