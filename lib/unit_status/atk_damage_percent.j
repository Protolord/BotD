library AtkDamagePercent uses Table, BonusMod, AtkDamage, CombatStat

/*
    AtkDamagePercent.create(unit, bonus)
        - Add AtkDamagePercent instance to a unit.
            
    this.change(newBonus)
         - Change the AtkDamagePercent bonus of a certain instance.
        
    this.destroy()
         - Destroy the AtkDamagePercent instance.

*/    

    globals
        private constant real TIMEOUT = 0.1
    endglobals

    struct AtkDamagePercent extends array
        implement Alloc
        implement List
        
        readonly real b
        readonly unit u
        
        private AtkDamage ad
        private timer t
        private thistype head
        private integer count
        
        private static Table tb
        
        method destroy takes nothing returns nothing
            local thistype head = this.head
            set head.b = head.b - this.b
            set head.count = head.count - 1
            if head.count == 0 then
                call thistype.tb.remove(GetHandleId(this.u))
                call head.pop()
                call head.deallocate()
            endif
            call head.ad.change(head.b*CombatStat.getDamage(head.u))
            call this.deallocate()
        endmethod
        
        method change takes real newBonus returns nothing
            local thistype head = this.head
            set head.b = head.b + newBonus - this.b
            set this.b = newBonus
            call head.ad.change(head.b*CombatStat.getDamage(head.u))
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype head = thistype(0).next
            loop
                exitwhen head == 0
                call head.ad.change(head.b*CombatStat.getDamage(head.u))
                set head = head.next
            endloop
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
                set head.u = u
                set head.ad = AtkDamage.create(u, 0)
                call head.push(TIMEOUT)
                set thistype.tb[id] = head
            endif
            set this.u = u
            set this.b = bonus
            set this.head = head
            set head.b = head.b + this.b
            call head.ad.change(head.b*CombatStat.getDamage(head.u))
            return this
        endmethod
        
        private static method onInit takes nothing returns nothing
            set thistype.tb = Table.create()
        endmethod
        
    endstruct
    
endlibrary
