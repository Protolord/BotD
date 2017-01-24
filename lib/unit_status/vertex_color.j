library VertexColor uses Table

/*
    VertexColor.create(unit, addRed, addGreen, addBlue, addAlpha)
        - Create a VertexColor instance to unit.
    
    VertexColor.get$COLOR$(unit)
        - Returns the current $COLOR$ vertex color of a unit.
        - $COLOR$ can be red/green/blue/alpha
    
    this.speed = <scaling speed>
        - Sets how fast the coloring happens.
        - Returns the current speed.
    
    this.duration = <scaling duration>
        - VertexColor instance duration.
    
    this.destroy()
        - Destroy VertexColor instance.

*/
    globals
        //Scaling Speed per second used as default.
        private constant integer DEFAULT_SPEED = 100
        private constant real TIMEOUT = 0.0625
    endglobals
    
    struct VertexColor
        
        //! textmacro VERTEX_COLOR_SYSTEM_ATTRIBUTES takes COLOR
            private integer $COLOR$add
            private integer $COLOR$sub
        //! endtextmacro
        
        //! runtextmacro VERTEX_COLOR_SYSTEM_ATTRIBUTES("red")
        //! runtextmacro VERTEX_COLOR_SYSTEM_ATTRIBUTES("green")
        //! runtextmacro VERTEX_COLOR_SYSTEM_ATTRIBUTES("blue")
        //! runtextmacro VERTEX_COLOR_SYSTEM_ATTRIBUTES("alpha")
        public real speed
        public real duration
        private unit u
        private integer id
        
        private static Table red
        private static Table green
        private static Table blue
        private static Table alpha
        private static Table count
        private static timer t = CreateTimer()
        
        private thistype next
        private thistype prev
        
        method destroy takes nothing returns nothing
            set this.duration = 0
        endmethod
        
        //! textmacro VERTEX_COLOR_SYSTEM_GET takes COLOR
            static method get$COLOR$ takes unit u returns integer
                local integer id = GetHandleId(u)
                if thistype.$COLOR$.has(id) then
                    return thistype.$COLOR$[id]
                endif
                return 255
            endmethod
        //! endtextmacro
        
        //! runtextmacro VERTEX_COLOR_SYSTEM_GET("red")
        //! runtextmacro VERTEX_COLOR_SYSTEM_GET("green")
        //! runtextmacro VERTEX_COLOR_SYSTEM_GET("blue")
        //! runtextmacro VERTEX_COLOR_SYSTEM_GET("alpha")
        
        //! textmacro VERTEX_COLOR_SYSTEM_CHANGE takes COLOR
            if this.$COLOR$add != 0 then
                if this.$COLOR$add > 0 then
                    set added = IMinBJ(this.$COLOR$add, R2I(this.speed*TIMEOUT))
                else
                    set added = -IMinBJ(IAbsBJ(this.$COLOR$add), R2I(this.speed*TIMEOUT))
                endif
                set this.$COLOR$add = this.$COLOR$add - added
                set this.$COLOR$sub = this.$COLOR$sub + added
                set new$COLOR$ = thistype.$COLOR$[this.id] + added
                set thistype.$COLOR$[this.id] = new$COLOR$
            else
                set new$COLOR$ = thistype.$COLOR$[this.id]
            endif
        //! endtextmacro
        
        //! textmacro VERTEX_COLOR_SYSTEM_REVERT takes COLOR
            if this.$COLOR$sub != 0 then
                if this.$COLOR$sub > 0 then
                    set added = IMinBJ(this.$COLOR$sub, R2I(this.speed*TIMEOUT))
                else
                    set added = -IMinBJ(IAbsBJ(this.$COLOR$sub), R2I(this.speed*TIMEOUT))
                endif
                set this.$COLOR$sub = this.$COLOR$sub - added
                set new$COLOR$ = thistype.$COLOR$[this.id] - added
                set thistype.$COLOR$[this.id] = new$COLOR$
            else
                set new$COLOR$ = thistype.$COLOR$[this.id]
            endif
        //! endtextmacro
        
        private static method onPeriod takes nothing returns nothing
            local thistype this = thistype(0).next
            local integer added
            local integer newred
            local integer newgreen
            local integer newblue
            local integer newalpha
            loop
                exitwhen this == 0
                set this.duration = this.duration - TIMEOUT
                if this.duration > 0 then
                    //! runtextmacro VERTEX_COLOR_SYSTEM_CHANGE("red")
                    //! runtextmacro VERTEX_COLOR_SYSTEM_CHANGE("green")
                    //! runtextmacro VERTEX_COLOR_SYSTEM_CHANGE("blue")
                    //! runtextmacro VERTEX_COLOR_SYSTEM_CHANGE("alpha")
                    call SetUnitVertexColor(this.u, newred, newgreen, newblue, newalpha)
                else
                    //! runtextmacro VERTEX_COLOR_SYSTEM_REVERT("red")
                    //! runtextmacro VERTEX_COLOR_SYSTEM_REVERT("green")
                    //! runtextmacro VERTEX_COLOR_SYSTEM_REVERT("blue")
                    //! runtextmacro VERTEX_COLOR_SYSTEM_REVERT("alpha")
                    call SetUnitVertexColor(this.u, newred, newgreen, newblue, newalpha)
                    if redsub == 0 and greensub == 0 and bluesub == 0 and alphasub == 0 then
                        set thistype.count[this.id] = thistype.count[this.id] - 1
                        if thistype.count[this.id] == 0 then
                            call thistype.red.remove(this.id)
                            call thistype.green.remove(this.id)
                            call thistype.blue.remove(this.id)
                            call thistype.alpha.remove(this.id)
                        endif
                        set this.next.prev = this.prev
                        set this.prev.next = this.next
                        if thistype(0).next == 0 then
                            call PauseTimer(thistype.t)
                        endif
                        set this.u = null
                        call this.deallocate()
                    endif
                endif
                set this = this.next
            endloop
        endmethod
        
        static method create takes unit u, integer r, integer g, integer b, integer a returns thistype
            local thistype this = thistype.allocate()
            set this.u = u
            set this.id = GetHandleId(u)
            set this.speed = DEFAULT_SPEED
            set this.redadd = r
            set this.greenadd = g
            set this.blueadd = b
            set this.alphaadd = a
            set this.redsub = 0
            set this.greensub = 0
            set this.bluesub = 0
            set this.alphasub = 0
            set this.duration = 0xFFFFFF
            if thistype.count[this.id] > 0 then
                set thistype.count[this.id] = thistype.count[this.id] + 1
            else
                set thistype.red[this.id] = 255
                set thistype.green[this.id] = 255
                set thistype.blue[this.id] = 255
                set thistype.alpha[this.id] = 255
                set thistype.count[this.id] = 1
            endif
            set this.next = thistype(0)
            set this.prev = thistype(0).prev
            set this.prev.next = this
            set this.next.prev = this
            if this.prev == 0 then
                call TimerStart(thistype.t, TIMEOUT, true, function thistype.onPeriod)
            endif
            return this
        endmethod
        
        private static method onInit takes nothing returns nothing
            set thistype.red = Table.create()
            set thistype.green = Table.create()
            set thistype.blue = Table.create()
            set thistype.alpha = Table.create()
            set thistype.count = Table.create()
        endmethod
        
    endstruct
    
endlibrary