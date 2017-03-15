scope AuraOfStrength
 
    globals
        private constant integer SPELL_ID = 'A844'
		private constant real TIMEOUT = 1.0
    endglobals
    
	private function HealPerSecond takes integer level returns real
        if level == 11 then
			return 1200.0
		endif
		return 60.0*level
    endfunction
	
    private function Radius takes integer level returns real
        return 600.0 + 0.0*level
    endfunction
	
	private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitAlly(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE)
    endfunction

    struct AuraOfStrength extends array
		implement Alloc
		
        private unit caster
		private timer t
		private real radius
        private real hps
        private trigger manaTrg

        private static trigger trg
        private static Table tb
		private static group g

        private method destroy takes nothing returns nothing
            call DestroyTrigger(this.manaTrg)
			call ReleaseTimer(this.t)
            call thistype.tb.remove(GetHandleId(this.caster))
            call thistype.tb.remove(GetHandleId(this.manaTrg))
            set this.caster = null
            set this.manaTrg = null
			set this.t = null
            call this.deallocate()
        endmethod
			
		private static method onPeriod takes nothing returns nothing
			local thistype this = GetTimerData(GetExpiredTimer())
			local player p = GetOwningPlayer(this.caster)
			local unit u
			call GroupUnitsInArea(thistype.g, GetUnitX(this.caster), GetUnitY(this.caster), this.radius)
			loop
				set u = FirstOfGroup(thistype.g)
				exitwhen u == null
				call GroupRemoveUnit(thistype.g, u)
				if TargetFilter(u, p) then
					call Heal.unit(u, this.hps, 4.0)
				endif
			endloop
		endmethod

        private static method onManaDeplete takes nothing returns boolean
            local integer id = GetHandleId(GetTriggeringTrigger())
            if thistype.tb.has(id) then
                call thistype(thistype.tb[id]).destroy()
                call SetUnitState(GetTriggerUnit(), UNIT_STATE_MANA, 0.0)
                call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " deactivates thistype")
            endif
            return false
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
			local integer lvl
            set this.caster = GetTriggerUnit()
            set lvl = GetUnitAbilityLevel(this.caster, SPELL_ID)
			set this.hps = HealPerSecond(lvl)*TIMEOUT
			set this.radius = Radius(lvl)
            set this.manaTrg = CreateTrigger()
			set this.t = NewTimerEx(this)
            call TriggerAddCondition(this.manaTrg, function thistype.onManaDeplete)
            call TriggerRegisterUnitStateEvent(this.manaTrg, this.caster, UNIT_STATE_MANA, LESS_THAN, 1.0)
            set thistype.tb[GetHandleId(this.caster)] = this
            set thistype.tb[GetHandleId(this.manaTrg)] = this
			call TimerStart(this.t, TIMEOUT, true, function thistype.onPeriod)
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " activates thistype")
        endmethod

        private static method unCast takes nothing returns boolean
            local integer id = GetHandleId(GetTriggerUnit())
            if GetIssuedOrderId() == ORDER_unimmolation and thistype.tb.has(id) then
                call thistype(thistype.tb[id]).destroy()
                call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " deactivates thistype")
            endif
            return false
        endmethod

        private static method add takes unit u returns nothing
            call TriggerRegisterUnitEvent(thistype.trg, u, EVENT_UNIT_ISSUED_ORDER)
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            set thistype.trg = CreateTrigger()
            set thistype.tb = Table.create()
            call TriggerAddCondition(thistype.trg, function thistype.unCast)
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call thistype.add(PlayerStat.initializer.unit)
			set thistype.g = CreateGroup()
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope