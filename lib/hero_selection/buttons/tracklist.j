library TrackList requires Track

    struct TrackList extends array
        implement Alloc

        readonly player p
        readonly Track t
        readonly thistype next
        readonly thistype prev

        method destroy takes nothing returns nothing
            set t.enabled = false
            set this.prev.next = .next
            set this.next.prev = .prev
            call this.deallocate()
        endmethod

        static method create takes thistype head, Track trk, player p returns thistype
            local thistype this = thistype.allocate()
            set this.t = trk
            set this.p = p
            set this.next = head.next
            set this.prev = head
            set this.next.prev = this
            set this.prev.next = this
            return this
        endmethod

        static method head takes nothing returns thistype
            local thistype this = thistype.allocate()
            set this.next = 0
            set this.prev = 0
            return this
        endmethod

    endstruct

endlibrary