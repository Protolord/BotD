scope Shadowrun
    
    //Configuration
    globals
        private constant integer SPELL_ID = 'A121'
        private constant integer SPELL_BUFF = 'a121'
    endglobals
    
    private function BonusSpeed takes integer level returns real
        if level == 11 then
            return 1.0
        endif
        return 0.05*level
    endfunction
    
    struct Shadowrun extends array
        
        private unit caster
        private Movespeed ms
        private Invisible inv
        
        private method remove takes nothing returns nothing
            call this.inv.destroy()
            call this.ms.destroy()
            set this.caster = null
            call this.destroy()
        endmethod
        
        implement CTLExpire
            if GetUnitAbilityLevel(this.caster, SPELL_BUFF) == 0 then
                call this.remove()
            endif
        implement CTLEnd
    
        
        private static method onCast takes nothing returns nothing
            local thistype this = thistype.create()
            set this.caster = GetTriggerUnit()
            set this.ms = Movespeed.create(this.caster, BonusSpeed(GetUnitAbilityLevel(this.caster, SPELL_ID)), 0)
            set this.inv = Invisible.create(this.caster, 0)
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope