library AbilityTimer uses Table, TimerUtilsEx

/*
    AbilityTimer.create(unit, ability, duration)
        - Makes a unit ethereal, preventing it from attacking and receiving physical damage
          but takes extra damage from magic attacks.
*/

    globals
        private constant integer SPELL_ID = 'Aetl'
    endglobals

    struct AbilityTimer extends array
        implement Alloc

        private unit u
        private integer a
        private static HashTable ht

        method destroy takes nothing returns nothing
            local integer id = GetHandleId(this.u)
            set thistype.ht[id][a] = thistype.ht[id][a] - 1
            set thistype.ht[id][0] = thistype.ht[id][0] - 1
            if thistype.ht[id][a] == 0 then
                call UnitRemoveAbility(this.u, this.a)
                if thistype.ht[id][0] == 0 then
                    call thistype.ht.remove(id)
                endif
            endif
            set this.u = null
            call this.deallocate()
        endmethod

        private static method expires takes nothing returns nothing
            call thistype(ReleaseTimer(GetExpiredTimer())).destroy()
        endmethod

        static method create takes unit u, integer a, real time returns thistype
            local thistype this = thistype.allocate()
            local integer id = GetHandleId(u)
            set this.u = u
            set this.a = a
            if thistype.ht[id][a] > 0 then
                set thistype.ht[id][a] = thistype.ht[id][a] + 1
            else
                set thistype.ht[id][a] = 1
                call UnitAddAbility(u, a)
                call UnitMakeAbilityPermanent(u, true, a)
            endif
            set thistype.ht[id][0] = thistype.ht[id][0] + 1
            call TimerStart(NewTimerEx(this), time, false, function thistype.expires)
            return this
        endmethod

        private static method onInit takes nothing returns nothing
            set thistype.ht = HashTable.create()
        endmethod

    endstruct


endlibrary