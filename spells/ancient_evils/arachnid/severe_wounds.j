scope SevereWound
 
    globals
        private constant integer SPELL_ID = 'A444'
        private constant integer UNIT_ID = 'uSeW'
        private constant real TIMEOUT = 1.0
        private constant string HEALER_SFX = "Models\\Effects\\SevereWounds.mdx"
        private constant string HEALED_SFX = "Abilities\\Spells\\NightElf\\ManaBurn\\ManaBurnTarget.mdl"
        private constant string SFX_SUMMON = "Abilities\\Spells\\Undead\\RaiseSkeletonWarrior\\RaiseSkeleton.mdl"
    endglobals
    
    private function HealPerSecond takes integer level returns real
        if level == 11 then
            return 2000.0
        endif
        return 100.0*level
    endfunction
    
    private function UnitHP takes integer level returns real
        return 0.0*level + 500.0 
    endfunction
    
    private function Duration takes integer level returns real
        return 10.0 + 0.0*level
    endfunction
    
    private function Radius takes integer level returns real
        return 0.0*level + 300.0
    endfunction
    
    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitAlly(u, p) and GetUnitTypeId(u) != 'uCoc'
    endfunction
    
    struct SevereWounds extends array
        implement Alloc
        
        private unit u
        private real hps
        private real radius
        private timer t
        
        private static group g
        
        private method destroy takes nothing returns nothing
            call ReleaseTimer(this.t)
            set this.u = null
            set this.t = null
            call this.deallocate()
        endmethod
        
        private static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            local player owner = GetOwningPlayer(this.u)
            local unit u
            local unit dummy
            if UnitAlive(this.u) then
                call GroupUnitsInArea(thistype.g, GetUnitX(this.u), GetUnitY(this.u), this.radius)
                set dummy = GetRecycledDummyAnyAngle(GetUnitX(this.u), GetUnitY(this.u), 10)
                call SetUnitScale(dummy, this.radius/700, 0, 0)
                call DestroyEffect(AddSpecialEffectTarget(HEALER_SFX, dummy, "origin"))
                loop
                    set u = FirstOfGroup(thistype.g)
                    exitwhen u == null
                    call GroupRemoveUnit(thistype.g, u)
                    if TargetFilter(u, owner) then
                        call Heal.unit(u, this.hps, 4.0)
                        call DestroyEffect(AddSpecialEffectTarget(HEALED_SFX, u, "origin"))
                    endif
                endloop
            else
                call this.destroy()
            endif
            set owner = null
        endmethod
        
        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            local unit caster = GetTriggerUnit()
            local real facing = GetUnitFacing(caster)
            local player owner = GetTriggerPlayer()
            local real x = GetUnitX(caster) + 100*Cos(facing*bj_DEGTORAD)
            local real y = GetUnitY(caster) + 100*Sin(facing*bj_DEGTORAD)
            local integer lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            set this.u = CreateUnit(owner, UNIT_ID, x, y, facing)
            call UnitApplyTimedLife(this.u, 'BTLF', Duration(lvl))
            call SetUnitMaxState(u, UNIT_STATE_MAX_LIFE, UnitHP(lvl))
            call DestroyEffect(AddSpecialEffectTarget(SFX_SUMMON, this.u, "origin"))
            set this.t = NewTimerEx(this)
            set this.hps = HealPerSecond(lvl)*TIMEOUT
            set this.radius = Radius(lvl)
            call TimerStart(this.t, TIMEOUT, true, function thistype.onPeriod)
            set caster = null
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            set thistype.g = CreateGroup()
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope