scope Reincarnation
 
    globals
        private constant integer SPELL_ID = 'A1XX'
        private constant real REVIVE_DELAY = 7.00
        private constant integer DETECT_REMOVE = 'ARem'
    endglobals
    
    struct Reincarnation extends array
        implement Alloc
        
        private unit u
        private real mana
        private static trigger t
        private static trigger dead
        private static Table tb
        
        private static method restore takes nothing returns nothing
            local thistype this = ReleaseTimer(GetExpiredTimer())
            if GetOwningPlayer(this.u) == GetLocalPlayer() then
                call SelectUnit(this.u, true)
            endif
            call SetWidgetLife(this.u, GetUnitState(this.u, UNIT_STATE_MAX_LIFE))
            call SetUnitState(this.u, UNIT_STATE_MANA, this.mana)
            set this.u = null
            set this.mana = 0
            call this.deallocate()
        endmethod
        
        private static method expires takes nothing returns nothing
            local thistype this = ReleaseTimer(GetExpiredTimer())
            if thistype.tb.boolean[GetHandleId(this.u)] then
                call SystemMsg.create(GetUnitName(this.u) + " is reincarnating")
                call TimerStart(NewTimerEx(this), REVIVE_DELAY + 0.01, false, function thistype.restore)
            else
                set this.u = null
                set this.mana = 0
                call this.deallocate()
            endif
        endmethod
        
        private static method onDeath takes nothing returns boolean
            set thistype.tb.boolean[GetHandleId(GetTriggerUnit())] = false
            return false
        endmethod
        
        private static method onOrder takes nothing returns boolean
            local thistype this
            local unit caster
            if GetIssuedOrderId() == ORDER_undefend then
                set caster = GetTriggerUnit()
                if not UnitAlive(caster) then
                    set this = thistype.allocate()
                    set this.u = caster
                    set this.mana = GetUnitState(caster, UNIT_STATE_MANA)
                    set thistype.tb.boolean[GetHandleId(this.u)] = true
                    call TimerStart(NewTimerEx(this), 0.0, false, function thistype.expires)
                endif
                set caster = null
            endif
            return false
        endmethod
        
        static method add takes unit u returns nothing
            call SetPlayerAbilityAvailable(GetOwningPlayer(u), DETECT_REMOVE, false)
            call TriggerRegisterUnitEvent(thistype.t, u, EVENT_UNIT_ISSUED_ORDER)
            call TriggerRegisterUnitEvent(thistype.dead, u, EVENT_UNIT_DEATH)
            call UnitAddAbility(u, DETECT_REMOVE)
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            set thistype.t = CreateTrigger()
            set thistype.dead = CreateTrigger()
            set thistype.tb = Table.create()
            call TriggerAddCondition(thistype.t, function thistype.onOrder)
            call TriggerAddCondition(thistype.dead, function thistype.onDeath)
            call thistype.add(PlayerStat.initializer.unit)
            call SystemTest.end()
        endmethod
        
        
    endstruct
    
endscope