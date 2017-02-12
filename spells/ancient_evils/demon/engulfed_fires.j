scope EngulfedFires
 
    globals
        private constant integer SPELL_ID = 'A544'
        private constant integer BUFF_ID = 'B544'
        private constant string SFX = "Models\\Effects\\EngulfedFires.mdx"
        private constant integer SET_MAX_LIFE = 'ASML'
    endglobals
    
    private function Duration takes integer level returns real
        if level == 11 then
            return 20.0
        endif
        return 0.5*level + 5.0
    endfunction
    
    private struct SpellBuff extends Buff
        
        private effect sfx
        private real hp
        private boolean added
        private trigger trg
        private trigger dmgTrg
        
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
            call thistype.tb.remove(GetHandleId(this.dmgTrg))
            call thistype.tb.remove(GetHandleId(this.trg))
            call DestroyTrigger(this.dmgTrg)
            call DestroyTrigger(this.trg)
            call DestroyEffect(this.sfx)
            set this.trg = null
            set this.sfx = null
        endmethod
        
        private static method onChange takes nothing returns boolean
            local thistype this = thistype.tb[GetHandleId(GetTriggeringTrigger())]
            if this.added then
                call UnitRemoveAbility(this.target, SET_MAX_LIFE)
                set this.added = false
            endif
            call SetWidgetLife(this.target, this.hp)
            return false
        endmethod

        private static method onDamage takes nothing returns boolean
            local thistype this = thistype.tb[GetHandleId(GetTriggeringTrigger())]
            local real amount = GetEventDamage()
            if amount > this.hp then
                call DisableTrigger(this.trg)
                call UnitAddAbility(this.target, SET_MAX_LIFE)
                call SetWidgetLife(this.target, this.hp + amount)
                call EnableTrigger(this.trg)
                set this.added = true
            endif
            return false
        endmethod
        
        method onApply takes nothing returns nothing
            call Damage.remove(this.target)
            set this.sfx = AddSpecialEffectTarget(SFX, this.target, "origin")
            set this.hp = RMinBJ(I2R(R2I(GetWidgetLife(this.target))) + 0.5, GetUnitState(this.target, UNIT_STATE_MAX_LIFE))
            set this.added = false
            set this.dmgTrg = CreateTrigger()
            set this.trg = CreateTrigger()
            call TriggerRegisterUnitEvent(this.dmgTrg, this.target, EVENT_UNIT_DAMAGED)
            call TriggerAddCondition(this.dmgTrg, function thistype.onDamage)
            call TriggerRegisterUnitStateEvent(this.trg, this.target, UNIT_STATE_LIFE, LESS_THAN, this.hp - 0.1 )
            call TriggerRegisterUnitStateEvent(this.trg, this.target, UNIT_STATE_LIFE, GREATER_THAN, this.hp + 0.1)
            call TriggerAddCondition(this.trg, function thistype.onChange)
            call SetWidgetLife(this.target, this.hp)
            set thistype.tb[GetHandleId(this.dmgTrg)] = this
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