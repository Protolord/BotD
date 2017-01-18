scope BloodExtremity
    
    globals
        private constant integer SPELL_ID = 'A143'
        private constant string HEAL_EFFECT = "Abilities\\Spells\\Undead\\DeathCoil\\DeathCoilSpecialArt.mdl"
        private constant string LIGHT = "HWPB"
        private constant real TIMEOUT = 0.03125000
        private constant real DELAY = 0.75
    endglobals
    
    private function HealAmount takes integer level returns real
        if level == 11 then
            return 14000.0
        endif
        return 700.0*level
    endfunction
    
    struct BloodExtremity extends array
        implement Alloc
        
        private lightning l
        private unit caster
        private unit target
        private real duration
        
        private method destroy takes nothing returns nothing
            call DestroyLightning(this.l)
            set this.l = null
            set this.caster = null
            set this.target = null
            call this.deallocate()
        endmethod
        
        private static method expire takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            set this.duration = this.duration - TIMEOUT
            if this.duration > 0 then
                call MoveLightning(this.l, true, GetUnitX(this.caster), GetUnitY(this.caster), GetUnitX(this.target), GetUnitY(this.target))
            else
                call ReleaseTimer(GetExpiredTimer())
                call this.destroy()
            endif
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            set this.target = GetSpellTargetUnit()
            set this.caster = GetTriggerUnit()
            call Heal.unit(this.target, HealAmount(GetUnitAbilityLevel(this.caster, SPELL_ID)), 4)
            set this.l = AddLightning(LIGHT, true, GetUnitX(this.caster), GetUnitY(this.caster), GetUnitX(this.target), GetUnitY(this.target))
            call SetLightningColor(this.l, 1, 0.25, 0.25, 1)
            call DestroyEffect(AddSpecialEffectTarget(HEAL_EFFECT, target, "origin"))
            set this.duration = DELAY
            call TimerStart(NewTimerEx(this), TIMEOUT, true, function thistype.expire)
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope