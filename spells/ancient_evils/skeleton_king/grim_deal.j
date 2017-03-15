scope GrimDeal
    
    globals
        private constant integer SPELL_ID = 'A743'
    endglobals
    
    private function Chance takes integer level returns real
        if level == 11 then
            return 50.0
        endif
        return 11.0 + 2.0*level
    endfunction
    
    private function TargetFilter takes unit u, player p returns boolean
        return IsUnitEnemy(u, p)
    endfunction
    
    struct GrimDeal extends array

        private static method onDeath takes nothing returns boolean
            local unit killer = GetKillingUnit()
            local unit dying = GetTriggerUnit()
            local integer level = GetUnitAbilityLevel(killer, SPELL_ID)
            if level > 0 and TargetFilter(dying, GetOwningPlayer(killer)) then
                if GetRandomReal(0, 100) <= Chance(level) then
                    call Heal.unit(killer, 0xFFFFFF, 1.0)
                endif
            endif
            set killer = null
            set dying = null
            return false
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope