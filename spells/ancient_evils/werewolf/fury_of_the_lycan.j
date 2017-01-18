scope FuryOfTheLycan

    globals
        private constant integer SPELL_ID = 'A243'
        private constant integer SPELL_BUFF = 'B243'
        private constant string BUFF_SFX = "Models\\Effects\\FuryOfTheLycan.mdx"
    endglobals
    
    private function Duration takes integer level returns real
        return 9.0 + 0.0*level
    endfunction
    
    private struct SpellBuff extends Buff
        private effect sfx
        
        static group g
        
        method rawcode takes nothing returns integer
            return SPELL_BUFF
        endmethod
        
        method dispelType takes nothing returns integer
            return BUFF_NONE
        endmethod
        
        method stackType takes nothing returns integer
            return BUFF_STACK_NONE
        endmethod
        
        method onRemove takes nothing returns nothing
            call GroupRemoveUnit(thistype.g, this.target)
            call DestroyEffect(this.sfx)
            set this.sfx = null
        endmethod
        
        method onApply takes nothing returns nothing
            set this.sfx = AddSpecialEffectTarget(BUFF_SFX, this.target, "origin")
            call GroupAddUnit(thistype.g, this.target)
        endmethod
        
        implement BuffApply
    endstruct
    
    struct FuryOfTheLycan extends array
        implement Alloc
        
        private unit caster

        private static method debuff takes nothing returns nothing
            local thistype this = ReleaseTimer(GetExpiredTimer())
            call UnitRemoveAbility(this.caster, 'Bbsk')
            set this.caster = null
            call this.deallocate()
        endmethod
        
        private static method onDamage takes nothing returns nothing
            if IsUnitInGroup(Damage.target, SpellBuff.g) then
                call Heal.unit(Damage.target, 2.0*Damage.amount, 1)
                set Damage.amount = 0
            endif
        endmethod
        
        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            local unit caster = GetTriggerUnit()
            local SpellBuff b = SpellBuff.add(caster, caster)
            set b.duration = Duration(GetUnitAbilityLevel(caster, SPELL_ID))
            set this.caster = caster
            call TimerStart(NewTimerEx(this), 0.00, false, function thistype.debuff)
            set caster = null
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call Damage.registerModifier(function thistype.onDamage)
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            set SpellBuff.g = CreateGroup()
            call PreloadSpell(SPELL_BUFF)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope