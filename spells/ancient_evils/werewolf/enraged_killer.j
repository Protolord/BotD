scope EnragedKiller
    
    globals
        private constant integer SPELL_ID = 'A223'
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_SIEGE
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_NORMAL
        private constant string BUFF_SFX = "Models\\Effects\\EnragedKiller.mdx"
    endglobals

    private function Duration takes integer level returns real
        return 5.0 + 0.0*level
    endfunction
    
    private function DamageGrowth takes integer level returns real
        if level == 11 then
            return 12.0
        endif
        return 1.0 + 0.5*level
    endfunction
    
    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u)
    endfunction
    
    private struct SpellBuff extends Buff
        
        private effect sfx
        public real dmg

        private static constant integer RAWCODE = 'D223'
        private static constant integer DISPEL_TYPE = BUFF_NEGATIVE
        private static constant integer STACK_TYPE = BUFF_STACK_PARTIAL
        
        method onRemove takes nothing returns nothing
            call DestroyEffect(this.sfx)
            set this.sfx = null
        endmethod
        
        method onApply takes nothing returns nothing
            set this.dmg = 0
            set this.sfx = AddSpecialEffectTarget(BUFF_SFX, this.target, "overhead")
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod
        
        implement BuffApply
    endstruct
    
    struct EnragedKiller extends array
    
        private static trigger trg

        private static method onDamage takes nothing returns boolean
            local integer level = GetUnitAbilityLevel(Damage.source, SPELL_ID)
            local SpellBuff b
            local textsplat t
            if Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.coded and level > 0 and TargetFilter(Damage.target, GetOwningPlayer(Damage.source)) then
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
            call SpellBuff.initialize()
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope