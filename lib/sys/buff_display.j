library BuffDisplay uses TimerUtilsEx

/*
    BuffDisplay.create(unit)
        - Create a BuffDisplay at units.

    this.value = <BuffDisplay value>
        - Change the displayed value of a BuffDisplay.

    this.destroy()
        - Destroy the BuffDisplay instance.
*/

    globals
        private constant real TIMEOUT = 0.03125
    endglobals

    struct BuffDisplay extends array
        implement Alloc
        implement List

        public string value

        private textsplat ts
        private integer count
        private unit u
        private thistype head
        private thistype nextN
        private thistype prevN

        private static Table tb

        method enqueue takes thistype head returns nothing
            set this.nextN = head
            set this.prevN = head.prevN
            set this.nextN.prevN = this
            set this.prevN.nextN = this
        endmethod

        method dequeue takes nothing returns nothing
            set this.prevN.nextN = this.nextN
            set this.nextN.prevN = this.prevN
        endmethod

        method destroy takes nothing returns nothing
            local thistype head = this.head
            set head.count = head.count - 1
            if head.count == 0 then
                call thistype.tb.remove(GetHandleId(head.u))
                call head.pop()
                call head.ts.destroy()
                set head.u = null
                call head.deallocate()
            endif
            call this.dequeue()
            call this.deallocate()
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype head = thistype(0).next
            local thistype this
            loop
                exitwhen head == 0
                set head.value = ""
                set this = head.nextN
                call head.ts.setPosition(GetUnitX(head.u) - 30.0*(head.count - 1) - 10.0, GetUnitY(head.u), GetUnitFlyHeight(head.u) + 180)
                loop
                    exitwhen this == head
                    set head.value = head.value + this.value + " "
                    set this = this.nextN
                endloop
                call head.ts.setText(head.value, 7.0, TEXTSPLAT_TEXT_ALIGN_CENTER)
                set head = head.next
            endloop
        endmethod

        static method create takes unit u returns thistype
            local thistype this = thistype.allocate()
            local integer id = GetHandleId(u)
            local thistype head
            if thistype.tb.has(id) then
                set head = thistype.tb[id]
                set head.count = head.count + 1
            else
                set head = thistype.allocate()
                set head.nextN = head
                set head.prevN = head
                set head.u = u
                set head.ts = textsplat.create(TREBUCHET_MS)
                call head.ts.setVisible(GetLocalPlayer() == GetOwningPlayer(u))
                set head.count = 1
                set thistype.tb[id] = head
                call head.push(TIMEOUT)
            endif
            set this.head = head
            call this.enqueue(head)
            return this
        endmethod

        private static method onInit takes nothing returns nothing
            set thistype.tb = Table.create()
        endmethod

    endstruct

endlibrary