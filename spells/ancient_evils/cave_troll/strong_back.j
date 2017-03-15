scope StrongBack

    globals
        private constant integer SPELL_ID = 'A822'
		private constant integer BUFF_ID = 'B822'
		private constant real ANGLE_TOLERANCE = 60.0 //In degrees
    endglobals
    
	//In percent
    private function DamageReduction takes integer level returns real
        if level == 11 then
            return 50.0
        endif
        return 3.0*level
    endfunction
    
    private function TargetFilter takes unit u, player p returns boolean
        return IsUnitEnemy(u, p)
    endfunction
    
    struct StrongBack extends array
        
        private static method onDamage takes nothing returns nothing
            local integer level = GetUnitAbilityLevel(Damage.target, SPELL_ID)    
			local real angle
            if level > 0 and Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.element.coded and TargetFilter(Damage.source, GetOwningPlayer(Damage.target))  then
				set angle = Atan2(GetUnitY(Damage.target) - GetUnitY(Damage.source), GetUnitX(Damage.target) - GetUnitX(Damage.source))*bj_RADTODEG
				if angle < 0 then
					set angle = angle + 360
				endif
				if RAbsBJ(GetUnitFacing(Damage.target) - angle) <= ANGLE_TOLERANCE then
					set Damage.amount = DamageReduction(level)*Damage.amount/100
				endif
            endif
        endmethod
		
		private static method learn takes nothing returns nothing   
			local unit u = GetTriggerUnit()
            if GetLearnedSkill() == SPELL_ID then
                call UnitAddAbility(u, BUFF_ID)
                call UnitMakeAbilityPermanent(u, true, BUFF_ID) 
            endif
			set u = null
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call Damage.registerModifier(function thistype.onDamage)
			call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_SKILL, function thistype.learn)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope