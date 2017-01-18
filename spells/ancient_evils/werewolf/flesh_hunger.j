scope FleshHunger
    
    globals
        private constant integer SPELL_ID = 'A214'
        private constant integer SPELL_BUFF = 'D214'
        private constant string SFX = "Models\\Effects\\FleshHunger.mdx"
    endglobals
    
    private function SlowDuration takes integer level returns real
        if level == 11 then
            return 20.0
        endif
        return 1.0*level
    endfunction
    
    private function SlowEffect takes integer level returns real
        return -0.85 + 0.0*level
    endfunction
    
    private struct SpellBuff extends Buff
        
        public Movespeed ms
        private effect sfx
        
        method rawcode takes nothing returns integer
            return SPELL_BUFF
        endmethod
        
        method dispelType takes nothing returns integer
            return BUFF_NEGATIVE
        endmethod
        
        method stackType takes nothing returns integer
            return BUFF_STACK_PARTIAL
        endmethod
        
        method onRemove takes nothing returns nothing
            call this.ms.destroy()
            call DestroyEffect(this.sfx)
            set this.sfx = null
        endmethod
        
        method onApply takes nothing returns nothing
            set this.ms = Movespeed.create(this.target, 0, 0)
            set this.sfx = AddSpecialEffectTarget(SFX, this.target, "chest")
        endmethod
        
        implement BuffApply
    endstruct

    struct FleshHunger extends array
        
        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local integer lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            local SpellBuff b = SpellBuff.add(caster, GetSpellTargetUnit())
            set b.duration = SlowDuration(lvl)
            call b.ms.change(SlowEffect(lvl), 0)
            set caster = null
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype on " + GetUnitName(GetSpellTargetUnit()))
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call PreloadSpell(SPELL_BUFF)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope