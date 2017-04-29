scope FrostNova
 
    globals
        private constant integer SPELL_ID = 'AH42'
		private constant string SFX = "Models\\Effects\\FrostNova.mdx"
        private constant string SFX_BUFF = "Abilities\\Spells\\Undead\\FrostArmor\\FrostArmorDamage.mdl" 
		private constant string SFX_TARGET = "Abilities\\Spells\\Undead\\FrostNova\\FrostNovaTarget.mdl"
		private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
    endglobals
    
    private function DamageDealt takes integer level returns real
        if level == 11 then
            return 1200.0
        endif
        return 60.0*level
    endfunction
	
	//In Percent
	private function AttackSlow takes integer level returns real
		return 0.5 + 0*level
	endfunction
	
	private function MoveSlow takes integer level returns real
		return 0.5 + 0.0*level
	endfunction

	private function Radius takes integer level returns real
		return 200.0 + 0.0*level
	endfunction

	private function Duration takes integer level returns real
		if level == 11 then
			return 5.0
		endif
		return 0.5*level
	endfunction
	
	private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction
    
	private struct SpellBuff extends Buff

        private effect sfx
		private VertexColor vc
		private Movespeed ms 
		private Atkspeed as
        
		private static constant integer RAWCODE = 'DH42'
        private static constant integer DISPEL_TYPE = BUFF_NEGATIVE
        private static constant integer STACK_TYPE = BUFF_STACK_PARTIAL
        
        method onRemove takes nothing returns nothing
            call DestroyEffect(this.sfx)
			call this.ms.destroy()
			call this.as.destroy()
			call this.vc.destroy()
            set this.sfx = null
        endmethod
        
        method onApply takes nothing returns nothing
            set this.sfx = AddSpecialEffectTarget(SFX_BUFF, this.target, "chest")
			set this.vc = VertexColor.create(this.target, -200, -50, 255, 0)
			set this.ms = Movespeed.create(this.target, 0, 0)
			set this.as = Atkspeed.create(this.target, 0)
			set this.vc.speed = 500
        endmethod

		method reapply takes integer lvl returns nothing
			call this.ms.change(-MoveSlow(lvl), 0)
			call this.as.change(-AttackSlow(lvl))
		endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod
        
        implement BuffApply
    endstruct
    
    struct FrostNova extends array
		
		private static group g

        private static method onCast takes nothing returns nothing
			local unit caster = GetTriggerUnit()
			local unit target = GetSpellTargetUnit()
			local integer lvl = GetUnitAbilityLevel(caster, SPELL_ID)
			local player owner = GetTriggerPlayer()
			local real x = GetUnitX(target)
			local real y = GetUnitY(target)
			local SpellBuff b
			local Effect e
			local unit u 
			call GroupUnitsInArea(thistype.g, x, y, Radius(lvl))
			loop
				set u = FirstOfGroup(thistype.g)
				exitwhen u == null
				call GroupRemoveUnit(thistype.g, u)
				if TargetFilter(u, owner) then
					call Damage.element.apply(caster, u, DamageDealt(lvl), ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_ICE)
					call DestroyEffect(AddSpecialEffect(SFX_TARGET, GetUnitX(u), GetUnitY(u)))
					set b = SpellBuff.add(caster, u)
					set b.duration = Duration(lvl)
					call b.reapply(lvl)
				endif
			endloop
			set e = Effect.createAnyAngle(SFX, x, y, 0)
			set e.scale = Radius(lvl)/150
			call e.destroy()
			set caster = null 
			set target = null 
			set owner = null
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
			set thistype.g = CreateGroup()
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
			call SpellBuff.initialize()
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope