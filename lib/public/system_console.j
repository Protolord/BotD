library SystemConsole /*
                            SystemConsole v1.02
                                  by Flux

            SystemConsole is a text-console simulation for Warcraft 3.
            It main purpose is to display information to players in a
            console format thus it logs all messages displayed so
            players can view it again anytime. It can hold up to 8192
            line messages in its buffer.
            It can also be used as a debugging tool through its
            SystemTest feature.


    */ requires TimerUtilsEx/*
      (nothing)

    */ optional Table /*
     If not found, it will create a hashtable. Hashtables are limited to
     255 per map.


    Includes:
        * SystemMsg
            - The interface for displaying game messages.

            API:
                - SystemMsg.create(string msg)
                    Display message.

                - SystemMsg.createFor(force f, string msg)
                    Display message only to force f.

                - SystemMsg.createIf(boolean condition, string msg)
                    Display message if condition is true.

                - SystemMsg.refresh()
                    Refreshes the console. Works inside a local block.

                - set SystemMsg.show = true/false
                    Controls the visibility of System Messages.
                    Works inside a local block.



        * SystemTest
            - Test a function or a group of functions if it
              will execute without fail. Enclosed the function(s)
              to be tested between SystemTest.start(msg) and
              SystemTest.end().

            API:
                - SystemTest.start(string msg)
                    Starting block of SystemTest

                - SystemTest.startFor(force f, string msg)
                    Starting block of SystemTest that is only visible to force f.

                - SystemTest.end()
                    End block of SystemTest

    */

    globals
        //Duration of system messages
        private constant real DURATION = 10000

        //The time allotted for a SystemTest to finish before it is considered a failure
        private constant real DELAY = 0.25

        //Maximum number of lines saved in memory
        public constant integer BUFFER = 256
    endglobals

    struct SystemMsg extends array
        implement Alloc

        string value

        readonly thistype next
        readonly thistype prev

        private static boolean privShow = false
        readonly static integer count = 0
        static timer t = CreateTimer()

        static integer lineCount = 0
        static integer cursor = 16

        static method refresh takes nothing returns nothing
            local thistype this = thistype(0).next
            local integer i = 0
            local integer j = thistype.count - cursor
            if thistype.privShow then
                call ClearTextMessages()
                loop
                    exitwhen this == 0
                    if i >= j and i < j + 16 then
                        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, DURATION, this.value)
                    endif
                    set i = i + 1
                    set this = this.next
                endloop
            endif
        endmethod

        method destroy takes nothing returns nothing
            set this.next.prev = this.prev
            set this.prev.next = this.next
            set thistype.count = thistype.count - 1
            call this.deallocate()
        endmethod

        private static method conv takes integer i returns string
            local string s = I2S(i)
            if i < 10 then
                set s = "0" + s
            endif
            return s
        endmethod

        static method create takes string s returns thistype
            local thistype this = thistype.allocate()
            local real time = TimerGetElapsed(thistype.t)
            local integer min = R2I(time/60)
            local integer sec = R2I(time)
            set min = min - (min/60)*60
            set sec = sec - (sec/60)*60
            set thistype.lineCount = thistype.lineCount + 1
            set this.value = "|cff777777[" + thistype.conv(min) + ":" + thistype.conv(sec) + "]#" + I2S(thistype.lineCount) + "|r: " + s
            set this.next = 0
            set this.prev = thistype(0).prev
            set this.next.prev = this
            set this.prev.next = this
            if thistype.count == BUFFER then
                call thistype(0).next.destroy()
            else
                set thistype.count = thistype.count + 1
            endif
            if thistype.privShow and thistype.cursor <= 16 then
                call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, DURATION, this.value)
            endif
            if thistype.cursor > 16 then
                set thistype.cursor = thistype.cursor + 1
            endif
            return this
        endmethod

        static method operator show takes nothing returns boolean
            return thistype.privShow
        endmethod

        static method operator show= takes boolean b returns nothing
            set thistype.privShow = b
            if b then
                call thistype.refresh()
            else
                call ClearTextMessages()
            endif
        endmethod

    endstruct

    struct SystemTest extends array
        implement Alloc

        private boolean checker
        private timer t
        private SystemMsg msg

        private thistype next

        static if LIBRARY_Table then
            private static Table tb
        else
            private static hashtable hash = InitHashtable()
        endif

        method destroy takes nothing returns nothing
            if this.msg > 0 then
                if this.checker then
                    set this.msg.value = this.msg.value + " [ |cff00ff00OK|r ]"
                else
                    set this.msg.value = this.msg.value + " [ |cffff0000Failed|r ]"
                endif
            endif
            call SystemMsg.refresh()
            call ReleaseTimer(this.t)
            set this.t = null
            call this.deallocate()
        endmethod

        private static method expires takes nothing returns nothing
            call thistype(ReleaseTimer(GetExpiredTimer())).destroy()
        endmethod

        static method create takes nothing returns thistype
            local thistype this = thistype.allocate()
            set this.checker = false
            set this.t = NewTimerEx(this)
            call TimerStart(this.t, DELAY, false, function thistype.expires)
            //Push
            set this.next = thistype(0).next
            set thistype(0).next = this
            return this
        endmethod

        static method start takes string s returns nothing
            local thistype this = thistype.create()
            set this.msg = SystemMsg.create(s)
        endmethod

        static method end takes nothing returns nothing
            local thistype this = thistype(0).next
            debug if this == 0 then
            debug call SystemMsg.create("Missing SystemTest.start(<message>)")
            debug return
            debug endif
            set thistype(0).next = this.next
            set this.checker = true
            call this.destroy()
        endmethod

        private static method onInit takes nothing returns nothing
            call TimerStart(SystemMsg.t, 9999, false, null)
            set thistype.tb = Table.create()
        endmethod


    endstruct

endlibrary