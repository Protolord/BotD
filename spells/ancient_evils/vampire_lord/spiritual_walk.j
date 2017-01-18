scope SpiritualWalk
    
    //Configuration
    globals
        private constant integer SPELL_ID = 'A122'
        private constant integer SPELL_BUFF = 'a122'
    endglobals
    
    private function StealMana takes integer level returns real
        if level == 11 then
            return 0.5
        endif
        return 0.15 + 0.02*level
    endfunction    
    
    private function BonusSpeed takes integer level returns real
        if level == 11 then
            return 0.3
        endif
        return 0.02*level
    endfunction
    
    struct SpiritualWalk extends array
        
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
            if Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.element.coded and IsUnitInGroup(Damage.source, thistype.g) then
                set mana = GetUnitState(Damage.target, UNIT_STATE_MANA)
                set amount = StealMana(GetUnitAbilityLevel(Damage.source, SPELL_ID))*GetUnitState(Damage.target, UNIT_STATE_MAX_MANA)
                if mana < amount then
                    set amount = mana
                endif
                if amount > 0 then
                    call SetUnitState(Damage.target, UNIT_STATE_MANA, mana - amount)
                    call SetUnitState(Damage.source, UNIT_STATE_MANA, GetUnitState(Damage.source, UNIT_STATE_MANA) + amount)
                    call FloatingTextTag("|cff0099ff-" + I2S(R2I(amount)) + "|r", Damage.target, 2.5)
                endif
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
            set this.inv = Invisible.create(this.caster, 0)
            set this.ms = Movespeed.create(this.caster, BonusSpeed(GetUnitAbilityLevel(this.caster, SPELL_ID)), 0)
            call GroupAddUnit(thistype.g, this.caster)
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call Damage.register(function thistype.onDamage)
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            set thistype.g = CreateGroup()
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope