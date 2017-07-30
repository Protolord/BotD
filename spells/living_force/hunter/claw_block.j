scope ClawBlock

	//Damage is hard-coded to reflect the damage dealt by enemy unit for 100%
    globals
        private constant integer SPELL_ID               = 'AH81'

		private constant integer BUFF_ID                = 'BH81'

		//buff effect which attached to spell owner
        private constant string BUFF_EFFECT             = "Abilities\\Spells\\NightElf\\ThornsAura\\ThornsAuraDamage.mdl"

        //attach point of SFX
        private constant string ATTACH_POINT            = "origin"

        private constant attacktype ATTACK_TYPE         = ATTACK_TYPE_NORMAL

        private constant damagetype DAMAGE_TYPE         = DAMAGE_TYPE_NORMAL

        private constant integer    DAMAGE_ELEMENT_TYPE = DAMAGE_ELEMENT_NORMAL
    endglobals

	//chance to activate the spell in percentage
	private function Chance takes integer level returns real
		return 4.0*level
	endfunction

    //unit u : attacking unit
    //player p : owner of attacked unit
    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and /*
        */     IsUnitType(u, UNIT_TYPE_MELEE_ATTACKER)
    endfunction

    struct ClawBlock extends array

		private static method onDamage takes nothing returns nothing
            local integer level     = GetUnitAbilityLevel(Damage.target, SPELL_ID)

            if Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.coded and level > 0 and TargetFilter(Damage.source, GetOwningPlayer(Damage.target)) and CombatStat.isMelee(Damage.source) then
				if GetRandomInt(0, 100) <= Chance(level) then
					call Damage.element.apply(Damage.target, Damage.source, Damage.amount, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_TYPE)
				endif
				call SystemMsg.create(GetUnitName(Damage.target) + " procs thistype")
            endif
		endmethod

        private static method learn takes nothing returns nothing
            local thistype this
            local unit triggerUnit  = GetTriggerUnit()
            local integer id

            if GetLearnedSkill() == SPELL_ID and GetUnitAbilityLevel(triggerUnit, SPELL_ID) == 1 then
                call UnitAddAbility(triggerUnit, BUFF_ID)

				call AddSpecialEffectTarget(BUFF_EFFECT, triggerUnit, ATTACH_POINT)
            endif

            set triggerUnit         = null
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
			call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_SKILL, function thistype.learn)
			call Damage.register(function thistype.onDamage)
            call SystemTest.end()
        endmethod

    endstruct

endscope