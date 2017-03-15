scope RockToss

    globals
        private constant integer SPELL_ID = 'A632'
        private constant string MODEL = "Abilities\\Weapons\\AncientProtectorMissile\\AncientProtectorMissile.mdl"
        private constant string SFX_HIT = "Models\\Effects\\RockToss.mdx"
        private constant string SFX_ROCK = "Doodads\\LordaeronSummer\\Rocks\\Lords_Rock\\Lords_Rock9.mdl"
        private constant real ROCK_SPACING = 200.0
        private constant player NEUTRAL = Player(14)
    endglobals
    
    private function Duration takes integer level returns real
        return 0.0*level + 15.0
    endfunction

    private function Radius takes integer level returns real
        if level == 11 then
            return GLOBAL_SIGHT
        endif
        return 500.0*level
    endfunction

    private function StunRadius takes integer level returns real
        return 500.0 + 0.0*level
    endfunction
    
    private function StunDuration takes integer level returns real
        return 1.0 + 0.0*level
    endfunction

    private function Speed takes integer level returns real
        return 1500.0 + 0.0*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction

    private struct Rock extends array
        implement Alloc

        private effect sfx
        private unit u
        
        readonly thistype next
        readonly thistype prev
        
        method destroy takes nothing returns nothing
            set this.prev.next = this.next
            set this.next.prev = this.prev
            if this.u != null then
                call DummyAddRecycleTimer(this.u, 5.0)
                call UnitClearBonus(this.u, BONUS_SIGHT_RANGE)
                call SetUnitOwner(this.u, NEUTRAL, false)
                set this.u = null
            endif
            if this.sfx != null then
                call DestroyEffect(this.sfx)
                set this.sfx = null
            endif
            call this.deallocate()
        endmethod
        
        static method add takes player owner, thistype head, real x, real y returns nothing
            local thistype this
            if x < WorldBounds.maxX and x > WorldBounds.minX and y < WorldBounds.maxY and y > WorldBounds.minY then
                set this = thistype.allocate()
                set this.u = GetRecycledDummyAnyAngle(x, y, 0)
                call UnitSetBonus(this.u, BONUS_SIGHT_RANGE, 150)
                set this.sfx = AddSpecialEffectTarget(SFX_ROCK, this.u, "origin")
                call SetUnitOwner(this.u, owner, false)
                call SetUnitScale(this.u, 0.5, 0, 0)
                set this.next = head
                set this.prev = head.prev
                set this.prev.next = this
                set this.next.prev = this
            endif
        endmethod
        
        static method head takes nothing returns thistype
            local thistype this = thistype.allocate()
            set this.next = this
            set this.prev = this
            return this
        endmethod
    endstruct
    
    struct RockToss extends array
        
        private unit caster
        private unit target
        private unit dummy
        private integer lvl
        private player owner
        private Missile m
        private FlySight fs
        private TrueSight ts
        private Rock sfxHead

        private static group g
        
        private method destroy takes nothing returns nothing
            local Rock r 
            if this.lvl < 11 then
                set r = this.sfxHead.next
                loop
                    exitwhen r == this.sfxHead
                    call r.destroy()
                    set r = r.next
                endloop
                call this.sfxHead.destroy()
            endif
            call this.fs.destroy()
            call this.m.destroy()
            set this.caster = null
            set this.target = null
            set this.owner = null
        endmethod

        private static method expires takes nothing returns nothing
            call thistype(ReleaseTimer(GetExpiredTimer())).destroy()
        endmethod
        
        private static method onHit takes nothing returns nothing
            local thistype this = Missile.getHit()
            local group g = NewGroup()
            local real radius = Radius(this.lvl)
            local real da
            local real angle
            local real endAngle
            local unit u = GetRecycledDummyAnyAngle(this.m.x, this.m.y, 0)
            call SetUnitScale(u, StunRadius(this.lvl)/300, 0, 0)
            call DestroyEffect(AddSpecialEffectTarget(SFX_HIT, u, "origin"))
            call DummyAddRecycleTimer(u, 5.0)
            call SetUnitOwner(this.m.u, this.owner, false)
            call ShowDummy(this.m.u, false)
            set this.fs = FlySight.create(this.m.u, radius)
            set this.ts = TrueSight.create(this.m.u, radius)
            //Stun
            call GroupUnitsInArea(g, this.m.x, this.m.y, StunRadius(this.lvl))
            loop
                set u = FirstOfGroup(g)
                exitwhen u == null
                call GroupRemoveUnit(g, u)
                if TargetFilter(u, this.owner) then
                    call Stun.create(u, StunDuration(this.lvl), false)
                endif
            endloop
            call ReleaseGroup(g)
            //Create SFX
            if this.lvl < 11 then  
                set this.sfxHead = Rock.head()
                set da = 2*bj_PI/R2I(2*bj_PI*radius/ROCK_SPACING)
                if da > bj_PI/3 then
                    set da = bj_PI/3
                endif
                set angle = da
                set endAngle = da + 2*bj_PI - 0.0001
                loop
                    exitwhen angle >= endAngle
                    call Rock.add(this.owner, this.sfxHead, this.m.x + radius*Cos(angle), this.m.y + radius*Sin(angle))
                    set angle = angle + da
                endloop
            endif
            call TimerStart(NewTimerEx(this), Duration(this.lvl), false, function thistype.expires)
            set g = null
        endmethod
        
        private static method onCast takes nothing returns nothing
            local thistype this = thistype(Missile.create())
            local real x = GetSpellTargetX()
            local real y = GetSpellTargetY()
            set this.caster = GetTriggerUnit()
            set this.owner = GetTriggerPlayer()
            set this.target = GetSpellTargetUnit()
            set this.lvl = GetUnitAbilityLevel(this.caster, SPELL_ID)
            set this.m = Missile(this)
            set this.m.sourceUnit = this.caster
            call this.m.targetXYZ(x, y, GetPointZ(x, y) + 20.0)
            set this.m.speed = Speed(this.lvl)
            set this.m.model = MODEL
            call this.m.registerOnHit(function thistype.onHit)
            call this.m.launch()
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