scope Bloodlust
    
    globals
        private constant integer SPELL_ID = 'A824'
        private constant string BUFF_SFX = "Abilities\\Spells\\Orc\\Bloodlust\\BloodlustTarget.mdl"
        private constant real LIMIT = 500.0
    endglobals

    private function Duration takes integer level returns real
        if level == 11 then
            return 30.0
        endif
        return 10.0
    endfunction
    
	//Speed Growth when unit is hit
    private function UnitGrowth takes integer level returns real
        if level == 11 then
            return 0.05 //5%
        endif
        return 0.005*level //0.5%
    endfunction
	
	//Speed Growth when building is hit
	private function StructureGrowth takes integer level returns real
        if level == 11 then
            return 0.005 //0.5%
        endif
        return 0.0005*level //0.05%
    endfunction
    
    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p)
    endfunction
    
    private struct SpellBuff extends Buff
        
        private effect sfx1
        private effect sfx2
        private effect sfx3
        private effect sfx4
        public real bonus
        readonly Atkspeed as
		readonly Movespeed ms

        private static constant integer RAWCODE = 'B824'
        private static constant integer DISPEL_TYPE = BUFF_POSITIVE
        private static constant integer STACK_TYPE = BUFF_STACK_NONE
        
        method onRemove takes nothing returns nothing
            call DestroyEffect(this.sfx1)
            call DestroyEffect(this.sfx2)
            call DestroyEffect(this.sfx3)
            call DestroyEffect(this.sfx4)
            call this.as.destroy()
			call this.ms.destroy()
            set this.sfx1 = null
            set this.sfx2 = null
            set this.sfx3 = null
            set this.sfx4 = null
        endmethod
        
        method onApply takes nothing returns nothing
            set this.bonus = 0
            set this.as = Atkspeed.create(this.target, 0)
			set this.ms = Movespeed.create(this.target, 0, 0)
            set this.sfx1 = AddSpecialEffectTarget(BUFF_SFX, this.target, "hand right")
            set this.sfx2 = AddSpecialEffectTarget(BUFF_SFX, this.target, "hand left")
            set this.sfx3 = AddSpecialEffectTarget(BUFF_SFX, this.target, "foot right")
            set this.sfx4 = AddSpecialEffectTarget(BUFF_SFX, this.target, "foot left")
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod
        
        implement BuffApply
    endstruct
    
    struct Bloodlust extends array
    
        private static trigger trg

        private static method onDamage takes nothing returns boolean
            local integer level = GetUnitAbilityLevel(Damage.source, SPELL_ID)
			local SpellBuff b
            if Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.coded and level > 0 and TargetFilter(Damage.target, GetOwningPlayer(Damage.source)) then
                set b = SpellBuff.add(Damage.source, Damage.source)
                set b.duration = Duration(level)
				if IsUnitType(Damage.target, UNIT_TYPE_STRUCTURE) then
					set b.bonus = b.bonus + StructureGrowth(level)
				else
					set b.bonus = b.bonus + UnitGrowth(level)
				endif
                if b.bonus > LIMIT then
                    set b.bonus = LIMIT
                endif
                call b.as.change(b.bonus)
				call b.ms.change(b.bonus, 0)
            endif
            return false
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            set thistype.trg = CreateTrigger()
            call Damage.registerTrigger(thistype.trg)
            call TriggerAddCondition(thistype.trg, function thistype.onDamage)
            call SpellBuff.initialize()
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope