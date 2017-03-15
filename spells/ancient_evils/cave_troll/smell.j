scope Smell
    
    globals
        private constant integer SPELL_ID = 'A831'
        private constant string SFX = ""
		private constant real RADIUS = 200.0
		private constant integer TRUE_SIGHT_ABILITY = 'ATSS'
		private constant real TIMEOUT = 0.05
    endglobals
    
    private function Duration takes integer level returns real
        if level == 11 then
            return 0.0
        endif
        return 3.0*level
    endfunction
    
    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p)
    endfunction
	
	private struct SpellBuff extends Buff

        private effect sfx
		private unit dummy
        
		private static constant integer RAWCODE = 'D831'
        private static constant integer DISPEL_TYPE = BUFF_NEGATIVE
        private static constant integer STACK_TYPE = BUFF_STACK_PARTIAL
        
        method onRemove takes nothing returns nothing
			call this.pop()
            call DestroyEffect(this.sfx)
			call UnitClearBonus(this.dummy, BONUS_SIGHT_RANGE)
			call UnitRemoveAbility(this.dummy, TRUE_SIGHT_ABILITY)
			call RecycleDummy(this.dummy)
            set this.sfx = null
			set this.dummy = null
        endmethod
        
        static method onPeriod takes nothing returns nothing
            local thistype this = thistype(0).next
            loop
                exitwhen this == 0
				call SetUnitX(this.dummy, GetUnitX(this.target))
				call SetUnitY(this.dummy, GetUnitY(this.target))
                set this = this.next
            endloop
        endmethod
        
        implement List

        method onApply takes nothing returns nothing
            set this.sfx = AddSpecialEffectTarget(SFX, this.target, "chest")
			set this.dummy = GetRecycledDummyAnyAngle(GetUnitX(this.target), GetUnitY(this.target), 0)
			call SetUnitOwner(this.dummy, GetOwningPlayer(this.source), false)
			call PauseUnit(this.dummy, false)
			call UnitSetBonus(this.dummy, BONUS_SIGHT_RANGE, R2I(RADIUS))
			call UnitAddAbility(this.dummy, TRUE_SIGHT_ABILITY)
			call this.push(TIMEOUT)
        endmethod
        
        implement BuffApply
	endstruct
    
    struct Smell extends array
    
        private static method onDamage takes nothing returns nothing
            local integer level = GetUnitAbilityLevel(Damage.source, SPELL_ID)
			local real duration
			local SpellBuff b
            if Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.element.coded and level > 0 and TargetFilter(Damage.target, GetOwningPlayer(Damage.source)) then
                set b = SpellBuff.add(Damage.source, Damage.target)
				set duration = Duration(level)
				if duration > 0 then
					set b.duration = duration
				endif
            endif
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call Damage.register(function thistype.onDamage)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope