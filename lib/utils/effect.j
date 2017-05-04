library Effect uses TimerUtilsEx, DummyRecycler

/*
    Effect.create(string, x, y, z, angle)
        - Create an Effect instnace, a special effect attached to a dummy facing <angle>.

    Effect.createAnyAngle(string, x, y, z)
       - Create an Effect instnace, a special effect attached to a dummy facing random angle.

    this.duration = <duration>
        - How long the Effect lasts.

    this.scale = <newScale>
        - Set the scale of the Effect.

    this.destroy()
        - Destroy the Effect instance.
*/

    globals
        private constant real ALLOCATED_DESTROY_TIME = 5.0
    endglobals

    struct Effect extends array
        implement Alloc

        private unit u
        private effect e
        private timer t

        method destroy takes nothing returns nothing
            if this.t != null then
                call ReleaseTimer(this.t)
                set this.t = null
            endif
            call DummyAddRecycleTimer(this.u, ALLOCATED_DESTROY_TIME)
            call DestroyEffect(this.e)
            set this.u = null
            set this.e = null
            call this.deallocate()
        endmethod

        private static method expires takes nothing returns nothing
            call thistype(GetTimerData(GetExpiredTimer())).destroy()
        endmethod

        method operator facing= takes real r returns nothing
            call SetUnitFacing(this.u, r)
        endmethod

        method operator facing takes nothing returns real
            return GetUnitFacing(this.u)
        endmethod

        method operator x takes nothing returns real
            return GetUnitX(this.u)
        endmethod

        method operator y takes nothing returns real
            return GetUnitY(this.u)
        endmethod

        method operator duration= takes real r returns nothing
            if this.t == null then
                set this.t = NewTimerEx(this)
            endif
            call TimerStart(this.t, r, false, function thistype.expires)
        endmethod

        method operator scale= takes real r returns nothing
            call SetUnitScale(this.u, r, 0, 0)
        endmethod

        method setXY takes real x, real y returns nothing
            call SetUnitX(this.u, x)
            call SetUnitY(this.u, y)
        endmethod

        method setXYZ takes real x, real y, real z returns nothing
            call SetUnitX(this.u, x)
            call SetUnitY(this.u, y)
            call SetUnitZ(this.u, z)
        endmethod

        static method createAnyAngle takes string s, real x, real y, real z returns thistype
            local thistype this = thistype.allocate()
            set this.u = GetRecycledDummyAnyAngle(x, y, z)
            set this.e = AddSpecialEffectTarget(s, this.u, "origin")
            return this
        endmethod

        static method create takes string s, real x, real y, real z, real angle returns thistype
            local thistype this = thistype.allocate()
            set this.u = GetRecycledDummy(x, y, z, angle)
            set this.e = AddSpecialEffectTarget(s, this.u, "origin")
            return this
        endmethod

    endstruct

endlibrary