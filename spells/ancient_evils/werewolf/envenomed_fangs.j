scope EnvenomedFangs

    globals
        private constant integer SPELL_ID = 'A211'
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
		private constant string BUFF_SFX = "Abilities\\Spells\\Undead\\Curse\\CurseTarget.mdl"
    endglobals

    private function Duration takes integer level returns real
        if level == 11 then
            return 20.0
        endif
        return 1.0*level
    endfunction
    
    private function DamagePerSecond takes integer level returns real
        if level == 11 then
            return 150.0
        endif
        return 100.0 + 0.0*level
    endfunction
    
    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction
    
    private struct SpellBuff extends Buff
     
		private effect sfx
        private timer t
        public real dmg
        
        private static constant integer RAWCODE = 'D211'
        private static constant integer DISPEL_TYPE = BUFF_NEGATIVE
        private static constant integer STACK_TYPE = BUFF_STACK_PARTIAL
        
        method onRemove takes nothing returns nothing
			call DestroyEffect(this.sfx)
            call ReleaseTimer(this.t)
            set this.t = null
			set this.sfx = null
        endmethod
        
        static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            if TargetFilter(this.target, GetOwningPlayer(this.source)) then
                call Damage.element.apply(this.source, this.target, this.dmg, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_POISON)
            endif
        endmethod
        
        method onApply takes nothing returns nothing
            set this.t = NewTimerEx(this)
			set this.sfx = AddSpecialEffectTarget(BUFF_SFX, this.target, "chest")
            call TimerStart(this.t, 1.00, true, function thistype.onPeriod)
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod
        
        implement BuffApply
    endstruct
    
    struct EnvenomedFangs extends array
        
        private static method onDamage takes nothing returns nothing
            local integer level = GetUnitAbilityLevel(Damage.source, SPELL_ID)
            local SpellBuff b
            
            if level > 0 and Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.element.coded and TargetFilter(Damage.target, GetOwningPlayer(Damage.source))  then
                set b = SpellBuff.add(Damage.source, Damage.target)
                set b.dmg = DamagePerSecond(level)
                set b.duration = Duration(level)
            endif
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call Damage.register(function thistype.onDamage)
            call SpellBuff.initialize()
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope