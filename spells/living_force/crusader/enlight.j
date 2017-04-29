scope Enlight
 
    globals
        private constant integer SPELL_ID = 'AH22'
        private constant string SFX = "Abilities\\Spells\\Human\\HolyBolt\\HolyBoltSpecialArt.mdl"
        private constant string SFX_BUFF = "Abilities\\Spells\\Items\\StaffOfSanctuary\\Staff_Sanctuary_Target.mdl"
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
    endglobals
    
    private function BaseDamage takes integer level returns real
        return 25.0 + 0.0*level
    endfunction

    private function ExtraDamage takes integer level returns real
        return 25.0 + 0.0*level
    endfunction

    private function Duration takes integer level returns real
        if level == 11 then
            return 6.0
        endif
        return 0.3*level
    endfunction
	
	private struct SpellBuff extends Buff

        private effect sfx

        private static constant integer RAWCODE = 'DH22'
        private static constant integer DISPEL_TYPE = BUFF_NEGATIVE
        private static constant integer STACK_TYPE = BUFF_STACK_NONE
        
        method onRemove takes nothing returns nothing
			call DestroyEffect(this.sfx)
            set this.sfx = null
        endmethod
        
        method onApply takes nothing returns nothing
			set this.sfx = AddSpecialEffectTarget(SFX_BUFF, this.target, "chest")
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod
        
        implement BuffApply
    endstruct
    
    struct Enlight extends array
		
        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local unit target = GetSpellTargetUnit()
            local SpellBuff b = Buff.get(null, target, SpellBuff.typeid)
            local integer level = GetUnitAbilityLevel(caster, SPELL_ID)
            local Lightning l = Lightning.createUnits("HWSB", caster, target)
            set l.duration = 0.4
            call l.startColor(1.0, 1.0, 1.0, 0.8)
            call l.endColor(1.0, 1.0, 1.0, 0.1)
            if b > 0 then
                call Damage.element.apply(caster, target, BaseDamage(level) + b.duration*ExtraDamage(level), ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_FIRE)
                set b.duration = b.duration + Duration(level)
            else
                call Damage.element.apply(caster, target, BaseDamage(level), ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_FIRE)
			    set SpellBuff.add(caster, target).duration = Duration(level)
            endif
            call DestroyEffect(AddSpecialEffectTarget(SFX, target, "chest"))
            set caster = null 
            set target = null
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