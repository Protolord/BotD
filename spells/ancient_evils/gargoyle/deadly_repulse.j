scope DeadlyRepulse
 
    globals
        private constant integer SPELL_ID = 'A6XX'
        private constant integer UNIT_ID = 'uDeR'
        private constant real OFFSET = 100.0
        private constant real RADIUS = 400.0
    endglobals
    
    struct DeadlyRepulse extends array

        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local real angle = GetUnitFacing(caster)*bj_DEGTORAD
            local real x = GetUnitX(caster) + OFFSET*Cos(angle)
            local real y = GetUnitY(caster) + OFFSET*Sin(angle)
            local unit w = CreateUnit(GetTriggerPlayer(), UNIT_ID, x, y, angle*bj_RADTODEG + 25)
            local group g = NewGroup()
            local player p = GetTriggerPlayer()
            local unit u
            set Invisible.create(w, 0).autoDestroy = true
            call GroupUnitsInArea(g, x, y, RADIUS)
            loop
                set u = FirstOfGroup(g)
                exitwhen u == null
                call GroupRemoveUnit(g, u)
                if UnitAlive(u) and IsUnitEnemy(u, p) then
                    call IssueTargetOrderById(w, ORDER_smart, u)
                    exitwhen true
                endif
            endloop
            call ReleaseGroup(g)
            set p = null
            set g = null
            set caster = null
            set w = null
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call PreloadUnit(UNIT_ID)
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope