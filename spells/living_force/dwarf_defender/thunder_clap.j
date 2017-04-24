scope ThunderClap

    globals
        private constant integer SPELL_ID = 'AH31'
        private constant string SFX = "Abilities\\Spells\\Human\\Thunderclap\\ThunderClapCaster.mdl"
        private constant string BUFF_SFX = "Abilities\\Spells\\Orc\\Purge\\PurgeBuffTarget.mdl"
		private constant string SFX_RIBBON = "Abilities\\Spells\\Orc\\LightningShield\\LightningShieldBuff.mdl"
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
    endglobals

    private function MovementSlow takes integer level returns real
        return 0.60 + 0.0*level
    endfunction
	
	private function Duration takes real missingHp returns real
		return 0.1*missingHp + 1.0
	endfunction
	
	private function MaxDuration takes integer level returns real
		return 1.0*level + 1
	endfunction
    
    private function Radius takes integer level returns real
        return 350.0 + 0.0*level
    endfunction
    
    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction
	
	private struct SpellBuff extends Buff

        private effect sfx
		private Movespeed ms

        private static constant integer RAWCODE = 'DH31'
        private static constant integer DISPEL_TYPE = BUFF_POSITIVE
        private static constant integer STACK_TYPE = BUFF_STACK_NONE
        
        method onRemove takes nothing returns nothing
			call this.ms.destroy()
            call DestroyEffect(this.sfx)
			set this.sfx = null
        endmethod

        method onApply takes nothing returns nothing
            set this.sfx = AddSpecialEffectTarget(BUFF_SFX, this.target, "chest")
			set this.ms = Movespeed.create(this.target, 0, 0)
        endmethod
		
		method reapply takes real slow, real newDuration returns nothing
			if newDuration > this.duration then
				set this.duration = newDuration
			endif
			call this.ms.change(slow, 0)
		endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod
        
        implement BuffApply
    endstruct
    
    struct ThunderClap extends array
        
        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local player owner = GetTriggerPlayer()
            local integer lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            local real x = GetUnitX(caster)
            local real y = GetUnitY(caster)
            local group g = NewGroup()
			local Effect e = Effect.createAnyAngle(SFX, x, y, 50)
            local unit u
			set e.scale = Radius(lvl)/300.0
			call AddSpecialEffectTimer(AddSpecialEffectTarget(SFX_RIBBON, caster, "weapon right"), 1.0)
            call GroupUnitsInArea(g, x, y, Radius(lvl))
            loop
                set u = FirstOfGroup(g)
                exitwhen u == null
                call GroupRemoveUnit(g, u)
                if TargetFilter(u, owner) then
					call SpellBuff.add(caster, u).reapply(-MovementSlow(lvl), RMinBJ(MaxDuration(lvl), Duration(100*(1 - GetWidgetLife(u)/GetUnitState(u, UNIT_STATE_MAX_LIFE)))))
                endif
            endloop
            call ReleaseGroup(g)
			call e.destroy()
            set g = null
            set u = null
			set owner = null
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