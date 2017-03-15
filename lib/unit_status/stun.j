library Stun uses TimerUtilsEx, Table, DummyRecycler
    
/*
    Stun.create(unit, duration, additiveTime)
        - Stun a unit for a certain duration preventing it from doing anything.
        - Duration of zero means infinite.
        - Buff indicator appears.
	
	this.destroy()
		- Destroy a Stun instance.
*/

    globals
        private constant integer STUN_SPELL = 'AStn'
        private constant integer STUN_BUFF = 'BPSE'
    endglobals
    
    struct Stun extends array
        implement Alloc
        
        private unit u
        private unit dummy
        private timer t
        
        private static Table tb
        private static trigger trg
        private static group g = CreateGroup()
        private static integer counter = 0
        
        method destroy takes nothing returns nothing
            call UnitRemoveAbility(this.u, STUN_BUFF)
            call GroupRemoveUnit(thistype.g, this.u)
            call thistype.tb.remove(GetHandleId(this.u))
            call UnitRemoveAbility(this.dummy, STUN_SPELL)
            call RecycleDummy(this.dummy)
            call ReleaseTimer(this.t)
            set this.u = null
            set this.dummy = null
            set this.t = null
            call this.deallocate()
        endmethod
        
        private static method expire takes nothing returns nothing
            call thistype(GetTimerData(GetExpiredTimer())).destroy()
        endmethod
        
        private static method onDeath takes nothing returns boolean
            local thistype this = thistype.tb[GetHandleId(GetTriggerUnit())]
            if this != 0 then
                call this.destroy()
            endif
            return false
        endmethod
        
        private static method add takes nothing returns nothing
            call TriggerRegisterUnitEvent(thistype.trg, GetEnumUnit(), EVENT_UNIT_DEATH)
        endmethod
        
        static method create takes unit u, real duration, boolean stack returns thistype
            local integer id = GetHandleId(u)
            local thistype this = thistype.tb[id]
            local real prevDuration
            local unit dummy
            if this != 0 then
                set prevDuration = TimerGetRemaining(this.t)
            else
                set this = thistype.allocate()
                set this.u = u
                set this.t = NewTimerEx(this)
                set thistype.tb[id] = this
                set prevDuration = 0
            endif
            if stack then
                set duration = prevDuration + duration
            elseif duration < prevDuration then
                return this
            endif
            if duration > 0 then
                call TimerStart(this.t, duration, false, function thistype.expire)
            endif
            set this.dummy = GetRecycledDummyAnyAngle(GetUnitX(u), GetUnitY(u), 0)
            call SetUnitOwner(this.dummy, GetOwningPlayer(u), false)
            call PauseUnit(this.dummy, false)
            call UnitAddAbility(this.dummy, STUN_SPELL)
            call IssueTargetOrderById(this.dummy, ORDER_thunderbolt, u)
            set thistype.counter = thistype.counter + 1
            if thistype.counter > 10 then
                set thistype.counter = 0
                call DestroyTrigger(thistype.trg)
                set thistype.trg = CreateTrigger()
                call TriggerAddCondition(thistype.trg, Filter(function thistype.onDeath))
                call ForGroup(thistype.g, function thistype.add)
            endif
            call TriggerRegisterUnitEvent(thistype.trg, u, EVENT_UNIT_DEATH)
            call GroupAddUnit(thistype.g, u)
            return this
        endmethod
        
        private static method onInit takes nothing returns nothing
            set thistype.tb = Table.create()
            set thistype.trg = CreateTrigger()
            call TriggerAddCondition(thistype.trg, Filter(function thistype.onDeath))
        endmethod
        
    endstruct
    
endlibrary