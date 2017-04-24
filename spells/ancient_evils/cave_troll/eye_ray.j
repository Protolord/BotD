scope EyeRay
    
    globals
        private constant integer SPELL_ID = 'A832'
        private constant integer BUFF_ID = 'B832'
        private constant integer UNIT_ID = 'uEyR'
        private constant real TIMEOUT = 0.0625
        private constant real DISTANCE = 200.0
    endglobals

    private function Range_Day takes integer level returns real
        if level == 11 then
            return GLOBAL_SIGHT
        endif
        return 1800 + 100.0*level
    endfunction

    private function Range_Night takes integer level returns real
        if level == 11 then
            return GLOBAL_SIGHT
        endif
        return 1800 + 100.0*level
    endfunction

    private struct Vision extends array
        implement Alloc

        private unit u

        private thistype next
        private thistype prev

        method destroy takes nothing returns nothing
            set this.prev.next = this.next
            set this.next.prev = this.prev
            call RemoveUnit(this.u)
            set this.u = null
            call this.deallocate()
        endmethod

        static method create takes thistype head, real x, real y, player p returns thistype
            local thistype this = thistype.allocate()
            set this.next = head
            set this.prev = head.prev
            set this.next.prev = this
            set this.prev.next = this
            set this.u = CreateUnit(p, UNIT_ID, x, y, 0)
            return this
        endmethod

        static method head takes nothing returns thistype
            local thistype this = thistype.allocate()
            set this.next = this
            set this.prev = this
            return this
        endmethod

        method clear takes nothing returns nothing
            local thistype node = this.next
            loop
                exitwhen node == this
                call node.destroy()
                set node = node.next
            endloop
        endmethod

        method update takes unit u, real range returns nothing
            local thistype node = this.next
            local real facing = GetUnitFacing(u)*bj_DEGTORAD
            local real r = DISTANCE
            local real x
            local real y
            loop
                exitwhen node == this and r >= range
                if r < range then
                    set x = GetUnitX(u) + r*Cos(facing)
                    set y = GetUnitY(u) + r*Sin(facing)
                    if node == this then
                        set node = thistype.create(this, x, y, GetOwningPlayer(u))
                    endif
                    call SetUnitX(node.u, x)
                    call SetUnitY(node.u, y)
                else
                    call node.destroy()
                endif
                set r = r + DISTANCE
                set node = node.next
            endloop
        endmethod
    endstruct
    
    struct EyeRay extends array
        implement Alloc
        implement List
        
        private unit u
        private real range
        private Vision visionHead
        private fogmodifier fm

        private static Table tb
        
        private static method onPeriod takes nothing returns nothing
            local thistype this = thistype(0).next
            loop
                exitwhen this == 0
                if UnitAlive(this.u) then
                    if this.range < GLOBAL_SIGHT then
                        call this.visionHead.update(this.u, this.range)
                    elseif this.fm == null then 
                        set this.fm = CreateFogModifierRect(GetOwningPlayer(this.u), FOG_OF_WAR_VISIBLE, WorldBounds.world, true, false)
                        call FogModifierStart(this.fm) 
                    endif
                else
                    if this.range < GLOBAL_SIGHT then
                        call this.visionHead.clear()
                    elseif this.fm != null then 
                        call DestroyFogModifier(this.fm)
                        set this.fm = null
                    endif
                endif
                set this = this.next
            endloop
        endmethod

        private static method day takes nothing returns boolean
            local thistype this = thistype(0).next
            loop
                exitwhen this == 0
                set this.range = Range_Day(GetUnitAbilityLevel(this.u, SPELL_ID))
                set this = this.next
            endloop
            return false
        endmethod

        private static method night takes nothing returns boolean
            local thistype this = thistype(0).next
            loop
                exitwhen this == 0
                set this.range = Range_Night(GetUnitAbilityLevel(this.u, SPELL_ID))
                set this = this.next
            endloop
            return false
        endmethod
        
        private static method ultimates takes nothing returns boolean
            local unit u = GetTriggerUnit()
            local integer id = GetHandleId(u)
            local thistype this
            if thistype.tb.has(id) then
                set this = thistype.tb[id]
                if DayNight.get() == TIME_DAY then
                    set this.range = Range_Day(11)
                else
                    set this.range = Range_Night(11)
                endif
            endif
            set u = null
            return false
        endmethod
        
        private static method learn takes nothing returns nothing   
            local thistype this
            local unit u
            local integer id
            local integer lvl
            if GetLearnedSkill() == SPELL_ID then
                set u = GetTriggerUnit()
                set id = GetHandleId(u)
                if not thistype.tb.has(id) then
                    set this = thistype.allocate()
                    set this.u = u
                    set this.visionHead = Vision.head()
                    set thistype.tb[id] = this
                    call this.push(TIMEOUT)
                    call UnitAddAbility(u, BUFF_ID)
                    call UnitMakeAbilityPermanent(u, true, BUFF_ID)
                else
                    set this = thistype.tb[id]
                endif
                set lvl = GetUnitAbilityLevel(u, SPELL_ID)
                if DayNight.get() == TIME_DAY then
                    set this.range = Range_Day(lvl)
                else
                    set this.range = Range_Night(lvl)
                endif
                set u = null
            endif
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_SKILL, function thistype.learn)
            call PlayerStat.ultimateEvent(function thistype.ultimates)
            call DayNight.registerDay(function thistype.day)
            call DayNight.registerNight(function thistype.night)
            set thistype.tb = Table.create()
            call PreloadUnit(UNIT_ID)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope