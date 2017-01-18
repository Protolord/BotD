library SpellBlock uses Table, TimerUtilsEx
    
/*
    SpellBlock.create(unit, percentToProc, duration, destroyOnProc)
        - Create a SpellBlock to a unit.
            - unit: The unit that will have the SpellBlock.
            - percentToProc: Chance to Block a Spell [Acceptable Values: 0.0 (0%) to 1.0 (100%)]
            - duration: How long will this instance of SpellBlock last.
            - destroyOnProc: Will the Spell Block be removed upon blocking a Spell or will it remain until it expires?
            
    SpellBlock.has(unit) 
        - returns true if unit will successfully block a blockable spell due to chance.
        - returns false if unit has no SpellBlock or if it fails to proc due to chance.   
*/

    struct SpellBlock extends array
        implement Alloc
        
        private integer id
        private thistype head
        readonly boolean procDestroy
        readonly real percent
        readonly unit u
        
        //Optional Buffs
        readonly integer abilityId
        readonly integer buffId
        
        private thistype next
        private thistype prev
        
        private static Table tb
        
        method destroy takes nothing returns nothing
            set this.next.prev = this.prev
            set this.prev.next = this.next
            if this.head.next == this.head then
                call thistype.tb.remove(this.id)
                call this.head.deallocate()
            endif
            if this.buffId != 0 then
                call UnitRemoveAbility(this.u, this.abilityId)
                call UnitRemoveAbility(this.u, this.buffId)
            endif
            set this.u = null
            call this.deallocate()
        endmethod
        
        private static method expire takes nothing returns nothing
            call thistype(ReleaseTimer(GetExpiredTimer())).destroy()
        endmethod
        
        static method has takes unit u returns boolean
            local integer id = GetHandleId(u)
            local thistype this
            local thistype head
            if thistype.tb.has(id) then
                set head = thistype(thistype.tb[id])
                set this = head.next
                loop
                    exitwhen this == 0
                    if GetRandomReal(0, 1) <= this.percent then
                        if this.procDestroy then
                            call this.destroy()
                        endif
                        return true
                    endif
                    set this = this.next
                endloop
            endif
            return false
        endmethod
        
        method operator buff= takes integer id returns nothing
            set this.abilityId = id
            set this.buffId = id - (id/0x01000000)*0x01000000 + 0x42000000
            call UnitAddAbility(this.u, id)
        endmethod
        
        static method create takes unit u, real percent, real duration, boolean destroyOnProc returns thistype
            local thistype this = thistype.allocate()
            set this.u = u
            set this.id = GetHandleId(u)
            set this.buffId = 0
            set this.procDestroy = destroyOnProc
            if thistype.tb.has(this.id) then
                set this.head = thistype.tb[this.id]
            else
                set this.head = thistype.allocate()
                set thistype.tb[this.id] = this.head
                set this.head.next = 0
                set this.head.prev = 0
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