library Lightning requires SetUnitZ

/*
    Lightning.createUnits(string codeName, unit source, unit target)
        - Create a lightning attached to both units. Lightning periodically updates position

    Lightning.createPoints(string codeName, real x1, real y1, real z1, real x2, real y2, real z2)
        - Create a lightning at a specific location.

    this.duration = <lightning duration>
        - Lightning duration.

    this.startColor(real red, real green, real blue, real alpha)
        - Sets the starting color of the lightning upon creation.

    this.endColor(real red, real green, real blue, real alpha)
        - Sets the ending color of the lightning before it is destroyed.

    this.sourceZ = <height offset>
        - Sets a Z-offset for the lightning source

    this.targetZ = <height offset>
        - Sets a Z-offset for the lightning target

    this.destroy()
        - Destroy a Lightning instance.
*/
    globals
        private constant real TIMEOUT = 0.03125
        private constant real Z_OFFSET = 50.0
    endglobals

    struct Lightning extends array
        implement Alloc

        private lightning l
        private unit source
        private unit target
        private boolean list
        private real dur

        public real sourceZ
        public real targetZ

        //Colors
        private real r
        private real g
        private real b
        private real a
        private real dr
        private real dg
        private real db
        private real da
        private boolean color
        private real fullDur

        private thistype next
        private thistype prev
        private static timer t = CreateTimer()

        method pop takes nothing returns nothing
            if this.list then
                set this.prev.next = this.next
                set this.next.prev = this.prev
                if thistype(0).next == 0 then
                    call PauseTimer(thistype.t)
                endif
                set this.list = false
            endif
        endmethod

        method destroy takes nothing returns nothing
            call this.pop()
            call DestroyLightning(this.l)
            set this.l = null
            set this.source = null
            set this.target = null
            set this.color = false
            call this.deallocate()
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this = thistype(0).next
            local real factor
            loop
                exitwhen this == 0
                if this.dur > 0 or this.dur == -1 then
                    if this.dur > 0 then
                        set this.dur = this.dur - TIMEOUT
                    endif
                    if this.source != null and this.target != null then
                        call MoveLightningEx(this.l, true, GetUnitX(this.source), GetUnitY(this.source), GetUnitZ(this.source) + this.sourceZ, GetUnitX(this.target), GetUnitY(this.target), GetUnitZ(this.target) + this.targetZ)
                    endif
                    if this.color then
                        set factor = (this.fullDur - this.dur)/this.fullDur
                        call SetLightningColor(this.l, this.r + this.dr*factor, this.g + this.dg*factor, this.b + this.db*factor, this.a + this.da*factor)
                    endif
                else
                    call this.destroy()
                endif
                set this = this.next
            endloop
        endmethod

        method push takes nothing returns nothing
            if not this.list then
                set this.list = true
                set this.next = thistype(0)
                set this.prev = thistype(0).prev
                set this.next.prev = this
                set this.prev.next = this
                if this.prev == 0 then
                    call TimerStart(thistype.t, TIMEOUT, true, function thistype.onPeriod)
                endif
            endif
        endmethod

        method operator duration takes nothing returns real
            return this.dur
        endmethod

        method operator duration= takes real r returns nothing
            if not this.list then
                set this.list = true
                call this.push()
            endif
            set this.dur = r
            set this.fullDur = r
        endmethod

        method endColor takes real r, real g, real b, real a returns nothing
            set this.dr = r - this.r
            set this.dg = g - this.g
            set this.db = b - this.b
            set this.da = a - this.a
        endmethod

        method startColor takes real r, real g, real b, real a returns nothing
            set this.color = true
            set this.r = r
            set this.g = g
            set this.b = b
            set this.a = a
            call SetLightningColor(this.l, r, g, b, a)
            call this.push()
        endmethod

        static method createUnits takes string codeName, unit source, unit target returns thistype
            local thistype this = thistype.allocate()
            set this.source = source
            set this.target = target
            set this.sourceZ = Z_OFFSET
            set this.targetZ = Z_OFFSET
            set this.l = AddLightningEx(codeName, true, GetUnitX(source), GetUnitY(source), GetUnitZ(source) + this.sourceZ, GetUnitX(target), GetUnitY(target), GetUnitZ(target) + this.targetZ)
            set this.dur = -1
            call this.push()
            return this
        endmethod

        static method createPoints takes string codeName, real x1, real y1, real z1, real x2, real y2, real z2 returns thistype
            local thistype this = thistype.allocate()
            set this.l = AddLightningEx(codeName, true, x1, y1, z1, x2, y2, z2)
            set this.dur = -1
            return this
        endmethod

    endstruct

endlibrary