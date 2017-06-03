library SpellBlock uses Table, TimerUtilsEx

/*
    SpellBlock.create(unit, percentToProc, duration, destroyOnProc)
        - Create a SpellBlock to a unit.
            - unit: The unit that will have the SpellBlock.
            - percentToProc: Chance to Block a Spell [Acceptable Values: 0.0 (0%) to 1.0 (100%)]
            - duration: How long will this instance of SpellBlock last.

    this.registerProc(code)
        - Register a callback to be called when the SpellBlock procs.

    SpellBlock.has(unit)
        - returns true if unit will successfully block a blockable spell due to chance.
        - returns false if unit has no SpellBlock or if it fails to proc due to chance.
*/

    struct SpellBlock extends array
        implement Alloc

        private integer id
        private thistype head
        readonly real percent
        readonly unit u
        private trigger trg

        private thistype next
        private thistype prev

        private static Table tb
        private static thistype proc = 0

        method destroy takes nothing returns nothing
            if this.trg != null then
                call DestroyTrigger(this.trg)
                set this.trg = null
            endif
            set this.next.prev = this.prev
            set this.prev.next = this.next
            if this.head.next == this.head then
                call thistype.tb.remove(this.id)
                call this.head.deallocate()
            endif
            set this.u = null
            call this.deallocate()
        endmethod

        private static method expire takes nothing returns nothing
            call thistype(ReleaseTimer(GetExpiredTimer())).destroy()
        endmethod

        static method get takes nothing returns thistype
            return thistype.proc
        endmethod

        static method has takes unit u returns boolean
            local integer id = GetHandleId(u)
            local thistype this
            local thistype head
            if thistype.tb.has(id) then
                set head = thistype(thistype.tb[id])
                set this = head.next
                loop
                    exitwhen this == head
                    if GetRandomReal(0, 1) <= this.percent then
                        if this.trg != null then
                            set thistype.proc = this
                            call TriggerEvaluate(this.trg)
                            set thistype.proc = 0
                        endif
                        return true
                    endif
                    set this = this.next
                endloop
            endif
            return false
        endmethod

        method registerProc takes code c returns nothing
            if this.trg == null then
                set this.trg = CreateTrigger()
            endif
            call TriggerAddCondition(this.trg, Filter(c))
        endmethod

        static method create takes unit u, real percent, real duration returns thistype
            local thistype this = thistype.allocate()
            set this.u = u
            set this.id = GetHandleId(u)
            set this.percent = percent
            if thistype.tb.has(this.id) then
                set this.head = thistype.tb[this.id]
            else
                set this.head = thistype.allocate()
                set thistype.tb[this.id] = this.head
                set this.head.next = head
                set this.head.prev = head
            endif
            set this.next = this.head
            set this.prev = this.head.prev
            set this.next.prev = this
            set this.prev.next = this
            if duration > 0 then
                call TimerStart(NewTimerEx(this), duration, false, function thistype.expire)
            endif
            return this
        endmethod

        private static method onInit takes nothing returns nothing
            set thistype.tb = Table.create()
        endmethod

    endstruct

endlibrary