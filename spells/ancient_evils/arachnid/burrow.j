scope Burrow 
    globals
        private constant integer SPELL_ID = 'A4XX'
        private constant integer BURROWED_UNIT_ID = 'UBAr'
        private constant real DAMAGE = 9999999.9
        private constant real RADIUS = 150.0
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_CHAOS
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_NORMAL
    endglobals
    
    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction
    
    struct Burrow extends array
        
        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local player owner
            local group g
            local unit u
            if GetUnitTypeId(caster) == BURROWED_UNIT_ID then
                set g = NewGroup()
                set owner = GetTriggerPlayer()
                call GroupUnitsInArea(g, GetUnitX(caster), GetUnitY(caster), RADIUS)
                loop
                    set u = FirstOfGroup(g)
                    exitwhen u == null
                    call GroupRemoveUnit(g, u)
                    if TargetFilter(u, owner) then
                        call UnitDamageTarget(caster, u, DAMAGE, true, false, ATTACK_TYPE, DAMAGE_TYPE, null)
                    endif
                endloop
                call ReleaseGroup(g)
                set g = null
                set owner = null
            endif
            set caster = null
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope