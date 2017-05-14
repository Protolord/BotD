scope DeadlyRepulse

    globals
        private constant integer SPELL_ID = 'A6XX'
        private constant integer UNIT_ID = 'uDeR'
        private constant real OFFSET = 100.0
        private constant real RADIUS = 400.0
        private constant real TIMEOUT = 1.0
    endglobals

    struct DeadlyRepulse extends array
        implement Alloc

        private unit ward
        private timer t

        private static group g

        private method destroy takes nothing returns nothing
            call ReleaseTimer(this.t)
            set this.t = null
            set this.ward = null
            call this.deallocate()
        endmethod

        private method search takes nothing returns nothing
            local player p = GetOwningPlayer(this.ward)
            local unit u
            if UnitAlive(this.ward) then
                call GroupEnumUnitsInRange(thistype.g, GetUnitX(this.ward), GetUnitY(this.ward), RADIUS,null)
                loop
                    set u = FirstOfGroup(thistype.g)
                    exitwhen u == null
                    call GroupRemoveUnit(thistype.g, u)
                    if UnitAlive(u) and IsUnitEnemy(u, p) then
                        if GetUnitCurrentOrder(this.ward) != ORDER_attack then
                            call IssueTargetOrderById(this.ward, ORDER_attack, u)
                        endif
                        exitwhen true
                    endif
                endloop
            else
                call this.destroy()
            endif
        endmethod

        private static method onPeriod takes nothing returns nothing
            call thistype(GetTimerData(GetExpiredTimer())).search()
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            local unit caster = GetTriggerUnit()
            local real angle = GetUnitFacing(caster)*bj_DEGTORAD
            local real x = GetUnitX(caster) + OFFSET*Cos(angle)
            local real y = GetUnitY(caster) + OFFSET*Sin(angle)
            local unit u
            set this.ward = CreateUnit(GetTriggerPlayer(), UNIT_ID, x, y, angle*bj_RADTODEG + 25)
            set this.t = NewTimerEx(this)
            set Invisible.create(this.ward, 0).autoDestroy = true
            call TimerStart(this.t, TIMEOUT, true, function thistype.onPeriod)
            call this.search()
            set caster = null
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call PreloadUnit(UNIT_ID)
            set thistype.g = CreateGroup()
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SystemTest.end()
        endmethod

    endstruct

endscope