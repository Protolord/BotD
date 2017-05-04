scope Hellguard
 
    globals
        private constant integer SPELL_ID = 'A543'
        private constant string SFX_IMP = "Models\\Effects\\Hellguard.mdx"
        private constant string SFX = "Models\\Effects\\HellguardPentagram.mdx"
        private constant real TIMEOUT = 1.0
        private constant real IMP_SCALE = 0.5
    endglobals

    private function Radius takes integer level returns real
        return 0.0*level + 100.0
    endfunction

    private function Duration takes integer level returns real
        return 0.0*level + 10.0
    endfunction

    private function HealPerSecond takes integer level returns real
        if level == 11 then
            return 1000.0
        endif
        return 100.0*level
    endfunction

    private function Bonus takes integer level returns real
        if level == 11 then
            return 0.2
        endif
        return 0.1
    endfunction

    //For visual purposes only
    private function Imps takes integer level returns integer
        if level == 11 then
            return 10
        endif
        return 6
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitAlly(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE)
    endfunction

    private struct Imp extends array
        implement Alloc
        
        private unit u
        private effect sfx
        
        readonly thistype next
        readonly thistype prev
        
        method destroy takes nothing returns nothing
            set this.prev.next = this.next
            set this.next.prev = this.prev
            if this.sfx != null then
                call DestroyEffect(this.sfx)
                set this.sfx = null
            endif
            if this.u != null then
                call DummyAddRecycleTimer(this.u, 3.0)
                set this.u = null
            endif
            call this.deallocate()
        endmethod
        
        static method add takes thistype head, real x, real y, real angle returns nothing
            local thistype this = thistype.allocate()
            set this.u = GetRecycledDummy(x, y, 0, bj_RADTODEG*angle + 180)
            set this.sfx = AddSpecialEffectTarget(SFX_IMP, this.u, "origin")
            call SetUnitScale(this.u, IMP_SCALE, 0, 0)
            set this.next = head
            set this.prev = head.prev
            set this.prev.next = this
            set this.next.prev = this
        endmethod
        
        static method head takes nothing returns thistype
            local thistype this = thistype.allocate()
            set this.next = this
            set this.prev = this
            return this
        endmethod
    endstruct
    
    struct Hellguard extends array
        implement Alloc

        private unit caster
        private real duration
        private real radius
        private real heal
        private real bonus
        private real x
        private real y
        private timer t
        private effect sfx
        private unit sfxDummy
        private Imp impHead
        private Table tb

        private static group g

        private method destroy takes nothing returns nothing
            local Imp ih = this.impHead.next
            loop
                exitwhen ih == this.impHead
                call ih.destroy()
                set ih = ih.next
            endloop
            call this.impHead.destroy()
            call this.tb.destroy()
            call ReleaseTimer(this.t)
            call DummyAddRecycleTimer(this.sfxDummy, 2.0)
            call DestroyEffect(this.sfx)
            set this.t = null
            set this.sfx = null
            set this.sfxDummy = null
            set this.caster = null
            call this.deallocate()
        endmethod

        private static method debuff takes nothing returns nothing
            local thistype this = ReleaseTimer(GetExpiredTimer())
            call UnitRemoveAbility(this.caster, 'Bbsk')
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            local unit u
            local player owner
            local integer id
            local integer i
            set this.duration = this.duration - TIMEOUT
            if this.duration > 0 then
                set owner = GetOwningPlayer(this.caster)
                call GroupUnitsInArea(thistype.g, this.x, this.y, this.radius)
                loop
                    set u = FirstOfGroup(thistype.g)
                    exitwhen u == null
                    call GroupRemoveUnit(thistype.g, u)
                    if TargetFilter(u, owner) then
                        set id = GetHandleId(u)
                        set i = this.tb[id]
                        set this.tb[id] = i + 1
                        call Heal.unit(this.caster, u, this.heal + this.bonus*this.heal*I2R(i)/TIMEOUT, 4.0, true)
                    endif
                endloop
            else
                call this.destroy()
            endif
            set owner = null
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            local real angle = 0
            local real da
            local integer lvl
            local integer i
            local unit imp
            set this.caster = GetTriggerUnit()
            set this.x = GetUnitX(this.caster)
            set this.y = GetUnitY(this.caster)
            set lvl = GetUnitAbilityLevel(this.caster, SPELL_ID)
            set this.radius = Radius(lvl)
            set this.duration = Duration(lvl)
            set this.heal = HealPerSecond(lvl)
            set this.bonus = Bonus(lvl)
            set this.impHead = Imp.head()
            set this.tb = Table.create()
            set i = Imps(lvl)
            set da = 2*bj_PI/i
            loop
                exitwhen i == 0
                call Imp.add(this.impHead, this.x + this.radius*Cos(angle), this.y + this.radius*Sin(angle), angle)
                set angle = angle + da
                set i = i - 1
            endloop
            set this.sfxDummy = GetRecycledDummyAnyAngle(this.x, this.y, 0)
            set this.sfx = AddSpecialEffectTarget(SFX, this.sfxDummy, "origin")
            call SetUnitScale(this.sfxDummy, this.radius/80, 0, 0)
            set this.t = NewTimerEx(this)
            call TimerStart(this.t, TIMEOUT, true, function thistype.onPeriod)
            call TimerStart(NewTimerEx(this), 0.00, false, function thistype.debuff)
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            set thistype.g = CreateGroup()
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope