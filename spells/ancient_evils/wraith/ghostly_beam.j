scope GhostlyBeam

    globals
        private constant integer SPELL_ID = 'A331'
        private constant string SFX = "Abilities\\Weapons\\NecromancerMissile\\NecromancerMissile.mdl"
        private constant string LIGHT_SFX = "Models\\Effects\\GhostlyBeamLightt.mdx"
        private constant real SPEED = 1250.0
        private constant real TIMEOUT = 0.0625
        private constant real ULT_DURATION = 10.0
    endglobals

    private function NodeSightRadius takes integer level returns real
        if level == 11 then
            return GLOBAL_SIGHT
        endif
        return 100.0*level
    endfunction

    private struct Vision extends array

        private Missile m
        private FlySight fs
        private TrueSight ts

        private thistype next
        private thistype prev

        private method destroy takes nothing returns nothing
            call this.fs.destroy()
            call this.ts.destroy()
            call this.m.destroy()
        endmethod

        private static method onHit takes nothing returns nothing
            local thistype this = thistype(Missile.getHit())
            if this.ts.radius == GLOBAL_SIGHT then
                set this.m.stop = true
                call this.m.show(false)
            else
                call this.destroy()
            endif
        endmethod

        private static method expires takes nothing returns nothing
            call thistype(ReleaseTimer(GetExpiredTimer())).destroy()
        endmethod

        static method add takes GhostlyBeam b returns thistype
            local thistype this = thistype(Missile.create())
            set this.m = Missile(this)
            call this.m.sourceXYZ(b.x, b.y, b.z)
            call this.m.targetXYZ(b.x2, b.y2, b.z2)
            set this.m.model = SFX
            set this.m.speed = SPEED
            call this.m.launch()
            call SetUnitVertexColor(this.m.u, 255, 0, 0, 255)
            call SetUnitOwner(this.m.u, b.owner, false)
            if b.radius == GLOBAL_SIGHT then
                call SetUnitScale(this.m.u, 2.75, 0, 0)
            else
                call SetUnitScale(this.m.u, 2.0 + b.radius/1500, 0, 0)
            endif
            call this.m.registerOnHit(function thistype.onHit)
            set this.ts = TrueSight.create(this.m.u, b.radius)
            set this.fs = FlySight.create(this.m.u, b.radius)
            if b.duration > 0 then
                call TimerStart(NewTimerEx(this), b.duration, false, function thistype.expires)
            endif
            return this
        endmethod
    endstruct

    struct GhostlyBeam extends array
        implement Alloc

        private integer id
        private unit dummy
        private effect sfx
        readonly player owner
        readonly real x
        readonly real y
        readonly real z
        readonly real x2
        readonly real y2
        readonly real z2
        readonly real radius
        readonly real duration
        readonly boolean first
        readonly Vision head

        private static Table tb

        private method destroy takes nothing returns nothing
            call thistype.tb.remove(this.id)
            call this.pop()
            call DestroyEffect(this.sfx)
            call DummyAddRecycleTimer(this.dummy, 2.0)
            set this.sfx = null
            set this.dummy = null
            set this.owner = null
            call this.deallocate()
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this = thistype(0).next
            loop
                exitwhen this == 0
                if this.duration > 0 then
                    set this.duration = this.duration - TIMEOUT
                endif
                call Vision.add(this)
                set this = this.next
            endloop
        endmethod

        implement List

        private static method onStop takes nothing returns nothing
            call thistype(thistype.tb[GetHandleId(GetTriggerUnit())]).destroy()
        endmethod

        private static real Z_OFFSET = 50.0

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            local unit caster = GetTriggerUnit()
            local integer lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            set this.owner = GetTriggerPlayer()
            set this.x = GetUnitX(caster)
            set this.y = GetUnitY(caster)
            set this.z = GetUnitZ(caster) + thistype.Z_OFFSET
            set this.x2 = GetSpellTargetX()
            set this.y2 = GetSpellTargetY()
            set this.z2 = GetPointZ(this.x2, this.y2) + thistype.Z_OFFSET
            set this.radius = NodeSightRadius(lvl)
            if lvl == 11 then
                set this.duration = ULT_DURATION
            else
                set this.duration = 0
            endif
            set this.id = GetHandleId(caster)
            call this.push(TIMEOUT)
            set this.first = true
            set this.head = Vision.add(this)
            set this.first = false
            set this.dummy = GetRecycledDummy(this.x, this.y, this.z, Atan2(this.y2 - this.y, this.x2 - this.x)*bj_RADTODEG)
            set this.sfx = AddSpecialEffectTarget(LIGHT_SFX, this.dummy, "origin")
            call SetUnitVertexColor(this.dummy, 255, 0, 0, 255)
            call SetUnitScale(this.dummy, 1.25 + lvl/10, 0, 0)
            set thistype.tb[this.id] = this
            set caster = null
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            set thistype.tb = Table.create()
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call RegisterSpellEndcastEvent(SPELL_ID, function thistype.onStop)
            call SystemTest.end()
        endmethod

    endstruct

endscope