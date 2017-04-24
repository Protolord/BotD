scope Testudo
 
    globals
        private constant integer SPELL_ID = 'A821'
        private constant integer UNIT_ID = 'UTCT'
        private constant real DELAY = 1.0
        private constant string SFX = "Abilities\\Spells\\Orc\\Voodoo\\VoodooAura.mdl"
    endglobals

    private function ArmorBonus takes integer level returns integer
        if level == 11 then
            return 300
        endif
        return 30*level
    endfunction
	
	private function SpellResistBonus takes integer level returns real
		if level == 11 then
			return 0.0  //Spell Immunity will be added instead
		endif
		return 50.0
	endfunction

    private struct SpellBuff extends Buff

		private integer lvl
        private effect sfx
        private Armor a
		//private SpellResist sr
        //private SpellImmune si

        private static constant integer RAWCODE = 'B821'
        private static constant integer DISPEL_TYPE = BUFF_NONE
        private static constant integer STACK_TYPE = BUFF_STACK_NONE
        
        method onRemove takes nothing returns nothing
            call DestroyEffect(this.sfx)
			if this.lvl == 11 then
                //call this.si.destroy()
            else
				//call this.sr.destroy()
			endif
			call this.a.destroy()
            set this.sfx = null
        endmethod
        
        method onApply takes nothing returns nothing
            set this.lvl = GetUnitAbilityLevel(this.target, SPELL_ID)
            set this.sfx = AddSpecialEffectTarget(SFX, this.target, "origin")
			set this.a = Armor.create(this.target, ArmorBonus(this.lvl))
			if lvl == 11 then
                //set this.si = SpellImmune.create(this.target)
            else
				//set this.sr = SpellResist.create(this.target, SpellResistBonus(this.lvl))
			endif
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod
        
        implement BuffApply
    endstruct
    
    struct Testudo extends array
        implement Alloc

        private unit caster
        private SpellBuff b

        private static Table tb

        private method destroy takes nothing returns nothing
            call thistype.tb.remove(GetHandleId(this.caster))
            call this.b.remove()
            set this.caster = null
            call this.deallocate()
        endmethod

        private static method expire takes nothing returns nothing
            local thistype this = ReleaseTimer(GetExpiredTimer())
            set this.b = SpellBuff.add(this.caster, this.caster)
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            local unit u = GetTriggerUnit()
            local integer id = GetHandleId(u)
            if GetUnitTypeId(u) == 'UCav' then
                set this = thistype.allocate()
                set this.caster = u
			    set thistype.tb[id] = this
                call SetUnitAnimation(this.caster, "spell slam")
                call TimerStart(NewTimerEx(this), DELAY, false, function thistype.expire)
                call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " activates thistype")
            elseif GetUnitTypeId(u) == UNIT_ID and thistype.tb.has(id) then
                call thistype(thistype.tb[id]).destroy()
                call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " deactivates thistype")
            endif
            set u = null
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            set thistype.tb = Table.create()
            call PreloadUnit(UNIT_ID)
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SpellBuff.initialize()
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope