library SpellResistance requires DamageEvent, DamageModify

/*
    SpellResistance.create(unit, amount)
        - Make a unit gain spell resistance by a certain amount.

    this.duration = <time duration>
        - Add an expiration timer to a SpellResistance instance.

    this.destroy()
        - Destroy the SpellResistance instance.
*/

    struct SpellResistance extends array
        implement Alloc

        readonly real b
        readonly unit u

        private thistype head
        private integer count

        private static Table tb

        method destroy takes nothing returns nothing
            local thistype head = this.head
            set head.b = RMinBJ(head.b - this.b, 1.0)
            set head.count = head.count - 1
            if head.count == 0 then
                call thistype.tb.remove(GetHandleId(this.u))
                call head.deallocate()
            endif
            call this.deallocate()
        endmethod

        method change takes real newBonus returns nothing
            local thistype head = this.head
            set head.b = RMinBJ(head.b + newBonus - this.b, 1.0)
            set this.b = newBonus
        endmethod

        private static method onDamage takes nothing returns nothing
            local integer id = GetHandleId(Damage.target)
            if Damage.type == DAMAGE_TYPE_MAGICAL and Damage.coded and thistype.tb.has(id) then
                set Damage.amount = (1.0 - thistype(thistype.tb[id]).head.b)*Damage.amount
            endif
        endmethod

        static method create takes unit u, real bonus returns thistype
            local thistype this = thistype.allocate()
            local integer id = GetHandleId(u)
            local thistype head
            if thistype.tb.has(id) then
                set head = thistype.tb[id]
                set head.count = head.count + 1
            else
                set head = thistype.allocate()
                set head.b = 0
                set head.count = 1
                set thistype.tb[id] = head
            endif
            set this.u = u
            set this.b = bonus
            set this.head = head
            set head.b = RMinBJ(head.b + this.b, 1.0)
            return this
        endmethod

        private static method onInit takes nothing returns nothing
            set thistype.tb = Table.create()
            call Damage.registerModifier(function thistype.onDamage)
        endmethod

    endstruct
endlibrary