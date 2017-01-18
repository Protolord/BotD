scope EngulfedFires
 
    globals
        private constant integer SPELL_ID = 'A544'
        private constant integer BUFF_ID = 'B544'
        private constant string SFX = "Models\\Effects\\EngulfedFires.mdx"
    endglobals
    
    private function Duration takes integer level returns real
        if level == 11 then
        endif
        return 0.5*level + 5.0
    endfunction
    
    private struct SpellBuff extends Buff
        
        private effect sfx
        private real hp
        private trigger trg
        
        public static Table tb
        
        method rawcode takes nothing returns integer
            return BUFF_ID
        endmethod
        
        method dispelType takes nothing returns integer
            return BUFF_POSITIVE
        endmethod
        
        method stackType takes nothing returns integer
            return BUFF_STACK_NONE
        endmethod
        
        method onRemove takes nothing returns nothing
            call Damage.add(this.target)
            call DestroyTrigger(this.trg)
            call DestroyEffect(this.sfx)
            set this.trg = null
            set this.sfx = null
        endmethod
        
        private static method onChange takes nothing returns boolean
            local thistype this = thistype.tb[GetHandleId(GetTriggeringTrigger())]
            call SetWidgetLife(this.target, this.hp)
            return false
        endmethod
        
        method onApply takes nothing returns nothing
            call Damage.remove(this.target)
            set this.sfx = AddSpecialEffectTarget(SFX, this.target, "origin")
            set this.hp = I2R(R2I(GetWidgetLife(this.target))) + 0.5
            set this.trg = CreateTrigger()
            call TriggerRegisterUnitStateEvent(this.trg, this.target, UNIT_STATE_LIFE, LESS_THAN, this.hp - 0.1 )
            call TriggerRegisterUnitStateEvent(this.trg, this.target, UNIT_STATE_LIFE, GREATER_THAN, this.hp + 0.1)
            call TriggerAddCondition(this.trg, function thistype.onChange)
            call SetWidgetLife(this.target, this.hp)
            set thistype.tb[GetHandleId(this.trg)] = this
        endmethod
        
        implement BuffApply
    endstruct
    
    struct EngulfedFires extends array
        implement Alloc
        
        private unit u
        
        private static method expires takes nothing returns nothing
            local thistype this = ReleaseTimer(GetExpiredTimer())
            call UnitRemoveAbility(this.u, 'Bbsk')
            set this.u = null
        endmethod
        
        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            local unit caster = GetTriggerUnit()
            local integer lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            local SpellBuff b = SpellBuff.add(caster, caster)
            set b.duration = Duration(lvl)
            set this.u = caster
            call TimerStart(NewTimerEx(this), 0.00, false, function thistype.expires)
            set caster = null
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            set SpellBuff.tb = Table.create()
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope