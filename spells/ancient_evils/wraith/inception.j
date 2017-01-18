scope Inception
    
    globals
        private constant integer SPELL_ID = 'A344'
        private constant string SFX_SOURCE = "Models\\Effects\\InceptionSource.mdx"
        private constant string SFX_TARGET = "Models\\Effects\\InceptionTarget.mdx"
        private constant real OFFSET = 100.0
    endglobals
    
    private function IllusionDamageTaken takes integer level returns real
        if level == 11 then
            return 3.0
        endif
        return  9.0 - 0.5*level
    endfunction
    
    private function NumberOfIllusions takes integer level returns integer
        return 2 + 0*level
    endfunction
    
    private function Duration takes integer level returns real
        return 15.0 + 0.0*level
    endfunction
    
    private function DistanceThreshold takes integer level returns real
        return 800.0 + 0.8*level
    endfunction

    struct Inception extends array
        
        private unit caster
        private group g
        private real dist
        
        private static group swap
        private static group temp
        
        
        private static method expires takes nothing returns nothing
            local thistype this = ReleaseTimer(GetExpiredTimer())
            local real addHp = 0
            local unit u
            loop
                set u = FirstOfGroup(this.g)
                exitwhen u == null
                call GroupRemoveUnit(this.g, u)
                if UnitAlive(u) then
                    set addHp = addHp + GetWidgetLife(u)
                    call DestroyEffect(AddSpecialEffect(SFX_SOURCE, GetUnitX(u), GetUnitY(u)))
                endif
            endloop
            if addHp > 0 then
                call SetWidgetLife(this.caster, GetWidgetLife(this.caster) + addHp)
                call DestroyEffect(AddSpecialEffectTarget(SFX_TARGET, this.caster, "origin"))
            endif
            call DestroyGroup(this.g)
            set this.g = null
            set this.caster = null
            call this.destroy()
        endmethod
        
        implement CTL
            local unit u
        implement CTLExpire
            loop
                set u = FirstOfGroup(this.g)
                exitwhen u == null
                if IsUnitInRange(this.caster, u, this.dist) then
                    call GroupAddUnit(thistype.swap, u)
                else
                    call KillUnit(u)
                endif
                call GroupRemoveUnit(this.g, u)
            endloop
            set thistype.temp = this.g
            set this.g = thistype.swap
            set thistype.swap = thistype.temp
        implement CTLEnd
        
        private static method debuff takes nothing returns nothing
            local thistype this = ReleaseTimer(GetExpiredTimer())
            call UnitRemoveAbility(this.caster, 'Bbsk')
        endmethod
        
        private static method onCast takes nothing returns nothing
            local thistype this = thistype.create()
            local player owner = GetTriggerPlayer()
            local real angle
            local real dangle
            local integer lvl
            local integer num
            local real duration
            local real dmgFactor
            local real x
            local real y
            local Illusion il
            set this.caster = GetTriggerUnit()
            set x = GetUnitX(this.caster)
            set y = GetUnitY(this.caster)
            set lvl = GetUnitAbilityLevel(this.caster, SPELL_ID)
            set duration = Duration(lvl)
            set dmgFactor = IllusionDamageTaken(lvl)
            set num = NumberOfIllusions(lvl)
            set this.dist = DistanceThreshold(lvl)
            set this.g = CreateGroup()
            set angle = GetUnitFacing(this.caster)*bj_DEGTORAD + 0.5*bj_PI
            set dangle = 2*bj_PI/num
            loop
                exitwhen num == 0
                set angle = angle + dangle
                set il = Illusion.create(owner, this.caster, x + OFFSET*Cos(angle), y + OFFSET*Sin(angle))
                set il.damageGiven = 0.0
                set il.damageTaken = dmgFactor
                set il.duration = duration
                call GroupAddUnit(this.g, il.unit)
                set num = num - 1
            endloop
            call TimerStart(NewTimerEx(this), 0.00, false, function thistype.debuff)
            call TimerStart(NewTimerEx(this), 14.995, false, function thistype.expires)
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            set thistype.swap = CreateGroup()
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope