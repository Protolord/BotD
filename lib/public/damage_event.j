library DamageEvent /*
            ----------------------------------
                    DamageEvent v1.44
                        by Flux
            ----------------------------------

        A lightweight damage detection system that
        detects when a unit takes damage.
        Can distinguish physical and magical damage.

    */ requires /*
      (nothing)

    */ optional Table /*
        If not found, DamageEvent will create 2 hashtables. Hashtables are limited to 255 per map.

    */

    //Basic Configuration
    //See documentation for details
    globals
        private constant integer DAMAGE_TYPE_DETECTOR = 'ADMG'
        private constant real ETHEREAL_FACTOR = 1.6666
    endglobals

    //Advanced Configuration
    //Default values are recommended, edit only if you understand how the system works (See documentation).
    globals
        private constant boolean AUTO_REGISTER = true
        private constant boolean PREPLACE_INIT = true
        private constant integer COUNT_LIMIT = 50
        private constant real REFRESH_TIMEOUT = 30.0
    endglobals

    static if not AUTO_REGISTER and not PREPLACE_INIT then
    //Equivalent to AUTO_REGISTER or PREPLACE_INIT
    else
        //Autoregister Filter
        //If it returns true, it will be registered automatically
        private function AutoRegisterFilter takes unit u returns boolean
            local integer id = GetUnitTypeId(u)
            return id != 'dumi'
        endfunction
    endif

    //Globals not meant to be edited.
    globals
        constant integer DAMAGE_TYPE_PHYSICAL = 1
        constant integer DAMAGE_TYPE_MAGICAL = 2
        private constant real MIN_LIFE = 0.406
        private DamageBucket pickedBucket = 0
        private DamageBucket currentBucket = 0
    endglobals

    struct DamageBucket

        readonly integer count
        readonly trigger trg
        readonly group grp
        readonly thistype next
        readonly thistype prev

        private static timer t = CreateTimer()

        method destroy takes nothing returns nothing
            set this.next.prev = this.prev
            set this.prev.next = this.next
            if thistype(0).next == 0 then
                call PauseTimer(thistype.t)
            endif
            if this == currentBucket then
                set currentBucket = thistype(0).next
            endif
            call DestroyTrigger(this.trg)
            call DestroyGroup(this.grp)
            set this.trg = null
            set this.grp = null
            call this.deallocate()
        endmethod

        //Returns the DamageBucket where unit u belongs.
        static method get takes unit u returns thistype
            static if LIBRARY_Table then
                return Damage.tb[GetHandleId(u)]
            else
                return LoadInteger(Damage.hash, GetHandleId(u), 0)
            endif
        endmethod

        method remove takes unit u returns nothing
            call GroupRemoveUnit(this.grp, u)
            static if LIBRARY_Table then
                call Damage.tb.remove(GetHandleId(u))
            else
                call RemoveSavedInteger(Damage.hash, GetHandleId(u), 0)
            endif
        endmethod

        //Add unit u to this DamageBucket.
        method add takes unit u returns nothing
            call TriggerRegisterUnitEvent(this.trg, u, EVENT_UNIT_DAMAGED)
            call GroupAddUnit(this.grp, u)
            set this.count = this.count + 1
            static if LIBRARY_Table then
                set Damage.tb[GetHandleId(u)] = this
            else
                call SaveInteger(Damage.hash, GetHandleId(u), 0, this)
            endif
        endmethod

        private static thistype temp

        //Enumerate DamageBucket units, removing it if it is removed from the game
        private static method cleanGroup takes nothing returns nothing
            local unit u = GetEnumUnit()
            local thistype this = temp
            if GetUnitTypeId(u) != 0 then
                call TriggerRegisterUnitEvent(this.trg, u, EVENT_UNIT_DAMAGED)
                set this.count = this.count + 1
            else
                call GroupRemoveUnit(this.grp, u)
                static if LIBRARY_Table then
                    call Damage.tb.remove(GetHandleId(u))
                else
                    call RemoveSavedInteger(Damage.hash, GetHandleId(u), 0)
                endif
            endif
            set u = null
        endmethod

        //Refreshes this DamageBucket
        method refresh takes nothing returns nothing
            local unit u
            call DestroyTrigger(this.trg)
            set this.trg = CreateTrigger()
            call TriggerAddCondition(this.trg, Filter(function Damage.core))
            set this.count = 0
            set thistype.temp = this
            call ForGroup(this.grp, function thistype.cleanGroup)
            if this.count == 0 then
                call this.destroy()
            endif
        endmethod

        static method create takes nothing returns thistype
            local thistype this = thistype.allocate()
            set this.count = 0
            set this.trg = CreateTrigger()
            set this.grp = CreateGroup()
            call TriggerAddCondition(this.trg, Filter(function Damage.core))
            set this.next = thistype(0)
            set this.prev = thistype(0).prev
            set this.next.prev = this
            set this.prev.next = this
            if this.prev == 0 then
                call TimerStart(thistype.t, REFRESH_TIMEOUT, true, function Damage.refresh)
            endif
            return this
        endmethod

    endstruct

    struct DamageTrigger

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


    struct Damage extends array

        private static thistype stackTop = 0
        private static thistype global
        private static integer array allocator
        private unit stackSource
        private unit stackTarget
        private real stackAmount
        private integer stackType
        private thistype stackNext

        private static real hp

        static if LIBRARY_Table then
            readonly static Table tb
        else
            readonly static hashtable hash = InitHashtable()
        endif

        //Allows the DamageModify module to access the configuration
        static if LIBRARY_DamageModify then
            private static constant real S_ETHEREAL_FACTOR = ETHEREAL_FACTOR
            private static constant real S_MIN_LIFE = MIN_LIFE
        endif

        static method remove takes unit u returns nothing
            call DamageBucket.get(u).remove(u)
        endmethod

        //Add unit u to the current DamageBucket
        static method add takes unit u returns nothing
            local DamageBucket temp
            local DamageBucket b
            //If unit does not belong to any DamageBucket yet
            if DamageBucket.get(u) == 0 then
                call UnitAddAbility(u, DAMAGE_TYPE_DETECTOR)
                call UnitMakeAbilityPermanent(u, true, DAMAGE_TYPE_DETECTOR)
                if currentBucket != 0 then
                    //When the current DamageBucket exceeds the limit
                    if currentBucket.count >= COUNT_LIMIT then
                        set temp = DamageBucket(0).next
                        loop
                            exitwhen temp == 0
                            //Find a DamageBucket with few units
                            if temp.count < COUNT_LIMIT then
                                exitwhen true
                            endif
                            set temp = temp.next
                        endloop
                        if temp == 0 then //If none is found
                            set currentBucket = DamageBucket.create()
                        else             //If a DamageBucket is found, use it
                            set currentBucket = temp
                        endif
                    endif
                else
                    set currentBucket = DamageBucket.create()
                    set pickedBucket = currentBucket
                endif
                call currentBucket.add(u)
            endif
        endmethod

        //Periodic Refresh only refreshing one DamageBucket per REFRESH_TIMEOUT
        //to avoid lag spike.
        static method refresh takes nothing returns nothing
            call pickedBucket.refresh()
            loop
                set pickedBucket = pickedBucket.next
                exitwhen pickedBucket != 0
            endloop
        endmethod

        static method operator amount takes nothing returns real
            return thistype.stackTop.stackAmount
        endmethod

        static method operator type takes nothing returns integer
            return thistype.stackTop.stackType
        endmethod

        static method operator target takes nothing returns unit
            return thistype.stackTop.stackTarget
        endmethod

        static method operator source takes nothing returns unit
            return thistype.stackTop.stackSource
        endmethod

        private static boolean prevEnable = true

        static method operator enabled takes nothing returns boolean
            return thistype.prevEnable
        endmethod

        static method operator enabled= takes boolean b returns nothing
            local DamageBucket bucket = DamageBucket(0).next
            if b != thistype.prevEnable then
                loop
                    exitwhen bucket == 0
                    if b then
                        call EnableTrigger(bucket.trg)
                    else
                        call DisableTrigger(bucket.trg)
                    endif
                    set bucket = bucket.next
                endloop
            endif
            set thistype.prevEnable = b
        endmethod

        //All registered codes will go to this trigger
        private static trigger registered

        static method register takes code c returns boolean
            call TriggerAddCondition(thistype.registered, Condition(c))
            return false    //Prevents inlining
        endmethod

        static method registerTrigger takes trigger trig returns nothing
            call DamageTrigger.register(trig)
        endmethod

        static method unregisterTrigger takes trigger trig returns nothing
            call DamageTrigger.unregister(trig)
        endmethod

        implement optional DamageModify

        static if not LIBRARY_DamageModify then

            private static method afterDamage takes nothing returns boolean
                call SetWidgetLife(thistype.stackTop.stackTarget, thistype.hp - thistype.stackTop.stackAmount)
                call DestroyTrigger(GetTriggeringTrigger())
                if thistype.global > 0 then
                    set thistype.allocator[thistype.global] = thistype.allocator[0]
                    set thistype.allocator[0] = thistype.global
                    set thistype.stackTop = thistype.stackTop.stackNext
                endif
                return false
            endmethod

            static method core takes nothing returns boolean
                local real amount = GetEventDamage()
                local thistype this
                local real newHp
                local trigger trg

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

                if amount > 0.0 then
                    set this.stackType = DAMAGE_TYPE_PHYSICAL
                    set this.stackAmount = amount
                    call DamageTrigger.executeAll()
                    set thistype.allocator[this] = thistype.allocator[0]
                    set thistype.allocator[0] = this
                    set thistype.stackTop = thistype.stackTop.stackNext

                elseif amount < 0.0 then
                    set this.stackType = DAMAGE_TYPE_MAGICAL
                    if IsUnitType(this.stackTarget, UNIT_TYPE_ETHEREAL) then
                        set amount = amount*ETHEREAL_FACTOR
                    endif
                    set this.stackAmount = -amount
                    call DamageTrigger.executeAll()

                    set thistype.hp = GetWidgetLife(this.stackTarget)
                    set newHp = thistype.hp + amount
                    if newHp < MIN_LIFE then
                        set newHp = MIN_LIFE
                    endif
                    call SetWidgetLife(this.stackTarget, newHp)

                    set trg = CreateTrigger()
                    if amount < -1.0 then
                        call TriggerRegisterUnitStateEvent(trg, this.stackTarget, UNIT_STATE_LIFE, GREATER_THAN, newHp + 1.0)
                    elseif amount < -0.125 then
                        call TriggerRegisterUnitStateEvent(trg, this.stackTarget, UNIT_STATE_LIFE, GREATER_THAN, newHp + 0.125)
                    else
                        call TriggerRegisterUnitStateEvent(trg, this.stackTarget, UNIT_STATE_LIFE, GREATER_THAN, newHp + 0.01)
                    endif
                    call TriggerAddCondition(trg, Condition(function thistype.afterDamage))
                    set trg = null
                    set thistype.global = this
                endif

                return false
            endmethod
        endif

        static if PREPLACE_INIT then
            private static method preplace takes nothing returns nothing
                local group g = CreateGroup()
                local unit u
                call GroupEnumUnitsInRect(g, bj_mapInitialPlayableArea, null)
                loop
                    set u = FirstOfGroup(g)
                    exitwhen u == null
                    call GroupRemoveUnit(g, u)
                    if AutoRegisterFilter(u) then
                        call thistype.add(u)
                    endif
                endloop
                call DestroyGroup(g)
                call DestroyTimer(GetExpiredTimer())
                set g = null
            endmethod
        endif

        static if AUTO_REGISTER then
            private static method entered takes nothing returns boolean
                local unit u = GetTriggerUnit()
                if AutoRegisterFilter(u) then
                    call thistype.add(u)
                endif
                set u = null
                return false
            endmethod
        endif

        implement DamageInit
        implement DamageElement

    endstruct

    module DamageInit
        private static method onInit takes nothing returns nothing
            static if AUTO_REGISTER then
                local trigger t = CreateTrigger()
                local region reg = CreateRegion()
                call RegionAddRect(reg, bj_mapInitialPlayableArea)
                call TriggerRegisterEnterRegion(t, reg, null)
                call TriggerAddCondition(t, function thistype.entered)
            endif
            static if LIBRARY_Table then
                set thistype.tb = Table.create()
            endif
            static if PREPLACE_INIT then
                call TimerStart(CreateTimer(), 0.0000, false, function thistype.preplace)
            endif
            set thistype.registered = CreateTrigger()
            call DamageTrigger.register(thistype.registered)
            set thistype.allocator[0] = 1
            set thistype(0).stackSource = null
            set thistype(0).stackTarget = null
            set thistype(0).stackAmount = 0.0
            set thistype(0).stackType = 0
        endmethod

    endmodule

endlibrary