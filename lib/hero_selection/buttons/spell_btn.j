library SpellButton/*

*/ requires /*
    */ SpellDisplay /*
    */ SystemConsole /*
*/

    struct SpellButton extends array
        implement Alloc

        public TrackList tHead

        public static real buttonX
        public static real buttonY
        public static thistype global
        public static integer order
        public static integer spellNum

        public static integer orderCtr = 1
        public static integer array spellNumValues
        public static integer array orderValues

        public thistype next
        public thistype prev

        method destroy takes nothing returns nothing
            local TrackList tl = this.tHead.next
            set this.prev.next = this.next
            set this.next.prev = this.prev
            loop
                exitwhen tl == 0
                call tl.destroy()
                set tl = tl.next
            endloop
            call this.deallocate()
        endmethod

        static method destroyAll takes nothing returns nothing
            local thistype this = thistype(0).next
            loop
                exitwhen this == 0
                call this.destroy()
                set this = this.next
            endloop
        endmethod

        method hide takes player p returns nothing
            local TrackList tl = this.tHead.next
            loop
                exitwhen tl == 0
                if tl.p == p then
                    set tl.t.enabled = false
                    exitwhen true
                endif
                set tl = tl.next
            endloop
        endmethod

        static method hideAll takes player p returns nothing
            local thistype this = thistype(0).next
            call SystemTest.start("Disabling SpellButtons for " + GetPlayerName(p) + ": ")
            loop
                exitwhen this == 0
                call this.hide(p)
                set this = this.next
            endloop
            call SystemTest.end()
        endmethod

        static method clicked takes nothing returns nothing
            local PlayerStat ps = GetPlayerId(Track.tracker)
            local integer spellNum = thistype.spellNumValues[Track.instance]
            local integer order = thistype.orderValues[Track.instance]
            call SpellDisplay.change(Track.tracker, spellNum, order)
            if ps.spell1 != Spell.BLANK and ps.spell2 != Spell.BLANK and ps.spell3 != Spell.BLANK and ps.spell4 != Spell.BLANK then
                call ConfirmButton.show(Track.tracker, true)
            endif
        endmethod

        public static method changeButtonPos takes integer spellNum, integer order returns nothing
            set spellBtnX[spellNum*4 + order] = thistype.buttonX
            set spellBtnY[spellNum*4 + order] = thistype.buttonY
            set thistype.buttonX = thistype.buttonX + SPELL_BUTTON_SPACING
            if thistype.orderCtr > 4 then
                set thistype.orderCtr = 1
                set thistype.buttonX = thistype.buttonX + SPELL_GROUP_BUTTON_SPACING
            endif
        endmethod

        public static method createTrack takes nothing returns nothing
            local thistype this = thistype.global
            local player p = GetEnumPlayer()
            local Track t = Track.createForPlayer(TRACK_PATH_SMALL, thistype.buttonX, thistype.buttonY, 1, 270, p)
            call t.registerClick(function thistype.clicked)
            set thistype.spellNumValues[t] = thistype.spellNum
            set thistype.orderValues[t] = thistype.order
            call TrackList.create(this.tHead, t, p)
        endmethod

        public static method create takes integer spellNum, integer order returns thistype
            local thistype this = thistype.allocate()
            set this.tHead = TrackList.head()
            set thistype.spellNum = spellNum
            set thistype.order = order
            //Create a trackable for each group
            set thistype.global = this
            call ForForce(Players.users, function thistype.createTrack)
            //Update button position
            set thistype.orderCtr = thistype.orderCtr + 1
            call thistype.changeButtonPos(spellNum, order)
            set this.next = 0
            set this.prev = thistype(0).prev
            set this.next.prev = this
            set this.prev.next = this
            return this
        endmethod

        //! textmacro SELECTION_SYSTEM_SPELL_CREATE takes NUM
            call SpellButton.create($NUM$,1)
            call SpellButton.create($NUM$,2)
            call SpellButton.create($NUM$,3)
            call SpellButton.create($NUM$,4)
        //! endtextmacro

        static method init takes nothing returns boolean
            call SystemTest.start("Creating SpellButtons: ")
            set thistype.buttonX = SPELL_BUTTON_ORIGIN_X
            set thistype.buttonY = SPELL_BUTTON_ORIGIN_Y
            //! runtextmacro SELECTION_SYSTEM_SPELL_CREATE("1")
            //! runtextmacro SELECTION_SYSTEM_SPELL_CREATE("2")
            //! runtextmacro SELECTION_SYSTEM_SPELL_CREATE("3")
            //! runtextmacro SELECTION_SYSTEM_SPELL_CREATE("4")
            call SystemTest.end()
            return false
        endmethod

    endstruct

endlibrary