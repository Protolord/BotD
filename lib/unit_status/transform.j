library Transform requires Root, Movespeed, Alloc

    struct Transform extends array
        implement Alloc

        private integer removeId
        private unit u

        method destroy takes nothing returns nothing
            call UnitAddAbility(this.u, this.removeId)
            call UnitRemoveAbility(this.u, this.removeId)
            set this.u = null
            call this.deallocate()
        endmethod

        static method create takes unit u, integer spellId returns thistype
            local thistype this = thistype.allocate()
            set this.u = u
            set this.removeId = spellId - 0x01000000
            call UnitAddAbility(u, spellId)
            call UnitRemoveAbility(u, spellId)
            call Movespeed.check(u)
            call Root.check(u)
            return this
        endmethod

    endstruct

endlibrary