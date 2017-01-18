scope Dissimulation
  
    //Configuration
    globals
        private constant integer SPELL_ID = 'A421'
        private constant integer SPELL_BUFF = 'a421'
        private constant boolean SILENCE_STACK = false //If true, targeting a silenced unit will result to additive duration
    endglobals
    
    private function BonusSpeed takes integer level returns real
        return 0.0*level + 0.25
    endfunction
    
    private function SilenceDuration takes integer level returns real
        if level == 11 then
            return 20.0
        endif
        return 1.0*level
    endfunction
    //End configuration
    
    struct Dissimulation extends array
        
        private unit caster
        private Movespeed ms
        private Invisible inv
        
        private static group g
        
        private static method onDamage takes nothing returns nothing
            if Damage.type == DAMAGE_TYPE_PHYSICAL and IsUnitInGroup(Damage.source, thistype.g) then
                call Silence.create(Damage.target, SilenceDuration(GetUnitAbilityLevel(Damage.source, SPELL_ID)), SILENCE_STACK)
                call UnitRemoveAbility(Damage.source, SPELL_BUFF)
            endif
        endmethod
        
        private method remove takes nothing returns nothing
            call GroupRemoveUnit(thistype.g, this.caster)
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
            set this.inv = Invisible.create(this.caster, 0)
            set this.ms = Movespeed.create(this.caster, BonusSpeed(GetUnitAbilityLevel(this.caster, SPELL_ID)), 0)
            call GroupAddUnit(thistype.g, this.caster)
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call Damage.register(function thistype.onDamage)
            set thistype.g = CreateGroup()
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope