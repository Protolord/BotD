scope ChildOfTheNight
    
    globals
        private constant integer SPELL_ID = 'A232'
        private constant integer SPELL_BUFF = 'B232'
        private constant integer BUFF_ID = 'b232'
    endglobals
    
    private function Radius takes integer level returns real
        if level == 11 then
            return 2000.0
        endif
        return 100.0*level
    endfunction
    
    struct ChildOfTheNight
        
        private FlySight reveal
        private TrueSight sight
        private thistype next
        private unit u
        private player owner
        private integer lvl
        
        private static Table tb
        
        
        private static method day takes nothing returns boolean
            local thistype this = thistype(0).next
            loop
                exitwhen this == 0
                if this.sight > 0 then
                    call this.sight.destroy()
                    set this.sight = 0
                endif
                if this.reveal > 0 then
                    call this.reveal.destroy()
                    set this.reveal = 0
                endif
                call UnitRemoveAbility(this.u, SPELL_BUFF)
                call UnitRemoveAbility(this.u, BUFF_ID)
                set this = this.next
            endloop
            return false
        endmethod
        
        private static method night takes nothing returns boolean
            local thistype this = thistype(0).next
            loop
                exitwhen this == 0
                if this.lvl < 11 then
                    if this.sight == 0 then
                        set this.sight = TrueSight.create(this.u, Radius(this.lvl))
                    endif
                else
                    if this.reveal == 0 then
                        set this.reveal = FlySight.create(this.u, Radius(this.lvl))
                    endif
                endif
                call UnitAddAbility(this.u, SPELL_BUFF)
                call UnitMakeAbilityPermanent(this.u, true, SPELL_BUFF)
                set this = this.next
            endloop
            return false
        endmethod
        
        private static method start takes unit u, integer level returns nothing
            local integer id = GetHandleId(u)
            local thistype this
            local real time
            if not thistype.tb.has(id) then
                set this = thistype.allocate()
                set this.next = thistype(0).next
                set thistype(0).next = this
                set this.u = u
                set this.owner = GetOwningPlayer(u)
                set thistype.tb[id] = this
            else
                set this = thistype.tb[id]
            endif
            set this.lvl = level
            set time = GetFloatGameState(GAME_STATE_TIME_OF_DAY)
            if not (time >= 6.00 and time < 18.00) then //If it learned during night time
                if this.lvl < 11 then
                    if this.sight > 0 then
                        //Update true sight radius
                        set this.sight.radius = Radius(this.lvl)
                    else
                        set this.sight = TrueSight.create(u, Radius(this.lvl))
                    endif
                else
                    if this.sight > 0 then
                        call this.sight.destroy()
                        set this.sight = 0
                    endif
                    if this.reveal == 0 then
                        set this.reveal = FlySight.create(u, Radius(this.lvl))
                    endif
                endif
                call UnitAddAbility(u, SPELL_BUFF)
                call UnitMakeAbilityPermanent(u, true, SPELL_BUFF)
            endif
        endmethod
        
        private static method ultimates takes nothing returns boolean
            local unit u = GetTriggerUnit()
            local integer id = GetHandleId(u)
            local thistype this
            if thistype.tb.has(id) then
                set this = thistype.tb[id]
                call thistype.start(u, 11)
            endif
            set u = null
            return false
        endmethod
        
        private static method learn takes nothing returns nothing
            if GetLearnedSkill() == SPELL_ID then
                call thistype.start(GetTriggerUnit(), GetUnitAbilityLevel(GetTriggerUnit(), SPELL_ID))
            endif
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call DayNight.registerDay(function thistype.day)
            call DayNight.registerNight(function thistype.night)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_SKILL, function thistype.learn)
            call PlayerStat.ultimateEvent(function thistype.ultimates)
            set thistype.tb = Table.create()
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope