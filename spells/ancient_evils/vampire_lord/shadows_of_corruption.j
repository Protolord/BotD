scope ShadowsOfCorruption
    
    //Configuration
    globals
        private constant integer SPELL_ID = 'A123'
        private constant integer SPELL_BUFF = 'a123'
        private constant integer DEBUFF_ID = 'D123'
        private constant string SFX = "Models\\Effects\\ShadowsOfCorruption.mdx"
    endglobals
    
    private function SlowEffect takes integer level returns real
        return -0.50 + 0.0*level
    endfunction
    
    private function SlowDuration takes integer level returns real
        if level == 11 then
            return 15.0
        endif
        return 5.0 + 0.5*level
    endfunction
    
    private function BonusSpeed takes integer level returns real
        if level == 11 then
            return 0.3
        endif
        return 0.02*level
    endfunction
    
    private struct SpellBuff extends Buff
        
        public Movespeed ms
        private effect sfx
        
        method rawcode takes nothing returns integer
            return DEBUFF_ID
        endmethod
        
        method dispelType takes nothing returns integer
            return BUFF_NEGATIVE
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
    
    struct ShadowsOfCorruption extends array
        
        private unit caster
        private Invisible inv
        private Movespeed ms
        
        private static group g
        
        
        private method remove takes nothing returns nothing
            call GroupRemoveUnit(thistype.g, this.caster)
            call this.inv.destroy()
            call this.ms.destroy()
            set this.caster = null
            call this.destroy()
        endmethod
        
        private static method onDamage takes nothing returns nothing
            local real amount
            local real mana
            local integer lvl
            local SpellBuff b
            if Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.element.coded and IsUnitInGroup(Damage.source, thistype.g) then
                set lvl = GetUnitAbilityLevel(Damage.source, SPELL_ID)
                set b = SpellBuff.add(Damage.source, Damage.target)
                set b.duration = SlowDuration(lvl)
                call b.ms.change(SlowEffect(lvl), 0)
                call UnitRemoveAbility(Damage.source, SPELL_BUFF)
            endif
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
            call GroupAddUnit(thistype.g, this.caster)
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call Damage.register(function thistype.onDamage)
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call PreloadSpell(DEBUFF_ID)
            set thistype.g = CreateGroup()
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope