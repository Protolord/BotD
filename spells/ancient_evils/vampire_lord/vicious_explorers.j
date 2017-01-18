scope ViciousExplorers
    
    globals
        private constant integer SPELL_ID = 'A132'
        private constant string BAT_MODEL = "Units\\Undead\\Gargoyle\\Gargoyle.mdx"
        private constant string SFX = "Models\\Effects\\ViciousExplorersEffect.mdx"
        private constant real BAT_FLY_HEIGHT = 150
    endglobals
    
    private function NumberOfBats takes integer level returns integer
        if level == 11 then
            return 1
        endif
        return level
    endfunction
    
    private function Speed takes integer level returns real
        return 300.0
    endfunction
    
    private function Radius takes integer level returns real
        if level == 11 then
            return GLOBAL_SIGHT
        endif
        return 100.0*level
    endfunction
    
    private function Duration takes integer level returns real
        return 30.0 + 0.0*level
    endfunction
    
    struct ViciousExplorers extends array
        
        private Missile bat
        
        private method destroy takes nothing returns nothing
            call this.bat.destroy()
        endmethod
        
        private static method expires takes nothing returns nothing
            call thistype(ReleaseTimer(GetExpiredTimer())).destroy()
        endmethod

        private static method create takes player p, real x, real y, real x2, real y2, real spd returns thistype
            local thistype this = thistype(Missile.create())
            set this.bat = this
            call this.bat.sourceXYZ(x, y, GetPointZ(x, y) + BAT_FLY_HEIGHT)
            call this.bat.targetXYZ(x2, y2, GetPointZ(x2, y2) + BAT_FLY_HEIGHT)
            if IsPlayerAlly(GetLocalPlayer(), p) then
                set this.bat.model = BAT_MODEL
            endif
            set this.bat.speed = spd
            call this.bat.launch()
            return this
        endmethod
        
        private static method onCast takes nothing returns nothing
            local thistype this
            local player p = GetTriggerPlayer()
            local unit u = GetTriggerUnit()
            local integer level = GetUnitAbilityLevel(u, SPELL_ID)
            local integer i = NumberOfBats(level)
            local real duration = Duration(level)
            local real spd = Speed(level)
            local real radius = Radius(level)
            local real x = GetUnitX(u)
            local real y = GetUnitY(u)
            local real x2
            local real y2
            call DestroyEffect(AddSpecialEffect(SFX, x, y))
            loop
                exitwhen i == 0
                if radius == GLOBAL_SIGHT then
                    set x2 = x
                    set y2 = y
                else
                    set x2 = GetRandomReal(WorldBounds.playMinX, WorldBounds.playMaxX)
                    set y2 = GetRandomReal(WorldBounds.playMinY, WorldBounds.playMaxY)
                endif
                set this = thistype.create(p, x, y, x2, y2, spd)
                call SetUnitOwner(this.bat.u, p, false)
                if level < 11 then
                    call SetUnitVertexColor(this.bat.u, 30, 30, 30, 255)
                else
                    call SetUnitVertexColor(this.bat.u, 200, 30, 30, 255)
                endif
                call SetUnitScale(this.bat.u, 0.30 + 0.02*level, 0, 0)
                call TrueSight.createEx(this.bat.u, radius, duration)
                call FlySight.createEx(this.bat.u, radius, duration)
                call TimerStart(NewTimerEx(this), duration, false, function thistype.expires)
                set i = i - 1
            endloop
            set p = null
            set u = null
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope