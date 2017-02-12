scope Reaper
    
    globals
        private constant integer SPELL_ID = 'A712'
        private constant integer SPELL_BUFF = 'D712'
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_UNIVERSAL
        private constant string BUFF_SFX = "Models\\Effects\\EnragedKiller.mdx"
    endglobals

    private function Duration takes integer level returns real
        if level == 11 then
            return 30.0
        endif
        return 10.0 + 2.0*level
    endfunction
    
    private function DamageGrowth takes integer level returns real
        if level == 11 then
            return 20.0
        endif
        return 10.0 + 0.0*level
    endfunction
    
    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u)
    endfunction
    
    private struct SpellBuff extends Buff
        
        private effect sfx
        public real dmg
        
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
            call DestroyEffect(this.sfx)
            set this.sfx = null
        endmethod
        
        method onApply takes nothing returns nothing
            set this.dmg = 0
            set this.sfx = AddSpecialEffectTarget(BUFF_SFX, this.target, "overhead")
        endmethod
        
        implement BuffApply
    endstruct
    
    struct Reaper extends array
    
        private static trigger trg

        private static method onDamage takes nothing returns boolean
            local integer level = GetUnitAbilityLevel(Damage.source, SPELL_ID)
            local SpellBuff b
            local textsplat t
            if Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.element.coded and level > 0 and TargetFilter(Damage.target, GetOwningPlayer(Damage.source)) then
                set b = SpellBuff.add(Damage.source, Damage.target)
                set b.duration = Duration(level)
                //Deal extra damage
                if b.dmg > 0 then
                    call DisableTrigger(thistype.trg)
                    call Damage.apply(Damage.source, Damage.target, b.dmg, ATTACK_TYPE, DAMAGE_TYPE)
                    call EnableTrigger(thistype.trg)
                    set t = FloatingTextSplat(Element.string(DAMAGE_ELEMENT_NORMAL) + "+" + I2S(R2I(b.dmg + 0.5)) + "|r", Damage.target, 1.0)
                    call t.setVisible(GetLocalPlayer() == GetOwningPlayer(Damage.source) and IsUnitVisible(Damage.source, GetLocalPlayer()))
                endif
                set b.dmg = b.dmg + DamageGrowth(level)
            endif
            return false
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            set thistype.trg = CreateTrigger()
            call Damage.registerTrigger(thistype.trg)
            call TriggerAddCondition(thistype.trg, function thistype.onDamage)
            call PreloadSpell(SPELL_BUFF)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope