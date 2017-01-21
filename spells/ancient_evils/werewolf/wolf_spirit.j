scope WolfSpirit
    
    globals
        private constant integer SPELL_ID = 'A231'
        private constant integer UNIT_ID = 'uWoS'
        private constant real OFFSET = 120.0
        private constant real ORDER_TIMEOUT = 0.25
        private constant string SUMMON_SFX = ""
    endglobals
    
    private function Duration takes integer level returns real
        return 20.0
    endfunction
    
    private function MoveSpeed takes integer level returns real
        return 200.0 + 35.0*level
    endfunction
    
    private function Radius takes integer level returns real
        return 0.0*level + 1000.0
    endfunction
    
    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitType(u, UNIT_TYPE_PEON) and IsUnitEnemy(u, p)
    endfunction
    
    struct WolfSpirit extends array
        implement Alloc
        
        private unit wolf
        private unit target
        private fogmodifier fm
        private TrueSight ts
        private static real DEFAULT_DIST
        
        private static method reorder takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            if not UnitAlive(this.wolf) or IssueTargetOrderById(wolf, ORDER_smart, this.target) then
                set this.wolf = null
                set this.target = null
                call ReleaseTimer(GetExpiredTimer())
                call this.deallocate()
            endif
        endmethod
        
        private static method expires takes nothing returns nothing
            local thistype this = ReleaseTimer(GetExpiredTimer())
            call DestroyFogModifier(this.fm)
            set this.fm = null
            call this.deallocate()
        endmethod
        
        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            local unit caster = GetTriggerUnit()
            local integer level = GetUnitAbilityLevel(caster, SPELL_ID)
            local player p = GetTriggerPlayer()
            local real angle = GetUnitFacing(caster)
            local real x = GetUnitX(caster) + OFFSET*Cos(angle*bj_DEGTORAD)
            local real y = GetUnitY(caster) + OFFSET*Sin(angle*bj_DEGTORAD)
            local group g = CreateGroup()
            local real dist = thistype.DEFAULT_DIST
            local unit target = null
            local real temp
            local unit u
            local real dx
            local real dy
            local TrueSight ts

            set this.wolf = CreateUnit(p, UNIT_ID, x, y, angle)
            call SetUnitVertexColor(this.wolf, 255, 255, 255, 150)
            call DestroyEffect(AddSpecialEffect(SUMMON_SFX, x, y))
            call UnitApplyTimedLife(this.wolf, 'BTLF', Duration(level))
            call UnitAddAbility(this.wolf, 'Atwa')
            
            if level < 11 then
                call GroupEnumUnitsInRect(g, bj_mapInitialPlayableArea, null)
                loop
                    set u = FirstOfGroup(g)
                    exitwhen u == null
                    call GroupRemoveUnit(g, u)
                    if TargetFilter(u, p) then
                        set dx = GetUnitX(u) - x
                        set dy = GetUnitY(u) - x
                        set temp = dx*dx + dy*dy
                        if temp < dist then
                            set dist = temp
                            set target = u
                        endif
                    endif
                endloop
                call DestroyGroup(g)
                
                call SetUnitMoveSpeed(this.wolf, MoveSpeed(level))
                
                
                if target != null then
                    if not IssueTargetOrderById(this.wolf, ORDER_smart, target) then
                        call IssuePointOrderById(this.wolf, ORDER_move, GetUnitX(target), GetUnitY(target))
                        set this.target = target
                        call TimerStart(NewTimerEx(this), ORDER_TIMEOUT, true, function thistype.reorder)
                    endif
                else
                    set this.wolf = null    
                    call this.deallocate()
                endif
            else
                set this.fm = CreateFogModifierRect(p, FOG_OF_WAR_VISIBLE, WorldBounds.world, true, false)
                call FogModifierStart(this.fm)
                call TimerStart(NewTimerEx(this), Duration(level), false, function thistype.expires)
            endif
            call TrueSight.createEx(this.wolf, Radius(level), Duration(level))
            
            set target = null
            set caster = null
            set p = null
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call RemoveUnit(CreateUnit(Player(14), 'uWoS', 0, 0, 0))
            set thistype.DEFAULT_DIST = 4*GetRectMaxX(bj_mapInitialPlayableArea)*GetRectMaxX(bj_mapInitialPlayableArea)
            call PreloadUnit(UNIT_ID)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope