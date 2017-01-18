scope Spiders
 
    globals
        private constant integer SPELL_ID = 'A431'
        private constant integer UNIT_ID = 'uSpi'
        private constant string SFX = "Doodads\\Dungeon\\Terrain\\EggSack\\EggSack0.mdl"
        private constant real TIMEOUT = 0.20
        private constant real DEFAULT_SIGHT = 1000 //Sight Radius of Hatchling in Object Editor
    endglobals
    
    private function NumberOfUnits takes integer level returns integer
        if level == 11 then
            return 1
        endif
        return level
    endfunction
    
    private function SightRadius takes integer level returns real
        if level == 11 then
            return GLOBAL_SIGHT
        endif
        return 0.0*level + 1000.0
    endfunction
    
    private function UnitHP takes integer level returns real
        return 0.0*level + 200.0 
    endfunction
    
    private function Duration takes integer level returns real
        return 0.0*level + 10.0
    endfunction
    
    private function Speed takes integer level returns real
        return 0.0*level + 522
    endfunction
    
    struct Spiders extends array
        implement Alloc
        
        private group g
        
        private static thistype global
        
        implement List
        
        private method destroy takes nothing returns nothing
            call this.pop()
            call ReleaseGroup(this.g)
            set this.g = null
            call this.deallocate()
        endmethod
        
        private static method picked takes nothing returns nothing
            local unit u = GetEnumUnit()
            if UnitAlive(u) then
                if GetUnitCurrentOrder(u) == 0 then
                    call ForcedOrder.change(u, ORDER_move, GetRandomReal(WorldBounds.playMinX, WorldBounds.playMaxX), GetRandomReal(WorldBounds.playMinY, WorldBounds.playMaxY))
                endif
            else
                call GroupRemoveUnit(global.g, u)
            endif
            set u = null
        endmethod
        
        private static method onPeriod takes nothing returns nothing
            local thistype this = thistype(0).next
            loop
                exitwhen this == 0
                set thistype.global = this
                call ForGroup(this.g, function thistype.picked)
                if FirstOfGroup(this.g) == null then
                    call this.destroy()
                endif
                set this = this.next
            endloop
        endmethod
        
        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            local unit caster = GetTriggerUnit()
            local player owner = GetTriggerPlayer()
            local real angle = GetUnitFacing(caster)*bj_DEGTORAD
            local real x = GetUnitX(caster) - 100*Cos(angle)
            local real y = GetUnitY(caster) - 100*Sin(angle)
            local integer lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            local integer i = NumberOfUnits(lvl)
            local real duration = Duration(lvl)
            local real radius = SightRadius(lvl)
            local real hp = UnitHP(lvl)
            local real spd = Speed(lvl)
            local unit u
            set this.g = NewGroup()
            loop
                exitwhen i == 0
                set u = CreateUnit(owner, UNIT_ID, x, y, 0)
                call ForcedOrder.create(u, ORDER_move,  GetRandomReal(WorldBounds.playMinX, WorldBounds.playMaxX), GetRandomReal(WorldBounds.playMinY, WorldBounds.playMaxY))
                call SetUnitMaxState(u, UNIT_STATE_MAX_LIFE, hp)
                call UnitApplyTimedLife(u, 'BTLF', duration)
                call SetUnitMoveSpeed(u, spd)
                call GroupAddUnit(this.g, u)
                call TrueSight.createEx(u, radius, duration)
                if lvl == 11 then
                    call FlySight.create(u, radius)
                else
                    call UnitSetBonus(u, BONUS_SIGHT_RANGE, R2I(radius - DEFAULT_SIGHT))
                endif
                set i = i - 1
            endloop
            call DestroyEffect(AddSpecialEffect(SFX, x, y))
            call this.push(TIMEOUT)
            set caster = null
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call PreloadUnit(UNIT_ID)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope