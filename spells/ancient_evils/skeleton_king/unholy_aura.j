scope UnholyAura
    
    globals
        private constant integer SPELL_ID = 'A714'
        private constant integer BUFF_ID = 'B714'
        private constant real TIMEOUT = 0.1
    endglobals
    
    private function Regen takes integer level returns real
        if level == 11 then
            return 4.0
        endif
        return 1.0 + 0.2*level
    endfunction
    
    struct UnholyAura extends array
        implement Alloc
        implement Stack
        
        private unit u
        private real rate
        
        private static Table tb
        
        private static method onPeriod takes nothing returns nothing
            local thistype this = thistype.top
            loop
                exitwhen this == 0
                if UnitAlive(this.u) then
                    //call SetWidgetLife(this.u, GetWidgetLife(this.u) + this.rate*GetUnitState(this.u, UNIT_STATE_MAX_LIFE))
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
                    call this.push(TIMEOUT)
                    call UnitAddAbility(u, BUFF_ID)
                    call UnitMakeAbilityPermanent(u, true, BUFF_ID)
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
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope