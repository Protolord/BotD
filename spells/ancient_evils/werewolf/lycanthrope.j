scope Lycanthrope
    
    globals
        private constant integer SPELL_ID = 'A224'
        private constant integer SPELL_BUFF = 'B224'
        private constant string BUFF_SFX = "Abilities\\Spells\\NightElf\\BattleRoar\\RoarTarget.mdl"
        private constant string CAST_SFX = "Models\\Effects\\LycanthropeEffect.mdx"
        private constant string BUFF_SFX2 = "Abilities\\Spells\\Orc\\Bloodlust\\BloodLustSpecial.mdl"
    endglobals
    
    private function Duration takes integer level returns real
        if level == 11 then
            return 10.0
        endif
        return 0.5*level
    endfunction
    
    private struct SpellBuff extends Buff
        
        private effect sfx
        private effect handLeft
        private effect handRight
        
        method rawcode takes nothing returns integer
            return SPELL_BUFF
        endmethod
        
        method dispelType takes nothing returns integer
            return BUFF_POSITIVE
        endmethod
        
        method stackType takes nothing returns integer
            return BUFF_STACK_NONE
        endmethod
        
        method onRemove takes nothing returns nothing
            call UnitRemoveAbility(this.target, 'a224')
            //call UnitAddAbility(this.target, SHAPESHIFT_ID)
            call DestroyEffect(this.sfx)
            call DestroyEffect(this.handLeft)
            call DestroyEffect(this.handRight)
            set this.sfx = null
            set this.handLeft = null
            set this.handRight = null
        endmethod
        
        method onApply takes nothing returns nothing
            set this.sfx = AddSpecialEffectTarget(BUFF_SFX, this.target, "overhead")
            set this.handLeft = AddSpecialEffectTarget(BUFF_SFX2, this.target, "hand left")
            set this.handRight = AddSpecialEffectTarget(BUFF_SFX2, this.target, "hand right")
            //call UnitRemoveAbility(this.target, SHAPESHIFT_ID)
        endmethod
        
        implement BuffApply
    endstruct
    
    struct Lycanthrope extends array
        
        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local thistype id = GetUnitTypeId(caster)
            local SpellBuff b
            if id == 'UWeW' or id == 'UWeH' then
                set b = SpellBuff.add(caster, caster)
                set b.duration = Duration(GetUnitAbilityLevel(caster, SPELL_ID))
                call DestroyEffect(AddSpecialEffect(CAST_SFX, GetUnitX(caster), GetUnitY(caster)))
                call SystemMsg.create(GetUnitName(caster) + " cast thistype")
            endif
            set caster = null
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call PreloadSpell(SPELL_BUFF)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope