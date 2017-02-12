scope EyeOfDarkness
    
    globals
        private constant integer SPELL_ID = 'A131'
        private constant string MODEL = "Models\\Effects\\EyeOfDarkness.mdx"
        private constant real EYE_SPACING = 300
        private constant player NEUTRAL = Player(14)
    endglobals
    
    private function Radius takes integer level returns real
        if level == 11 then
            return GLOBAL_SIGHT
        endif
        return 250.0*level
    endfunction
    
    private function Duration takes integer level returns real
        return 9.0 + 0.0*level
    endfunction
    
    private struct Eye extends array
        implement Alloc
        
        readonly unit unit
        private effect sfx
        
        readonly thistype next
        readonly thistype prev
        
        method destroy takes nothing returns nothing
            if this.unit != null then
                call DummyAddRecycleTimer(this.unit, 1.0)
                call UnitClearBonus(this.unit, BONUS_SIGHT_RANGE)
                call SetUnitOwner(this.unit, NEUTRAL, false)
                set this.unit = null
            endif
            if this.sfx != null then
                call DestroyEffect(this.sfx)
                set this.sfx = null
            endif
            set this.prev.next = this.next
            set this.next.prev = this.prev
            call this.deallocate()
        endmethod

        static method create takes player owner, thistype head, real x, real y, real angle, real scale returns thistype
            local thistype this

            if x < WorldBounds.maxX and x > WorldBounds.minX and y < WorldBounds.maxY and y > WorldBounds.minY then
                set this = thistype.allocate()
                set this.unit = GetRecycledDummy(x, y, 0, angle*bj_RADTODEG)
                call SetUnitScale(this.unit, scale, 0, 0)
                set this.sfx = AddSpecialEffectTarget(MODEL, this.unit, "origin")
                call SetUnitOwner(this.unit, owner, false)
                call UnitSetBonus(this.unit, BONUS_SIGHT_RANGE, 100)
                set this.next = head
                set this.prev = head.prev
                set this.next.prev = this
                set this.prev.next = this
                return this
            endif
            return 0
        endmethod
        
        static method head takes nothing returns thistype
            local thistype this = thistype.allocate()
            set this.next = this
            set this.prev = this
            return this
        endmethod
        
    endstruct
    
    struct EyeOfDarkness extends array
        implement Alloc
        
        private fogmodifier fm
        private Eye head
        private TrueSight ts
        
        method destroy takes nothing returns nothing
            local Eye e = this.head.next
            loop
                exitwhen e == this.head
                call e.destroy()
                set e = e.next
            endloop
            call this.head.destroy()
            call DestroyFogModifier(this.fm)
            set this.fm = null
            call this.deallocate()
        endmethod
        
        private static method expire takes nothing returns nothing
            call thistype(ReleaseTimer(GetExpiredTimer())).destroy()
        endmethod
        
        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            local unit u = GetTriggerUnit()
            local player owner = GetTriggerPlayer()
            local integer level = GetUnitAbilityLevel(u, SPELL_ID)
            local real x = GetSpellTargetX()
            local real y = GetSpellTargetY()
            local real radius = Radius(level)
            local real newScale
            local real da
            local real angle
            local real endAngle
            local Eye e
            set this.head = Eye.head()
            if radius == GLOBAL_SIGHT then
                set this.fm = CreateFogModifierRect(owner, FOG_OF_WAR_VISIBLE, WorldBounds.world, true, false)
                set e = Eye.create(owner, this.head, x, y, -0.5*bj_PI, 5.0)
                call SetUnitOwner(e.unit, owner, false)
                set this.ts = TrueSight.create(e.unit, radius)
            else
                set this.fm = CreateFogModifierRadius(owner, FOG_OF_WAR_VISIBLE, x, y, RMaxBJ(radius, MIN_SIGHT), true, false)
                set e = Eye.create(owner, this.head, x, y, -0.5*bj_PI, 1.0 + radius/750)
                call SetUnitOwner(e.unit, owner, false)
                set this.ts = TrueSight.create(e.unit, radius)
                if radius > 255 then
                    loop 
                        set da = 2*bj_PI/R2I(2*bj_PI*radius/EYE_SPACING)
                        if da > bj_PI/3 then
                            set da = bj_PI/3
                        endif
                        set newScale = 0.75 + radius/1000
                        set angle = da
                        set endAngle = da + 2*bj_PI - 0.0001
                        loop
                            exitwhen angle >= endAngle
                            call Eye.create(owner, this.head, x + radius*Cos(angle), y + radius*Sin(angle), angle - bj_PI, newScale)
                            set angle = angle + da
                        endloop
                        set radius = radius - 750
                        exitwhen radius < 400
                    endloop
                endif
            endif
            call FogModifierStart(this.fm)            
            call TimerStart(NewTimerEx(this), Duration(level), false, function thistype.expire)
            set u = null
            set owner = null
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope