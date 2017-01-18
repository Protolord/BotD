library DamageModify uses DamageEvent/*
            ---------------------------------
                    DamageModify v1.30
                        by Flux
            ---------------------------------
    
        An add-on to DamageEvent that allows modification 
        of damage taken before it is applied.
    */
    
    globals
        private constant integer SET_MAX_LIFE = 'ASML'
    endglobals
    
    struct DamageTrigger2
        
        private trigger trg
        private thistype next
        private thistype prev
        
        method destroy takes nothing returns nothing
            set this.next.prev = this.prev
            set this.prev.next = this.next
            static if LIBRARY_Table then
                call Damage.tb.remove(GetHandleId(this.trg))
            else
                call RemoveSavedInteger(Damage.hash, GetHandleId(this.trg), 0)
            endif
            set this.trg = null
            call this.deallocate()
        endmethod
        
        static method unregister takes trigger t returns nothing
            local integer id = GetHandleId(t)
            static if LIBRARY_Table then
                if Damage.tb.has(id) then
                    call thistype(Damage.tb[id]).destroy()
                endif
            else
                if HaveSavedInteger(Damage.hash, id, 0) then
                    call thistype(LoadInteger(Damage.hash, id, 0)).destroy()
                endif
            endif
        endmethod
        
        static method register takes trigger t returns nothing
            local thistype this = thistype.allocate()
            set this.trg = t
            set this.next = thistype(0)
            set this.prev = thistype(0).prev
            set this.next.prev = this
            set this.prev.next = this
            static if LIBRARY_Table then
                set Damage.tb[GetHandleId(t)] = this
            else
                call SaveInteger(Damage.hash, GetHandleId(t), 0, this)
            endif
        endmethod
        
        static method executeAll takes nothing returns nothing
            local thistype this = thistype(0).next
            loop
                exitwhen this == 0
                if IsTriggerEnabled(this.trg) then
                    if TriggerEvaluate(this.trg) then
                        call TriggerExecute(this.trg)
                    endif
                endif
                set this = this.next
            endloop
        endmethod
        
    endstruct
    
    module DamageModify
        
        private static boolean changed = false
        private static trigger registered2 = CreateTrigger()

        static method registerModifier takes code c returns boolean
            call TriggerAddCondition(thistype.registered2, Condition(c))
            return false    //Prevents inlining
        endmethod
        
        static method registerModifierTrigger takes trigger trg returns nothing
            call DamageTrigger2.register(trg)
        endmethod
        
        static method unregisterModifierTrigger takes trigger trg returns nothing
            call DamageTrigger2.unregister(trg)
        endmethod
                
        private static method afterDamage takes nothing returns boolean
            if GetUnitAbilityLevel(thistype.target, SET_MAX_LIFE) > 0 then
                call UnitRemoveAbility(thistype.target, SET_MAX_LIFE)
            endif
            call SetWidgetLife(thistype.target, thistype.hp - thistype.amt)
            call DestroyTrigger(GetTriggeringTrigger())
            return false
        endmethod
            
        static method core takes nothing returns boolean
            local real amount = GetEventDamage()
            local boolean changed = false
            local trigger trg
            local real newHp
            
            if amount == 0.0 then
                return false
            endif
            
            set thistype.target = GetTriggerUnit()
            set thistype.source = GetEventDamageSource()
                            
            if amount == 0.0 then
                return false
            endif
            
            if amount > 0.0 then
                set thistype.type = DAMAGE_TYPE_PHYSICAL
                set thistype.amt = amount
                call DamageTrigger2.executeAll()
                set changed = thistype.changed
                if changed then
                    set thistype.changed = false
                endif
                call DamageTrigger.executeAll()
                
            elseif amount < 0.0 then
                set thistype.type = DAMAGE_TYPE_MAGICAL
                if IsUnitType(thistype.target, UNIT_TYPE_ETHEREAL) then
                    set thistype.amt = -amount*S_ETHEREAL_FACTOR
                else
                    set thistype.amt = -amount
                endif
                call DamageTrigger2.executeAll()
                set changed = thistype.changed
                if changed then
                    set thistype.changed = false
                endif
                call DamageTrigger.executeAll()
            endif
            
            if amount < 0.0 or changed then
                set thistype.hp = GetWidgetLife(thistype.target)
                
                set trg = CreateTrigger()
                if amount > 0.0 then
                    set newHp = thistype.hp + amount
                    if newHp > GetUnitState(thistype.target, UNIT_STATE_MAX_LIFE) then
                        call UnitAddAbility(thistype.target, SET_MAX_LIFE)
                    endif
                    call SetWidgetLife(thistype.target, newHp)
                    if amount > 1.0 then
                        call TriggerRegisterUnitStateEvent(trg, thistype.target, UNIT_STATE_LIFE, LESS_THAN, newHp - 0.01*amount)
                    else
                        call TriggerRegisterUnitStateEvent(trg, thistype.target, UNIT_STATE_LIFE, LESS_THAN, newHp - 0.01)
                    endif
                else
                    set newHp = thistype.hp + amount
                    if newHp < S_MIN_LIFE then
                        set newHp = S_MIN_LIFE
                    endif
                    call SetWidgetLife(thistype.target, newHp)
                    call TriggerRegisterUnitStateEvent(trg, thistype.target, UNIT_STATE_LIFE, GREATER_THAN, newHp + 0.01)
                endif
                call TriggerAddCondition(trg, Condition(function thistype.afterDamage))
                
            endif

            return false
        endmethod
        
        static method operator amount= takes real r returns nothing
            set thistype.amt = r
            set thistype.changed = true
        endmethod
        
        private static method onInit takes nothing returns nothing
            local unit u = CreateUnit(Player(14), 'hfoo', 0, 0, 0)
            call UnitAddAbility(u, SET_MAX_LIFE)
            call RemoveUnit(u)
            set thistype.registered2 = CreateTrigger()
            call DamageTrigger2.register(thistype.registered2)
            set u = null
        endmethod
    endmodule
    
endlibrary