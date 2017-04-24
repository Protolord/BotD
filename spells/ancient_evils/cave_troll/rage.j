scope Rage
    
    globals
        private constant integer SPELL_ID = 'A843'
        private constant string SFX = ""
    endglobals
    
    //In percent
    private function MaxHPHeal takes integer level returns real
        if level == 11 then
            return 20.0
        endif
        return 1.5*level
    endfunction
	
	//In percent
	private function UnitChance takes integer level returns real
		return 5.0 + 0.0*level
	endfunction
	
	private function StructureChance takes integer level returns real
		return 1.0 + 0.0*level
	endfunction
    
    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p)
    endfunction
    
    struct Rage extends array
    
        private static method onDamage takes nothing returns nothing
            local integer level = GetUnitAbilityLevel(Damage.source, SPELL_ID)
			local boolean proc = false
            local VertexColor vc
            local real rand
            if Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.coded and level > 0 and TargetFilter(Damage.target, GetOwningPlayer(Damage.source)) then
                set rand = GetRandomReal(0, 100)
				if IsUnitType(Damage.target, UNIT_TYPE_STRUCTURE) then
					if rand <= StructureChance(level) then
						set proc = true
					endif
				else
					if rand <= UnitChance(level) then
						set proc = true
					endif
                endif
				if proc then
					call Heal.unit(Damage.source, MaxHPHeal(level)*GetUnitState(Damage.source, UNIT_STATE_MAX_LIFE)/100.0, 4.0)
					call DestroyEffect(AddSpecialEffectTarget(SFX, Damage.source, "chest"))
                    set vc = VertexColor.create(Damage.source, 0, -225, -225, 0)
                    set vc.speed = 765
                    set vc.duration = 0.75
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