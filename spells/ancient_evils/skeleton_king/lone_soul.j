scope LoneSoul
    
    globals
        private constant integer SPELL_ID = 'A733'
        private constant string SOUL_MODEL = "Models\\Units\\LoneSoul.mdx"
        private constant string SFX = "Models\\Effects\\ViciousExplorersEffect.mdx"
        private constant real SOUL_FLY_HEIGHT = 300
        private constant real MOVE_SPEED = 300.0
        private constant real TIMEOUT = 2.0
    endglobals
    
    private function NumberOfSouls takes integer level returns integer
        return 1
    endfunction
    
    private function Speed takes integer level returns real
        return 300.0
    endfunction
    
    private function Radius takes integer level returns real
        if level == 11 then
            return 1800.0
        endif
        return 100.0*level
    endfunction
    
    struct LoneSoul extends array

        private static group g
        private static timer t
        
        private static method picked takes nothing returns nothing
            local unit u = GetEnumUnit()
            if GetUnitCurrentOrder(u) == 0 then
                call IssuePointOrderById(u, ORDER_move, GetRandomReal(WorldBounds.playMinX, WorldBounds.playMaxX), GetRandomReal(WorldBounds.playMinY, WorldBounds.playMaxY))
            endif
            set u = null
        endmethod

        private static method onPeriod takes nothing returns nothing
            call ForGroup(thistype.g, function thistype.picked)
        endmethod

        private static method onCast takes nothing returns nothing
            local player p = GetTriggerPlayer()
            local unit caster = GetTriggerUnit()
            local integer level = GetUnitAbilityLevel(caster, SPELL_ID)
            local integer i = NumberOfSouls(level)
            local real spd = Speed(level)
            local real radius = Radius(level)
            local real x = GetUnitX(caster)
            local real y = GetUnitY(caster)
            local unit soul
            local real x2
            local real y2
            call DestroyEffect(AddSpecialEffect(SFX, x, y))
            loop
                exitwhen i == 0
                set x2 = GetRandomReal(WorldBounds.playMinX, WorldBounds.playMaxX)
                set y2 = GetRandomReal(WorldBounds.playMinY, WorldBounds.playMaxY)
                set soul = CreateUnit(p, 'dumi', x, y, Atan2(y2 - y, x2 - x)*bj_RADTODEG)
                call SetUnitMoveSpeed(soul, MOVE_SPEED)
                call IssuePointOrderById(soul, ORDER_move, x2, y2)
                call GroupAddUnit(thistype.g, soul)
                call SetUnitFlyHeight(soul, SOUL_FLY_HEIGHT, 300)
                call AddSpecialEffectTarget(SOUL_MODEL, soul, "origin")
                call SetUnitScale(soul, 0.40 + 0.05*level, 0, 0)
                call TrueSight.create(soul, radius)
                call UnitSetBonus(soul, BONUS_SIGHT_RANGE, R2I(radius))
                if thistype.t == null then
                    set thistype.t = CreateTimer()
                    call TimerStart(thistype.t, TIMEOUT, true, function thistype.onPeriod)
                endif
                set i = i - 1
            endloop
            set p = null
            set soul = null
            set caster = null
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            set thistype.g = CreateGroup()
            set thistype.t = null
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope