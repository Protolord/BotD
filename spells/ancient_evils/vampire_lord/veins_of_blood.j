scope VeinsOfBlood
    
    globals
        private constant integer SPELL_ID = 'A141'
        private constant integer SPELL_BUFF = 'B141'
        private constant string BUFF_SFX = "Models\\Effects\\VeinsOfBlood.mdx"
        private constant real TIMEOUT = 1.0
    endglobals
    
    private function HealPerSecond takes integer level returns real
        if level == 11 then
            return 1200.0
        endif
        return 600.0 + 0.0*level
    endfunction
    
    private function Duration takes integer level returns real
        if level == 11 then
            return 10.0
        endif
        return 1.0*level
    endfunction
    
    private struct SpellBuff extends Buff
        
        private timer t
        private effect sfx
        public real heal
        
        method raw takes nothing returns integer
            return SPELL_BUFF
        endmethod
        
        method dispelType takes nothing returns integer
            return BUFF_POSITIVE
        endmethod
        
        method stackType takes nothing returns integer
            return BUFF_STACK_FULL
        endmethod
        
        method onRemove takes nothing returns nothing
            call ReleaseTimer(this.t)
            call DestroyEffect(this.sfx)
            set this.sfx = null
            set this.t = null
        endmethod
        
        static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            call Heal.unit(this.target, this.heal, 4)
        endmethod
        
        method onApply takes nothing returns nothing
            set this.t = NewTimerEx(this)
            set this.sfx = AddSpecialEffectTarget(BUFF_SFX, this.target, "origin")
            call TimerStart(this.t, TIMEOUT, true, function thistype.onPeriod)
        endmethod
        
        implement BuffApply
    endstruct
    
    struct VeinsOfBlood extends array
        implement Alloc
        
        private unit caster
        
        private static method debuff takes nothing returns nothing
            local thistype this = ReleaseTimer(GetExpiredTimer())
            call UnitRemoveAbility(this.caster, 'Bbsk')
            set this.caster = null
            call this.deallocate()
        endmethod
        
        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            local unit caster = GetTriggerUnit()
            local integer lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            local SpellBuff b = SpellBuff.add(caster, caster)
            set b.duration = Duration(lvl)
            set b.heal = HealPerSecond(lvl)*TIMEOUT
            set this.caster = caster
            call TimerStart(NewTimerEx(this), 0.00, false, function thistype.debuff)
            set caster = null
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call PreloadSpell(SPELL_BUFF)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope