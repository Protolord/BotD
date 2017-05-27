library SpellResistance requires DamageEvent, DamageModify

/*
    SpellResistance.create(unit, amount)
        - Make a unit gain spell resistance by a certain amount.
        - Only use values (-inf, 1)

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
            set head.b = head.b/(1 - this.b)
            set head.count = head.count - 1
            if head.count == 0 then
                call thistype.tb.remove(GetHandleId(this.u))
                call head.deallocate()
            endif
            call this.deallocate()
        endmethod

        method change takes real newBonus returns nothing
            local thistype head = this.head
            set head.b = head.b*(1 - newBonus)/(1 - this.b)
            set this.b = newBonus
        endmethod

        private static method onDamage takes nothing returns nothing
            local integer id = GetHandleId(Damage.target)
            if thistype.tb.has(id) and (Damage.type == DAMAGE_TYPE_MAGICAL or (Damage.type == DAMAGE_TYPE_PHYSICAL and CombatStat.getAttackType(Damage.source) == ATTACK_TYPE_MAGIC)) then
                set Damage.amount = thistype(thistype.tb[id]).b*Damage.amount
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
                set head.b = 1
                set head.count = 1
                set thistype.tb[id] = head
            endif
            set this.u = u
            set this.b = bonus
            set this.head = head
            set head.b = head.b*(1 - this.b)
            return this
        endmethod

        private static method onInit takes nothing returns nothing
            set thistype.tb = Table.create()
            call Damage.registerModifier(function thistype.onDamage)
        endmethod

    endstruct
endlibrary