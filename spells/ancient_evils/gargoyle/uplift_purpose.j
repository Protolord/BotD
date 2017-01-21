scope UpliftPurpose

    globals
        private constant integer SPELL_ID = 'A621'
        private constant integer BUFF_ID = 'B621'
        private constant string SFX = ""
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
    endglobals
    
    private function HPSacrifice takes integer level returns real
        if level == 11 then
            return 0.20
        endif
        return 0.01*level
    endfunction

    private function Duration takes integer level returns real
        return 0.0*level + 10
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p)
    endfunction

    private struct SpellBuff extends Buff
     
        private effect sfx
        public real dmg
        
        method rawcode takes nothing returns integer
            return BUFF_ID
        endmethod
        
        method dispelType takes nothing returns integer
            return BUFF_NEGATIVE
        endmethod
        
        method stackType takes nothing returns integer
            return BUFF_STACK_FULL
        endmethod
        
        method onRemove takes nothing returns nothing
            call DestroyEffect(this.sfx)
            set this.sfx = null
        endmethod
        
        method onApply takes nothing returns nothing
            set this.sfx = AddSpecialEffectTarget(SFX, this.target, "origin")
        endmethod
        
        implement BuffApply
    endstruct
    
    struct UpliftPurpose extends array
        
        private static trigger trg

        private static method onDamage takes nothing returns boolean
            local player p
            if Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.element.coded and GetUnitAbilityLevel(Damage.source, BUFF_ID) > 0 then
                set p = GetOwningPlayer(Damage.source)
                call DisableTrigger(thistype.trg)
                implement BuffListStart
                    if Buff.picked.getType() == SpellBuff.typeid then
                        if TargetFilter(Buff.picked.target, p) then
                            call Damage.apply(Damage.source, Damage.target, SpellBuff(Buff.picked).dmg, ATTACK_TYPE, DAMAGE_TYPE)
                            call FloatingTextSplat(Element.string(DAMAGE_ELEMENT_EARTH) + "+" + I2S(R2I(SpellBuff(Buff.picked).dmg + 0.5)) + "|r", Damage.target, 1.0).setVisible(GetLocalPlayer() == GetOwningPlayer(Damage.source))
                            call Buff.picked.remove()
                        endif
                    endif
                implement BuffListEnd
                call EnableTrigger(thistype.trg)
            endif
            set p = null
            return false
        endmethod
        
        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local integer lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            local real bonus = HPSacrifice(lvl)*GetUnitState(caster, UNIT_STATE_MAX_LIFE)
            local real hp = GetWidgetLife(caster)
            local SpellBuff b 
            if hp > bonus then
                call SetWidgetLife(caster, hp - bonus)
                set b = SpellBuff.add(caster, caster)
                set b.duration = Duration(lvl)
                set b.dmg = bonus
            else
                call Damage.kill(caster, caster)
            endif
            set caster = null
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            set thistype.trg = CreateTrigger()
            call Damage.registerTrigger(thistype.trg)
            call TriggerAddCondition(thistype.trg, function thistype.onDamage)
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call PreloadSpell(BUFF_ID)
            call SystemTest.end()
        endmethod
        
    endstruct
endscope
