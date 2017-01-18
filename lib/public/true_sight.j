library TrueSight /*

                     True Sight v1.10
                         by Flux
       
    Allows dynamically assigning a True Sight to a unit at any range
    using only 1 ability.
       
    */ requires Invisible/*
       nothing
       
    */ optional DummyRecycler /*
        if not found, the system will create a new dummy every time a unit passing the filter is within range.
        Highly recommended.
       
    */ optional RegisterPlayerUnitEvent /*
        if not found, it will create a new trigger with the Item Picked and Item Dropped event.
   
   
    Known Issues:
        - Actual sight radius sometimes become "radius + 64" if a unit outside radius is close enough to a revealed unit.
        - Minimum acceptable radius is 64
               
                       
    *********************************
                   API
    *********************************
       
    struct TrueSight
       
        public real radius
            You can edit the radius of a TrueSight instance anytime.
       
        static method create takes unit u, real radius returns TrueSight
            Add a True Sight to <unit u> revealing invisible units within <real radius> for
            <real duration> second(s).
       
        method operator duration= takes real time returns nothing
            Add a duration counter to a TrueSight instance.
           
        static method addToItem takes integer itemId, real radius returns nothing
            Make all items of rawcode <integer itemId> have TrueSight having <real radius>.
       
        method destroy takes nothing returns nothing
            Destroy a TrueSight instance. You mostly won't need this if duration is not zero.
 
         
    CREDITS:
        Flux                - DummyRecycler
        Magtheridon96       - RegisterPlayerUnitEvent
           
    */
   
    globals
        //A True Sight Ability with 64 Cast Range
        private constant integer TRUE_SIGHT_ABILITY = 'ATSS'
       
        //If DummyRecycler is not found, it will create units using this rawcode
        private constant integer DUMMY_ID = 'dumi'
       
        //Recommended Value: 0.05 to 0.25 
        //If value is too high, revealed unit may sometimes flicker (switching between visible and invisible)
        //Lower value = Better detection
        //Higher value = Better performance
        private constant real TIMEOUT = 0.05
       
        //If certain items will have a passive TrueSight, set this to true
        //else set it to false to have lesser compiled code
        private constant boolean WILL_USE_ON_ITEMS = false
    endglobals
   
    native UnitAlive takes unit u returns boolean

    private function TargetFilter takes unit u, player owner returns boolean
        static if DEBUG_MODE then
            return UnitAlive(u) and IsUnitEnemy(u, owner)
        else
            return UnitAlive(u) and IsUnitEnemy(u, owner) and Invisible.has(u)
        endif
    endfunction
   
    private struct SightSource extends array
        implement Alloc
       
        readonly unit u
        readonly unit target
       
        readonly thistype next
        readonly thistype prev
       
        method destroy takes nothing returns nothing
            set this.prev.next = this.next
            set this.next.prev = this.prev
            if this.u != null then
                static if LIBRARY_DummyRecycler then
                    call UnitRemoveAbility(this.u, TRUE_SIGHT_ABILITY)
                    call RecycleDummy(this.u)
                else
                    call RemoveUnit(this.u)
                endif
                set this.u = null
            endif
            set this.target = null
            call this.deallocate()
        endmethod
       
        static method create takes thistype head, unit target, player owner returns thistype
            local thistype this = thistype.allocate()
            set this.target = target
            static if LIBRARY_DummyRecycler then
                set this.u = GetRecycledDummyAnyAngle(GetUnitX(target), GetUnitY(target), 0)
                call PauseUnit(this.u, false)
                call SetUnitOwner(this.u, owner, false)
            else
                set this.u = CreateUnit(owner, DUMMY_ID, GetUnitX(target), GetUnitY(target), 0)
            endif
            call UnitAddAbility(this.u, TRUE_SIGHT_ABILITY)
            set this.next = head
            set this.prev = head.prev
            set this.next.prev = this
            set this.prev.next = this
            return this
        endmethod
       
        static method head takes nothing returns thistype
            local thistype this = thistype.allocate()
            set this.next = this
            set this.prev = this
            return this
        endmethod
       
    endstruct
   
    struct TrueSight extends array
        implement Alloc
       
        public real radius
       
        readonly unit u
        readonly player owner
       
        private SightSource sightHead
        private real dur
        private group visible
        private boolean inf
       
        private thistype next
        private thistype prev
       
        private static group g = CreateGroup()
        private static timer t = CreateTimer()
       
        method destroy takes nothing returns nothing
            local SightSource sight = this.sightHead.next
            set this.prev.next = this.next
            set this.next.prev = this.prev
            if thistype(0).next == 0 then
                call PauseTimer(thistype.t)
            endif
            //Destroy all SightSource
            loop
                exitwhen sight == this.sightHead
                call sight.destroy()
                set sight = sight.next
            endloop
            call this.sightHead.destroy()
            call DestroyGroup(this.visible)
            set this.visible = null
            set this.u = null
            call this.deallocate()
        endmethod
       

        private static method pickAll takes nothing returns nothing
            local thistype this = thistype(0).next
            local SightSource sight
            local Invisible inv
            local player newOwner
            local boolean b
            local unit u
            loop
                exitwhen this == 0
               
                set newOwner = GetOwningPlayer(this.u)
                set b = newOwner != this.owner
                if b then
                    set this.owner = newOwner
                endif
                if not this.inf then
                    set this.dur = this.dur - TIMEOUT
                endif
               
                if (this.dur > 0 or this.inf) and UnitAlive(this.u) then
                    //Find new invisible units
                    //Find new invisible units
                    if this.radius > 1000 then
                        set inv = Invisible(0).next
                        call GroupClear(thistype.g)
                        loop
                            exitwhen inv == 0
                            if IsUnitInRange(this.u, inv.u, this.radius) then
                                call GroupAddUnit(thistype.g, inv.u)
                            endif
                            set inv = inv.next
                        endloop
                    else
                        call GroupEnumUnitsInRange(thistype.g, GetUnitX(this.u), GetUnitY(this.u), this.radius + 128.0, null)
                    endif
                    loop
                        set u = FirstOfGroup(thistype.g)
                        exitwhen u == null
                        call GroupRemoveUnit(thistype.g, u)
                       
                        if not IsUnitInGroup(u, this.visible) and TargetFilter(u, this.owner) and IsUnitInRange(this.u, u, this.radius) then
                            call GroupAddUnit(this.visible, u)
                            call SightSource.create(this.sightHead, u, this.owner)
                        endif
                    endloop
                    //Update SightSources
                    set sight = this.sightHead.next
                    loop
                        exitwhen sight == this.sightHead
                        if IsUnitInRange(this.u, sight.target, this.radius) and TargetFilter(sight.target, this.owner) then
                            call SetUnitX(sight.u, GetUnitX(sight.target))
                            call SetUnitY(sight.u, GetUnitY(sight.target))
                            if b then
                                call SetUnitOwner(sight.u, this.owner, false)
                            endif
                        else
                            call GroupRemoveUnit(this.visible, sight.target)
                            call sight.destroy()
                        endif
                        set sight = sight.next
                    endloop
                else
                    call this.destroy()
                endif
               
                set this = this.next
            endloop
        endmethod
       
        static method create takes unit u, real radius returns thistype
            local thistype this = thistype.allocate()
            set this.u = u
            set this.owner = GetOwningPlayer(u)
            set this.radius = radius
            set this.sightHead = SightSource.head()
            set this.inf = true
            set this.visible = CreateGroup()
            set this.next = 0
            set this.prev = thistype(0).prev
            set this.next.prev = this
            set this.prev.next = this
            if this.prev == 0 then
                call TimerStart(thistype.t, TIMEOUT, true, function thistype.pickAll)
            endif
            return this
        endmethod
       
        method operator duration takes nothing returns real
            return this.dur
        endmethod
       
        method operator duration= takes real time returns nothing
            set this.inf = false
            set this.dur = time
        endmethod
        
        static method createEx takes unit u, real radius, real time returns thistype
            local thistype this = thistype.create(u, radius)
            set this.duration = time
            return this
        endmethod
       
        static if WILL_USE_ON_ITEMS then
           
            private static hashtable hash = InitHashtable()
       
            private static method drop takes nothing returns nothing
                local item it = GetManipulatedItem()
                local integer id = GetItemTypeId(it)
                if HaveSavedReal(thistype.hash, id, 0) then
                    call thistype(LoadInteger(thistype.hash, GetHandleId(GetTriggerUnit()), GetHandleId(it))).destroy()
                endif
                set it = null
            endmethod
           
            private static method pick takes nothing returns nothing
                local item it = GetManipulatedItem()
                local integer id = GetItemTypeId(it)
                local unit u
                if HaveSavedReal(thistype.hash, id, 0) then
                    set u = GetTriggerUnit()
                    call SaveInteger(thistype.hash, GetHandleId(u), GetHandleId(it), thistype.create(u, LoadReal(thistype.hash, id, 0)))
                    set u = null
                endif
                set it = null
            endmethod
           
            static method addToItem takes integer itemId, real radius returns nothing
                call SaveReal(thistype.hash, itemId, 0, radius)
            endmethod
           
            private static method onInit takes nothing returns nothing
                static if LIBRARY_RegisterPlayerUnitEvent then
                    call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_PICKUP_ITEM, function thistype.pick)
                    call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DROP_ITEM, function thistype.drop)
                else
                    local trigger pickTrg = CreateTrigger()
                    local trigger dropTrg = CreateTrigger()
                    local code c1 = function thistype.pick
                    local code c2 = function thistype.drop
                    call TriggerRegisterAnyUnitEventBJ(pickTrg, EVENT_PLAYER_UNIT_PICKUP_ITEM)
                    call TriggerRegisterAnyUnitEventBJ(dropTrg, EVENT_PLAYER_UNIT_DROP_ITEM)
                    call TriggerAddCondition(pickTrg, Filter(c1))
                    call TriggerAddCondition(dropTrg, Filter(c2))
                endif
            endmethod
       
        endif
   
    endstruct
   
endlibrary