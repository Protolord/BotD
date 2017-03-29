
scope InfernalChains
    
    globals
        private constant integer SPELL_ID = 'A523'
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_CHAOS //Changing it may not properly affect buildings
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_UNIVERSAL
        private constant string BUFF_SFX = "Models\\Effects\\InfernalChains.mdx"
    endglobals

    //Damage is a percentage of target's max hp
    private function DamageGrowth takes integer level returns real
        if level == 11 then
            return 0.20
        endif
        return 0.10 + 0.0*level
    endfunction

    private function MaxDamage takes integer level returns real
        if level == 11 then
            return 1.0
        endif
        return 0.10*level
    endfunction

    //In percent
    private function Chance takes integer level returns real
        if level == 11 then
            return 100.0//1.0
        endif
        return 100.0//1.0
    endfunction
    
    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitType(u, UNIT_TYPE_STRUCTURE)
    endfunction
    
    private struct SpellBuff extends Buff
        
        private effect sfx
        public real dmg

        private static constant integer RAWCODE = 'D523'
        private static constant integer DISPEL_TYPE = BUFF_NONE
        private static constant integer STACK_TYPE = BUFF_STACK_PARTIAL
        
        method onRemove takes nothing returns nothing
            call DestroyEffect(this.sfx)
            set this.sfx = null
        endmethod
        
        method onApply takes nothing returns nothing
            set this.dmg = DamageGrowth(GetUnitAbilityLevel(this.source, SPELL_ID))
            set this.sfx = AddSpecialEffectTarget(BUFF_SFX, this.target, "origin")
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod
        
        implement BuffApply
    endstruct
    
    struct InfernalChains extends array
    
        private static trigger trg

        private static method onDamage takes nothing returns boolean
            local integer level = GetUnitAbilityLevel(Damage.source, SPELL_ID)
            local SpellBuff b
            local textsplat t
            local real dmg
            if Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.coded and level > 0 and GetRandomReal(0, 100) <= Chance(level) and TargetFilter(Damage.target, GetOwningPlayer(Damage.source)) then
                set b = SpellBuff.add(Damage.source, Damage.target)
                //Deal extra damage
                if b.dmg <= MaxDamage(level) then
                    set dmg = b.dmg*GetUnitState(Damage.target, UNIT_STATE_MAX_LIFE)
                    call DisableTrigger(thistype.trg)
                    call Damage.apply(Damage.source, Damage.target, dmg, ATTACK_TYPE, DAMAGE_TYPE)
                    call EnableTrigger(thistype.trg)
                    set t = FloatingTextSplatEx(Element.string(DAMAGE_ELEMENT_FIRE) + "+" + I2S(R2I(dmg + 0.5)) + "|r", Damage.target, 1.0, 250.0)
                    call t.setVisible(GetLocalPlayer() == GetOwningPlayer(Damage.source) and IsUnitVisible(Damage.source, GetLocalPlayer()))
                    set b.dmg = b.dmg + DamageGrowth(level)
                endif
            endif
            return false
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            set thistype.trg = CreateTrigger()
            call Damage.registerTrigger(thistype.trg)
            call TriggerAddCondition(thistype.trg, function thistype.onDamage)
            call SpellBuff.initialize()
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope