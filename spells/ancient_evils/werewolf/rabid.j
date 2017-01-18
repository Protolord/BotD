scope Rabid
    
    globals
        private constant integer SPELL_ID = 'A241'
        private constant integer RABID_BUFF = 'B241'
        private constant real TIMEOUT = 0.1
    endglobals
    
    private function Regen takes integer level returns real
        if level == 11 then
            return 4.0
        endif
        return 1.0 + 0.2*level
    endfunction
    
    struct Rabid extends array
        implement Alloc
        
        private unit u
        private real rate
        
        private static Table tb
        private static timer t
        
        private thistype next
        private thistype prev
        
        private static method pickAll takes nothing returns nothing
            local thistype this = thistype(0).next
            loop
                exitwhen this == 0
                if UnitAlive(this.u) then
                    call SetWidgetLife(this.u, GetWidgetLife(this.u) + this.rate*GetUnitState(this.u, UNIT_STATE_MAX_LIFE))
                endif
                set this = this.next
            endloop
        endmethod
        
        private static method ultimates takes nothing returns boolean
            local unit u = GetTriggerUnit()
            local integer id = GetHandleId(u)
            local thistype this
            if thistype.tb.has(id) then
                set this = thistype.tb[id]
                set this.rate = Regen(11)
            endif
            set u = null
            return false
        endmethod
        
        private static method learn takes nothing returns nothing   
            local thistype this
            local unit u
            local integer id
            if GetLearnedSkill() == SPELL_ID then
                set u = GetTriggerUnit()
                set id = GetHandleId(u)
                if not thistype.tb.has(id) then
                    set this = thistype.allocate()
                    set this.u = u
                    set thistype.tb[id] = this
                    set this.prev = thistype(0).prev
                    set this.next = thistype(0)
                    set this.prev.next = this
                    set this.next.prev = this
                    if thistype(0).next == this then
                        call TimerStart(thistype.t, TIMEOUT, true, function thistype.pickAll)
                    endif
                    call UnitAddAbility(u, RABID_BUFF)
                    call UnitMakeAbilityPermanent(u, true, RABID_BUFF)
                else
                    set this = thistype.tb[id]
                endif
                set this.rate = Regen(GetUnitAbilityLevel(this.u, SPELL_ID))*TIMEOUT/100
                set u = null
            endif
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_SKILL, function thistype.learn)
            call PlayerStat.ultimateEvent(function thistype.ultimates)
            set thistype.tb = Table.create
            set thistype.t = CreateTimer()
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope