library Armor uses Table, BonusMod, TimerUtilsEx

/*
    Armor.create(unit, bonus)
        - Add Armor instance to a unit.
            
    this.change(newBonus)
         - Change the armor modification of a certain instance.
        
    this.destroy()
         - Destroy the Armor instance.

*/    

    globals
        private constant integer LIMIT = 511
    endglobals

    private function Range takes real r returns integer
        if r < -LIMIT then
            return -LIMIT
        elseif r > LIMIT then
            return LIMIT
        endif
        return R2I(r)
    endfunction

    struct Armor extends array
        implement Alloc
        
        readonly real b
        readonly unit u
        
        private thistype head
        private integer count
        
        private static Table tb
        
        method destroy takes nothing returns nothing
            local thistype head = this.head
            set head.b = head.b - this.b
            set head.count = head.count - 1
            if head.count == 0 then
                call thistype.tb.remove(GetHandleId(this.u))
                call head.deallocate()
            endif
            call UnitSetBonus(u, BONUS_ARMOR, Range(head.b*100))
            call this.deallocate()
        endmethod
        
        method change takes real newBonus returns nothing
            local thistype head = this.head
            set head.b = head.b + newBonus - this.b
            set this.b = newBonus
            call UnitSetBonus(u, BONUS_ARMOR, Range(head.b*100))
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
            set head.b = head.b + this.b
            call UnitSetBonus(u, BONUS_ARMOR, Range(head.b*100))
            return this
        endmethod
        
        private static method onInit takes nothing returns nothing
            set thistype.tb = Table.create()
        endmethod
        
    endstruct
    
endlibrary
