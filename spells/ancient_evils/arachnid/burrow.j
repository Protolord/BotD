scope Burrow 
    globals
        private constant integer SPELL_ID = 'A4XX'
        private constant integer BURROWED_UNIT_ID = 'UBAr'
        private constant real RADIUS = 150.0
        private constant real SPACING = 100.0
        private constant real DELAY = 1.0
        private constant string SFX = "Objects\\Spawnmodels\\Undead\\ImpaleTargetDust\\ImpaleTargetDust.mdl"
        private constant string SFX_SPIKE = "Abilities\\Spells\\Undead\\Impale\\ImpaleMissTarget.mdl"
    endglobals
    
    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction
    
    struct Burrow extends array
        implement Alloc

        private unit caster
        private real x 
        private real y

        private method destroy takes nothing returns nothing
            set this.caster = null
            call this.deallocate()
        endmethod

        private static method onUnburrow takes nothing returns nothing
            local thistype this = ReleaseTimer(GetExpiredTimer())
            local group g = NewGroup()
            local player owner = GetOwningPlayer(this.caster)
            local unit u
            local real da
            local real angle
            local real endAngle
            call GroupUnitsInArea(g, this.x, this.y, RADIUS)
            loop
                set u = FirstOfGroup(g)
                exitwhen u == null
                call GroupRemoveUnit(g, u)
                if TargetFilter(u, owner) then
                    call Damage.kill(this.caster, u)
                endif
            endloop
            //Create SFX
            set da = 2*bj_PI/R2I(2*bj_PI*RADIUS/SPACING)
            if da > bj_PI/3 then
                set da = bj_PI/3
            endif
            set angle = da
            set endAngle = da + 2*bj_PI - 0.0001
            loop
                exitwhen angle >= endAngle
                call DestroyEffect(AddSpecialEffect(SFX_SPIKE, this.x + RADIUS*Cos(angle), this.y + RADIUS*Sin(angle)))
                set angle = angle + da
            endloop
            call this.destroy()
            call ReleaseGroup(g)
            set g = null
            set owner = null
        endmethod
        
        private static method onCast takes nothing returns nothing
            local unit u = GetTriggerUnit()
            local real x = GetUnitX(u)
            local real y = GetUnitY(u)
            local thistype this
            if GetUnitTypeId(u) == BURROWED_UNIT_ID then
                set this = thistype.allocate()
                set this.caster = u
                set this.x = x
                set this.y = y
                call TimerStart(NewTimerEx(this), DELAY, false, function thistype.onUnburrow)
            endif
            call DestroyEffect(AddSpecialEffect(SFX, x, y))
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