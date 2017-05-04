library Border

    struct Border extends array
        implement Alloc

        public lightning lineTop
        public lightning lineBot
        public lightning lineRight
        public lightning lineLeft
        public real height
        public real length
        public real red
        public real green
        public real blue

        method move takes real x, real y returns nothing
            local real h = 0.5*this.height
            local real l = 0.5*this.length
            call MoveLightningEx(this.lineTop, false, x - l, y + h, 0, x + l, y + h, 0)
            call MoveLightningEx(this.lineBot, false, x - l, y - h, 0, x + l, y - h, 0)
            call MoveLightningEx(this.lineRight, false, x + l, y + h, 0, x + l, y - h, 0)
            call MoveLightningEx(this.lineLeft, false, x - l, y + h, 0, x - l, y - h, 0)
        endmethod

        method destroy takes nothing returns nothing
            call DestroyLightning(this.lineTop)
            call DestroyLightning(this.lineBot)
            call DestroyLightning(this.lineRight)
            call DestroyLightning(this.lineLeft)
            set this.lineTop = null
            set this.lineBot = null
            set this.lineRight = null
            set this.lineLeft = null
            set this.height = 0
            set this.length = 0
            call this.deallocate()
        endmethod

        method show takes boolean flag returns nothing
            if flag then
                call SetLightningColor(this.lineTop, this.red, this.green, this.blue, 1)
                call SetLightningColor(this.lineBot, this.red, this.green, this.blue, 1)
                call SetLightningColor(this.lineRight, this.red, this.green, this.blue, 1)
                call SetLightningColor(this.lineLeft, this.red, this.green, this.blue, 1)
            else
                call SetLightningColor(this.lineTop, 1, 1, 1, 0)
                call SetLightningColor(this.lineBot, 1, 1, 1, 0)
                call SetLightningColor(this.lineRight, 1, 1, 1, 0)
                call SetLightningColor(this.lineLeft, 1, 1, 1, 0)
            endif
        endmethod

        method color takes real red, real green, real blue returns nothing
            set this.red = red
            set this.green = green
            set this.blue = blue
            call SetLightningColor(this.lineTop, this.red, this.green, this.blue, 1)
            call SetLightningColor(this.lineBot, this.red, this.green, this.blue, 1)
            call SetLightningColor(this.lineRight, this.red, this.green, this.blue, 1)
            call SetLightningColor(this.lineLeft, this.red, this.green, this.blue, 1)
        endmethod

        static method create takes real top, real bot, real right, real left returns thistype
            local thistype this = thistype.allocate()
            set this.lineTop = AddLightningEx(LINE, false, left, top, 0, right, top, 0)
            set this.lineBot = AddLightningEx(LINE, false, left, bot, 0, right, bot, 0)
            set this.lineRight = AddLightningEx(LINE, false, right, top, 0, right, bot, 0)
            set this.lineLeft = AddLightningEx(LINE, false, left, top, 0, left, bot, 0)
            set this.height = top - bot
            set this.length = right - left
            set this.red = 1
            set this.green = 1
            set this.blue = 1
            return this
        endmethod

    endstruct

endlibrary