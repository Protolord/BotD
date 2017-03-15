library FlySight uses TimerUtilsEx

/*
    FlySight.create(unit, radius)
        - Create FlySight attached to unit.

    FlySight.createEx(unit, radius, duration)
        - Create FlySight attached to unit for a period of time.

    this.radius = <new radius>
        - Change FlySight radius.

    this.destroy()
        - Destroy the FlySight instance.
*/

    globals
        constant real GLOBAL_SIGHT = 99999.0
        constant real MIN_SIGHT = 256.0
        private constant real TIMEOUT = 0.125
    endglobals
    
    struct FlySight extends array
        implement Alloc
        
        private real priv_radius
        private unit u
        private real x
        private real y
        private player owner
        private fogmodifier fm
    
        
        method destroy takes nothing returns nothing
            call DestroyFogModifier(this.fm)
            call this.pop()
            set this.fm = null
            set this.u = null
            set this.owner = null
            call this.deallocate()
        endmethod
        
        method operator radius takes nothing returns real
            return this.priv_radius
        endmethod
        
        method operator radius= takes real newRadius returns nothing
            set this.priv_radius = RMaxBJ(newRadius, MIN_SIGHT)
            call DestroyFogModifier(this.fm)
            if this.priv_radius == GLOBAL_SIGHT then
                set this.fm = CreateFogModifierRect(this.owner, FOG_OF_WAR_VISIBLE, WorldBounds.world, true, false)
            else
                set this.fm = CreateFogModifierRadius(this.owner, FOG_OF_WAR_VISIBLE, this.x, this.y, this.priv_radius, true, false)
            endif
            call FogModifierStart(this.fm)
        endmethod
        
        private static method onPeriod takes nothing returns nothing
            local thistype this = thistype(0).next
            local boolean b
            loop
                exitwhen this == 0
                if UnitAlive(this.u) then
                    set b = GetOwningPlayer(this.u) == this.owner 
                    if not(b and this.x == GetUnitX(this.u) and this.y == GetUnitY(this.u)) then
                        if not b then
                            set this.owner = GetOwningPlayer(this.u)
                        endif
                        set this.x = GetUnitX(this.u)
                        set this.y = GetUnitY(this.u)
                        //Only recreate if it is a new owner or it is not global sight
                        //Global sights does not need to be re-created because they provide the same vision.
                        if this.priv_radius < GLOBAL_SIGHT or not b then
                            call DestroyFogModifier(this.fm)
                            set this.fm = CreateFogModifierRadius(this.owner, FOG_OF_WAR_VISIBLE, this.x, this.y, this.priv_radius, true, false)
                            call FogModifierStart(this.fm)
                        endif
                    endif
                else
                    call this.destroy()
                endif
                set this = this.next
            endloop
        endmethod

        implement List
        
        static method create takes unit u, real radius returns thistype
            local thistype this = thistype.allocate()
            set this.u = u
            set this.priv_radius = RMaxBJ(radius, MIN_SIGHT)
            set this.x = GetUnitX(u)
            set this.y = GetUnitY(u)
            set this.owner = GetOwningPlayer(u)
            if radius == GLOBAL_SIGHT then
                set this.fm = CreateFogModifierRect(this.owner, FOG_OF_WAR_VISIBLE, WorldBounds.world, true, false)
            else
                set this.fm = CreateFogModifierRadius(this.owner, FOG_OF_WAR_VISIBLE, this.x, this.y, this.priv_radius, true, false)
            endif
            call FogModifierStart(this.fm)
            call this.push(TIMEOUT)
            return this
        endmethod
        
        private static method expires takes nothing returns nothing
            local thistype this = ReleaseTimer(GetExpiredTimer())
            if this.fm != null then
                call this.destroy()
            endif
        endmethod
        
        static method createEx takes unit u, real radius, real time returns thistype
            local thistype this = thistype.create(u, radius)
            call TimerStart(NewTimerEx(this), time, false, function thistype.expires)
            return this
        endmethod
    endstruct
    
endlibrary