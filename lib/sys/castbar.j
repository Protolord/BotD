library Castbar requires WorldBounds, TimerUtilsEx
    
/*
    Castbar.create(x, y, duration)
        - Create a Castbar at (x, y) with a certain duration.

    this.destroy()
        - Destroy the Castbar instance.
*/

    globals
        private constant real TIMEOUT = 0.05
        private constant integer CASTBAR_ID = 'cbar'
        private constant integer RED = 0
        private constant integer GREEN = 160
        private constant integer BLUE = 255
        private constant integer MAX_COUNT = 10
        private constant player OWNER = Player(PLAYER_NEUTRAL_PASSIVE)
        private constant real DEATH_DELAY = 0.15
    endglobals
    
    private struct Dummy extends array
        
        private unit u
        private thistype next
        
        private static Table tb
        private static integer count = 1
        
        private static method hide takes nothing returns nothing
            local thistype this = ReleaseTimer(GetExpiredTimer())
            call SetUnitX(this.u, WorldBounds.maxX)
            call SetUnitY(this.u, WorldBounds.maxY)
            set this.next = thistype(0).next
            set thistype(0).next = this
        endmethod
        
        static method recycle takes unit u returns nothing
            local thistype this = thistype.tb[GetHandleId(u)]
            call SetUnitVertexColor(u, RED, GREEN, BLUE, 100)
            if this == 0 then
                call UnitApplyTimedLife(u, 'BTLF', DEATH_DELAY)
            else
                call TimerStart(NewTimerEx(this), DEATH_DELAY, false, function thistype.hide)
            endif
        endmethod
        
        static method get takes real x, real y returns unit
            local thistype this = thistype(0).next
            if this == 0 then
                if thistype.count < MAX_COUNT then
                    set this = thistype.count
                    set this.u = CreateUnit(OWNER, CASTBAR_ID, x, y, 0)
                    call PauseUnit(this.u, true)
                    set thistype.tb[GetHandleId(this.u)] = this
                    set thistype.count = thistype.count + 1
                else
                    set bj_lastCreatedUnit = CreateUnit(OWNER, CASTBAR_ID, x, y, 0)
                    call PauseUnit(bj_lastCreatedUnit, true)
                    return bj_lastCreatedUnit
                endif
            else
                set thistype(0).next = this.next
                call SetUnitX(this.u, x)
                call SetUnitY(this.u, y)
            endif
            return this.u
        endmethod
        
        private static method onInit takes nothing returns nothing
            set thistype.tb = Table.create()
        endmethod
        
    endstruct
    
    struct Castbar
        
        private unit bar
        private real duration
        private real anim
        private real change
        
        private thistype next
        private thistype prev
        
        private static timer t = CreateTimer()
        
        method destroy takes nothing returns nothing
            set this.prev.next = this.next
            set this.next.prev = this.prev
            if thistype(0).next == 0 then
                call PauseTimer(thistype.t)
            endif
            call Dummy.recycle(this.bar)
            set this.bar = null
            call this.deallocate()
        endmethod
        
        private static method pickAll takes nothing returns nothing
            local thistype this = thistype(0).next
            loop
                exitwhen this == 0
                if this.anim < 100 then
                    set this.anim = this.anim + this.change
                    if this.anim > 100 then
                        set this.anim = 100
                    endif
                    call SetUnitAnimationByIndex(this.bar, R2I(this.anim))
                endif
                set this = this.next
            endloop
        endmethod
        
        static method create takes real x, real y, real duration returns thistype
            local thistype this = thistype.allocate()
            set this.duration = duration
            set this.anim = 0
            set this.change = 100.0*TIMEOUT/duration
            set this.bar = Dummy.get(x, y)
            call SetUnitVertexColor(this.bar, RED, GREEN, BLUE, 254)
            call SetUnitAnimationByIndex(this.bar, 0)
            set this.next = thistype(0)
            set this.prev = thistype(0).prev
            set this.next.prev = this
            set this.prev.next = this
            if this.prev == 0 then
                call TimerStart(thistype.t, TIMEOUT, true, function thistype.pickAll)
            endif
            return this
        endmethod
        
    endstruct
    
endlibrary