scope Spray
 
    globals
        private constant integer SPELL_ID = 'A441'
        private constant string SFX = "Models\\Effects\\SevereWound.mdx"
        private constant real TIMEOUT = 1.0
    endglobals
    
    private function Radius takes integer level returns real
        return 0.0*level + 250.0
    endfunction
    
    private function HealPerSecond takes integer level returns real
        if level == 11 then
            return 3000.0
        endif
        return 150.0*level
    endfunction
    
    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitAlly(u, p) and GetUnitTypeId(u) != 'uCoc'
    endfunction
    
    struct Spray extends array
        implement Alloc
        
        private unit dummy
        private unit caster
        private integer id
        private real x
        private real y
        private real hps
        private real radius
        private timer t
        
        private static group g
        private static Table tb
        
        private method destroy takes nothing returns nothing
            call DummyAddRecycleTimer(this.dummy, 1.5)
            call ReleaseTimer(this.t)
            call thistype.tb.remove(this.id)
            set this.dummy = null
            set this.t = null
            call this.deallocate()
        endmethod
        
        private method heal takes nothing returns nothing
            local player owner = GetOwningPlayer(this.caster)
            local unit u
            call GroupUnitsInArea(thistype.g, this.x, this.y, this.radius)
            loop
                set u = FirstOfGroup(thistype.g)
                exitwhen u == null
                call GroupRemoveUnit(thistype.g, u)
                if TargetFilter(u, owner) then
                    call Heal.unit(u, this.hps, 4.0)
                endif
            endloop
            call DestroyEffect(AddSpecialEffectTarget(SFX, this.dummy, "origin"))
            set owner = null
        endmethod
        
        private static method onPeriod takes nothing returns nothing
            call thistype(GetTimerData(GetExpiredTimer())).heal()
        endmethod
        
        private static method onStop takes nothing returns nothing
            local thistype this = thistype.tb[GetHandleId(GetTriggerUnit())]
            if this > 0 then
                call this.destroy()
            endif
        endmethod
        
        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            local integer lvl
            set this.caster = GetTriggerUnit()
            set lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            set this.id = GetHandleId(caster)
            set this.x = GetSpellTargetX()
            set this.y = GetSpellTargetY()
            set this.hps = HealPerSecond(lvl)*TIMEOUT
            set this.radius = Radius(lvl)
            set this.t = NewTimerEx(this)
            set this.dummy = GetRecycledDummyAnyAngle(this.x, this.y, 10)
            call SetUnitScale(this.dummy, this.radius/100, 0, 0)
            set thistype.tb[this.id] = this
            call this.heal()
            call TimerStart(this.t, TIMEOUT, true, function thistype.onPeriod)
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call RegisterSpellEndcastEvent(SPELL_ID, function thistype.onStop)
            set thistype.g = CreateGroup()
            set thistype.tb = Table.create()
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope