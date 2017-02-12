scope ShatteredEarth
 
    globals
        private constant integer SPELL_ID = 'A533'
        private constant string SFX = "Models\\Effects\\ShatteredEarthAsh.mdx"
        private constant string SFX_CAST = "Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl"
    endglobals
    
    private function Sight takes integer level returns real
        if level == 11 then
            return GLOBAL_SIGHT
        endif
        return 0.0*level + 1500.0
    endfunction
    
    private function NumberOfExplosions takes integer level returns integer
        if level == 11 then
            return 1
        endif
        return level
    endfunction
    
    private function Duration takes integer level returns real
        return 15.0 + 0.0*level
    endfunction

    private struct Node extends array
        implement Alloc

        private destructable d
        private effect sfx
        private TrueSight ts
        private FlySight fs

        private static Table tb

        method destroy takes nothing returns nothing
            call KillDestructable(this.d)
            call DestroyEffect(this.sfx)
            call this.ts.destroy()
            call this.fs.destroy()
            set this.sfx = null
            set this.d = null
        endmethod

        static method remove takes unit u returns nothing
            local thistype this = thistype.tb[GetHandleId(u)]
            if this > 0 then
                call thistype.tb.remove(GetHandleId(u))
                call this.destroy()
            endif
        endmethod

        static method add takes unit u, real sight returns nothing
            local thistype this = thistype.allocate()
            set this.d = CreateDestructable('Volc', GetUnitX(u), GetUnitY(u), GetRandomReal(0, 360), 0.3, 0)
            set this.sfx = AddSpecialEffectTarget(SFX, u, "origin")
            set this.ts = TrueSight.create(u, sight)
            set this.fs = FlySight.create(u, sight)
            call SetDestructableAnimation(this.d, "birth")
            set thistype.tb[GetHandleId(u)] = this
        endmethod

        static method init takes nothing returns nothing
            set thistype.tb = Table.create()
        endmethod

    endstruct
    
    struct ShatteredEarth extends array
        implement Alloc

        private group g 

        private static method expires takes nothing returns nothing
            local thistype this = ReleaseTimer(GetExpiredTimer())
            local unit u
            loop
                set u = FirstOfGroup(this.g)
                exitwhen u == null 
                call GroupRemoveUnit(this.g, u)
                call Node.remove(u)
                call DummyAddRecycleTimer(u, 4.0)
            endloop
            call ReleaseGroup(this.g)
            set this.g = null
            call this.deallocate()
        endmethod
        
        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            local unit caster = GetTriggerUnit()
            local integer lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            local real sight = Sight(lvl)
            local real i = NumberOfExplosions(lvl)
            local player p = GetTriggerPlayer()
            local real duration = Duration(lvl)
            local real x
            local real y
            local unit u
            set this.g = NewGroup()
            loop
                exitwhen i == 0
                set x = GetRandomReal(WorldBounds.playMinX, WorldBounds.playMaxX)
                set y = GetRandomReal(WorldBounds.playMinY, WorldBounds.playMaxY)
                set u = GetRecycledDummyAnyAngle(x, y, 0)
                call GroupAddUnit(this.g, u)
                call SetUnitOwner(u, p, false)
                call Node.add(u, sight)
                call PingMinimapEx(x, y, duration, 255, 50, 40, false)
                call SetUnitScale(u, 0.35, 0, 0)
                set i = i - 1
            endloop
            call DestroyEffect(AddSpecialEffect(SFX_CAST, GetUnitX(caster), GetUnitY(caster)))
            call TimerStart(NewTimerEx(this), duration, false, function thistype.expires)
            set u = null
            set caster = null
            set p = null
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call Node.init()
            call RegisterSpellFinishEvent(SPELL_ID, function thistype.onCast)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope