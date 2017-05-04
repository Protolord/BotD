scope BrainSap
    
    globals
        private constant integer SPELL_ID = 'A313'
        private constant string SFX_CASTER = "Models\\Effects\\BrainSapSource.mdx"
        private constant string SFX_TARGET = "Models\\Effects\\BrainSapTarget.mdx"
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
    endglobals
    
    private function Amount takes integer level returns real
        if level == 11 then
            return 1500.0
        endif
        return 75.0*level
    endfunction
    
    struct BrainSap extends array
        
        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local unit target = GetSpellTargetUnit()
            local real amount = Amount(GetUnitAbilityLevel(caster, SPELL_ID))
            call Damage.element.apply(caster, target, amount, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_SPIRIT)
            call Heal.unit(caster, caster, RMinBJ(amount, GetWidgetLife(target)), 1.0, true)
            call DestroyEffect(AddSpecialEffectTarget(SFX_CASTER, caster, "origin"))
            call DestroyEffect(AddSpecialEffectTarget(SFX_TARGET, target, "origin"))
            set caster = null
            set target = null
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype on " + GetUnitName(GetSpellTargetUnit()))
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope