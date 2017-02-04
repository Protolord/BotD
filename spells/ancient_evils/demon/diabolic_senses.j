scope DiabolicSenses

    globals
        private constant integer SPELL_ID = 'A531'
        private constant integer UNIT_ID = 'uDia'
        private constant integer INIT_DAMAGE = 1
        private constant integer INIT_SIGHT = 600
    endglobals
    
    private function AttackDamage takes integer level returns real
        return 50.0 + 0.0*level
    endfunction
    
    private function SightRadius takes integer level returns real
        return 0.0*level + 1000.0
    endfunction
    
    private function Duration takes integer level returns real
        return 15.0 + 0.0*level
    endfunction
    
    struct DiabolicSenses extends array
        implement Alloc
        
        private unit caster
        private integer lvl
        
        private static group g
        private static Table tb
        
        private method destroy takes nothing returns nothing
            call thistype.tb.remove(GetHandleId(this.caster))
            set this.caster = null
            call this.deallocate()
        endmethod
        
        private static method onSummon takes nothing returns boolean
            local thistype this
            local unit u
            if GetUnitTypeId(GetTriggerUnit()) == UNIT_ID then
                set this = thistype(thistype.tb[GetHandleId(thistype.tb.unit[GetHandleId(GetTriggeringTrigger())])])
                set u = GetTriggerUnit()
                call UnitSetBonus(u, BONUS_DAMAGE, R2I(AttackDamage(lvl)) - INIT_DAMAGE)
                if this.lvl == 11 then
                    call FlySight.create(u, GLOBAL_SIGHT)
                else
                    call UnitSetBonus(u, BONUS_SIGHT_RANGE, R2I(SightRadius(lvl)) - INIT_SIGHT)
                endif
                set u = null
            endif
            return false
        endmethod
        
        private static method expires takes nothing returns nothing
            call thistype(ReleaseTimer(GetExpiredTimer())).destroy()
        endmethod
        
        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            set this.caster = GetTriggerUnit()
            set this.lvl = GetUnitAbilityLevel(this.caster, SPELL_ID)
            set thistype.tb[GetHandleId(this.caster)] = this
            call TimerStart(NewTimerEx(this), Duration(this.lvl), false, function thistype.expires)
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method register takes unit u returns nothing
            local trigger t = CreateTrigger()
            local region r = CreateRegion()
            call RegionAddRect(r, WorldBounds.world)
            call TriggerRegisterEnterRegion(t, r, null)
            call TriggerAddCondition(t, function thistype.onSummon)
            set thistype.tb.unit[GetHandleId(t)] = u
        endmethod
        
        static method init takes nothing returns nothing
            local trigger t
            local region r
            call SystemTest.start("Initializing thistype: ")
            set thistype.g = CreateGroup()
            set thistype.tb = Table.create()
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call thistype.register(PlayerStat.initializer.unit)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope