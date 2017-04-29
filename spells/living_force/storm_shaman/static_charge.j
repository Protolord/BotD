scope StaticCharge
 
    globals
        private constant integer SPELL_ID = 'AH13'
        private constant string SFX = "Models\\Effects\\StaticCharge.mdx"
		private constant string LIGHTNING_CODE = "CLSB"
		private constant real LIGHTNING_DURATION = 0.4
		private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
    endglobals
    
	//Percentage of Max HP as Damage
    private function DamagePercent takes integer level returns real
        if level == 11 then
            return 10.0
        endif
        return 20 + 5.0*level
    endfunction
	
	private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction
    
    
    struct StaticCharge extends array
        
        private static method onCast takes nothing returns boolean
			local unit caster = GetTriggerUnit()
            local unit target = GetSpellTargetUnit()
			local integer lvl = GetUnitAbilityLevel(target, SPELL_ID)
            local Lightning l
			if lvl > 0 and TargetFilter(caster, GetOwningPlayer(target)) then
				call Damage.element.apply(target, caster, DamagePercent(lvl)*GetUnitState(caster, UNIT_STATE_MAX_LIFE)/100, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_ELECTRIC)
				set l = Lightning.createUnits(LIGHTNING_CODE, target, caster)
                set l.duration = LIGHTNING_DURATION
                call l.startColor(1.0, 1.0, 1.0, 0.8)
                call l.endColor(1.0, 1.0, 1.0, 0.1)
				call DestroyEffect(AddSpecialEffectTarget(SFX, caster, "chest"))
				set caster = null
				call SystemMsg.create(GetUnitName(target) + " procs thistype")
			endif
			set caster = null
            set target = null
            return false
        endmethod
        
        static method init takes nothing returns nothing
            local integer index = 0
            local trigger trg = CreateTrigger()
            call SystemTest.start("Initializing thistype: ")
            loop
                call TriggerRegisterPlayerUnitEvent(trg, Player(index), EVENT_PLAYER_UNIT_SPELL_EFFECT, null)
                set index = index + 1
                exitwhen index == bj_MAX_PLAYER_SLOTS
            endloop
            call TriggerAddCondition(trg, function thistype.onCast)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope