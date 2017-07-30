library DamageModify uses DamageEvent/*
            ---------------------------------
                    DamageModify v1.45
                        by Flux
            ---------------------------------

        An add-on to DamageEvent that allows modification
        of damage taken before it is applied.
    */

    globals
        private constant integer SET_MAX_LIFE = 'ASML'
        private constant boolean DEBUG_SYSTEM = false
    endglobals

    struct DamageTrigger2 extends array
        implement Alloc

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
                set s__Damage_triggeringTrigger  = this.trg
                if IsTriggerEnabled(this.trg) then
                    if TriggerEvaluate(this.trg) then
                        call TriggerExecute(this.trg)
                    endif
                endif
                set this = this.next
            endloop
            set s__Damage_triggeringTrigger  = null
        endmethod

    endstruct

    module DamageModify

        private static boolean changed = false
        private static trigger registered2 = CreateTrigger()
        private static boolean locked = false
        static if DEBUG_SYSTEM then
            private static integer instanceCount = 0
        endif

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

        static method lockAmount takes nothing returns nothing
            set thistype.locked = true
        endmethod

        private static method afterDamage takes nothing returns boolean
            if GetUnitAbilityLevel(thistype.stackTop.stackTarget, SET_MAX_LIFE) > 0 then
                call UnitRemoveAbility(thistype.stackTop.stackTarget, SET_MAX_LIFE)
            endif
            call SetWidgetLife(thistype.stackTop.stackTarget, thistype.hp - thistype.stackTop.stackAmount)
            call DestroyTrigger(GetTriggeringTrigger())
            if thistype.global > 0 then
                set thistype.allocator[thistype.global] = thistype.allocator[0]
                set thistype.allocator[0] = thistype.global
                set thistype.stackTop = thistype.stackTop.stackNext
            endif
            static if DEBUG_SYSTEM then
                set thistype.instanceCount = thistype.instanceCount - 1
            endif
            return false
        endmethod

        static method core takes nothing returns boolean
            local real amount = GetEventDamage()
            local boolean changed = false
            local thistype this
            local trigger trg
            local real newHp

            if amount == 0.0 then
                return false
            endif

            set this = thistype.allocator[0]
            if (thistype.allocator[this] == 0) then
                set thistype.allocator[0] = this + 1
            else
                set thistype.allocator[0] = thistype.allocator[this]
            endif
            set this.stackSource = GetEventDamageSource()
            set this.stackTarget = GetTriggerUnit()
            set this.stackNext = thistype.stackTop
            set thistype.stackTop = this

            static if DEBUG_SYSTEM then
                set thistype.instanceCount = thistype.instanceCount + 1
            endif

            if amount > 0.0 then
                set this.stackType = DAMAGE_TYPE_PHYSICAL
                set this.stackAmount = amount
                call DamageTrigger2.executeAll()
                set changed = thistype.changed
                if changed then
                    set thistype.changed = false
                endif
                set thistype.locked = true
                call DamageTrigger.executeAll()
                set thistype.locked = false

            elseif amount < 0.0 then
                set this.stackType = DAMAGE_TYPE_MAGICAL
                if IsUnitType(this.stackTarget, UNIT_TYPE_ETHEREAL) then
                    set amount = amount*S_ETHEREAL_FACTOR
                endif
                set this.stackAmount = -amount
                call DamageTrigger2.executeAll()
                set changed = thistype.changed
                if changed then
                    set thistype.changed = false
                endif
                set thistype.locked = true
                call DamageTrigger.executeAll()
                set thistype.locked = false
            endif

            if amount < 0.0 or (changed and amount > 0.125) then
                set thistype.hp = GetWidgetLife(this.stackTarget)
                set trg = CreateTrigger()
                if amount > 0.0 then
                    set newHp = thistype.hp + amount
                    if newHp > GetUnitState(this.stackTarget, UNIT_STATE_MAX_LIFE) then
                        call UnitAddAbility(this.stackTarget, SET_MAX_LIFE)
                    endif

                    call SetWidgetLife(this.stackTarget, newHp)
                    if amount > 1.0 then
                        call TriggerRegisterUnitStateEvent(trg, this.stackTarget, UNIT_STATE_LIFE, LESS_THAN, newHp - 1.0)
                    elseif amount > 0.125 then
                        call TriggerRegisterUnitStateEvent(trg, this.stackTarget, UNIT_STATE_LIFE, LESS_THAN, newHp - 0.125)
                    endif
                else
                    set newHp = thistype.hp + amount
                    if newHp < S_MIN_LIFE then
                        set newHp = S_MIN_LIFE
                    endif
                    call SetWidgetLife(this.stackTarget, newHp)
                    if amount < -1.0 then
                        call TriggerRegisterUnitStateEvent(trg, this.stackTarget, UNIT_STATE_LIFE, GREATER_THAN, newHp + 1.0)
                    elseif amount < -0.125 then
                        call TriggerRegisterUnitStateEvent(trg, this.stackTarget, UNIT_STATE_LIFE, GREATER_THAN, newHp + 0.125)
                    else
                        call TriggerRegisterUnitStateEvent(trg, this.stackTarget, UNIT_STATE_LIFE, GREATER_THAN, newHp + 0.01)
                    endif
                endif
                call TriggerAddCondition(trg, Condition(function thistype.afterDamage))
                set trg = null
                set thistype.global = this

            else
                set thistype.allocator[this] = thistype.allocator[0]
                set thistype.allocator[0] = this
                set thistype.stackTop = thistype.stackTop.stackNext
                static if DEBUG_SYSTEM then
                    set thistype.instanceCount = thistype.instanceCount - 1
                endif

            endif

            return false
        endmethod

        static method operator amount= takes real r returns nothing
            if not thistype.locked then
                set thistype.stackTop.stackAmount = r
                set thistype.changed = true
            endif
        endmethod

        static if DEBUG_SYSTEM then
            private static method instancePrint takes nothing returns nothing
                call BJDebugMsg("Damage.instances = " + I2S(thistype.instanceCount))
            endmethod
        endif

        private static method onInit takes nothing returns nothing
            local unit u = CreateUnit(Player(14), 'hfoo', 0, 0, 0)
            call UnitAddAbility(u, SET_MAX_LIFE)
            call RemoveUnit(u)
            set thistype.registered2 = CreateTrigger()
            call DamageTrigger2.register(thistype.registered2)
            set u = null
            static if DEBUG_SYSTEM then
                call TimerStart(CreateTimer(), 1.5, true, function thistype.instancePrint)
            endif
        endmethod
    endmodule

endlibrary