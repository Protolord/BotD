scope Regency
    
    globals
        private constant integer SPELL_ID = 'A741'
        private constant string BUFF_SFX = ""
        private constant real TIMEOUT = 0.03125
    endglobals
    
    private function Duration takes integer level returns real
        if level == 11 then
            return 100.0
        endif
        return 10.0*level
    endfunction

    private function MaxCharges takes integer level returns integer
        if level == 11 then
            return 300
        endif
        return 200
    endfunction
    
    private function TargetFilter takes unit u, player p returns boolean
        return IsUnitEnemy(u, p)
    endfunction

    private struct SpellBuff extends Buff
        
        private effect sfx
        private real hp
        private trigger trg
        private trigger dmgTrg
        private integer charges
        private textsplat ts

        private static Table tb
        

        private static constant integer RAWCODE = 'B741'
        private static constant integer DISPEL_TYPE = BUFF_POSITIVE
        private static constant integer STACK_TYPE = BUFF_STACK_NONE
        
        method onRemove takes nothing returns nothing
            call this.pop()
            call thistype.tb.remove(GetHandleId(this.dmgTrg))
            call thistype.tb.remove(GetHandleId(this.trg))
            call this.ts.destroy()
            call DestroyTrigger(this.dmgTrg)
            call DestroyTrigger(this.trg)
            call DestroyEffect(this.sfx)
            set this.dmgTrg = null
            set this.trg = null
            set this.sfx = null
        endmethod
        
        private static method onChange takes nothing returns boolean
            local thistype this = thistype.tb[GetHandleId(GetTriggeringTrigger())]
            local real newHp = GetWidgetLife(this.target)
            call thistype.tb.remove(GetHandleId(this.trg))
            call DestroyTrigger(this.trg)
            call SetWidgetLife(this.target, newHp + this.charges*(newHp - this.hp)/100.0)
            set this.trg = CreateTrigger()
            set this.hp = GetWidgetLife(this.target)
            call TriggerRegisterUnitStateEvent(this.trg, this.target, UNIT_STATE_LIFE, GREATER_THAN, this.hp + 0.25)
            call TriggerAddCondition(this.trg, function thistype.onChange)
            set thistype.tb[GetHandleId(this.trg)] = this
            return false
        endmethod

        private static method expires takes nothing returns nothing
            local SpellBuff this = ReleaseTimer(GetExpiredTimer())
            set this.charges = this.charges - 1
        endmethod

        private static method enable takes nothing returns nothing
            local thistype this = ReleaseTimer(GetExpiredTimer())
            set this.trg = CreateTrigger()
            set this.hp = GetWidgetLife(this.target)
            call TriggerRegisterUnitStateEvent(this.trg, this.target, UNIT_STATE_LIFE, GREATER_THAN, this.hp + 0.25)
            call TriggerAddCondition(this.trg, function thistype.onChange)
            set thistype.tb[GetHandleId(this.trg)] = this
        endmethod

        private static method onDamage takes nothing returns boolean
            local thistype this = thistype.tb[GetHandleId(GetTriggeringTrigger())]
            local integer level = GetUnitAbilityLevel(this.target, SPELL_ID)
            local real dur
            if TargetFilter(Damage.source, GetOwningPlayer(this.target)) then
                set dur = Duration(level)
                set this.duration = this.duration
                if this.charges < MaxCharges(level) then
                    set this.charges = this.charges + 1
                    call TimerStart(NewTimerEx(this), dur, false, function thistype.expires)
                endif
                call thistype.tb.remove(GetHandleId(this.trg))
                call DestroyTrigger(this.trg)
                call TimerStart(NewTimerEx(this), 0.0, false, function thistype.enable)
            endif
            return false
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this = thistype(0).next
            loop
                exitwhen this == 0
                call this.ts.setPosition(GetUnitX(this.target), GetUnitY(this.target), GetUnitFlyHeight(this.target) + 180)
                call this.ts.setText("|iREGENCY|i" + I2S(this.charges), 7.0, TEXTSPLAT_TEXT_ALIGN_CENTER)
                set this = this.next
            endloop
        endmethod

        implement List
        
        method onApply takes nothing returns nothing
            set this.charges = 1
            set this.sfx = AddSpecialEffectTarget(BUFF_SFX, this.target, "origin")
            set this.hp = RMinBJ(I2R(R2I(GetWidgetLife(this.target))) + 0.5, GetUnitState(this.target, UNIT_STATE_MAX_LIFE))
            set this.dmgTrg = CreateTrigger()
            set this.trg = CreateTrigger()
            set this.ts = textsplat.create(TREBUCHET_MS)
            call Damage.registerTrigger(this.dmgTrg)
            call TriggerAddCondition(this.dmgTrg, function thistype.onDamage)
            call TriggerRegisterUnitStateEvent(this.trg, this.target, UNIT_STATE_LIFE, GREATER_THAN, this.hp + 0.25)
            call TriggerAddCondition(this.trg, function thistype.onChange)
            call SetWidgetLife(this.target, this.hp)
            set thistype.tb[GetHandleId(this.dmgTrg)] = this
            set thistype.tb[GetHandleId(this.trg)] = this
            call this.push(TIMEOUT)
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
            set thistype.tb = Table.create()
        endmethod
        
        implement BuffApply
    endstruct
    
    struct Regency extends array

        private static method onDamage takes nothing returns nothing
            local integer level = GetUnitAbilityLevel(Damage.target, SPELL_ID)
            local SpellBuff b
            if level > 0 and TargetFilter(Damage.source, GetOwningPlayer(Damage.target)) then
                set b = SpellBuff.add(Damage.target, Damage.target)
                set b.duration = Duration(level)
            endif
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call Damage.register(function thistype.onDamage)
            call SpellBuff.initialize()
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope