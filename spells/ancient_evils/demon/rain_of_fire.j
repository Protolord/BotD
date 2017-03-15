scope RainOfFire
 
    globals
        private constant integer SPELL_ID = 'A521'
        private constant string MISSILE_MODEL = "Abilities\\Weapons\\LavaSpawnMissile\\LavaSpawnMissile.mdl"
        private constant real TIMEOUT = 1.0
        private constant real HEIGHT = 1200
        private constant real HEIGHT_MIN = 10
        private constant real SPEED = 800
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_CHAOS
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_UNIVERSAL
    endglobals

    private function NumberOfWaves takes integer level returns integer
        return 5 + 0*level
    endfunction

    private function WaveDamage takes integer level returns real
        if level == 11 then
            return 400.0    
        endif
        return 20.0*level
    endfunction

    private function Radius takes integer level returns real
        return 300.0 + 0.0*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction

    private keyword Wave

    private struct Fire extends array

        private Wave w
        private Missile m
        private integer part

        private static group g
        
        method destroy takes nothing returns nothing
            set this.w.fires = this.w.fires - 1
            if this.w.fires == 0 then
                call this.w.destroy()
            endif
            call this.pop()
            call this.m.destroy()
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this = thistype(0).next
            local unit u
            local real a
            loop
                exitwhen this == 0
                if GetUnitFlyHeight(this.m.u) <= HEIGHT_MIN then
                    call GroupUnitsInArea(thistype.g, this.w.r.x, this.w.r.y, this.w.r.radius)
                    if this.part == -1 then
                        loop
                            set u = FirstOfGroup(thistype.g)
                            exitwhen u == null
                            call GroupRemoveUnit(thistype.g, u)
                            if not IsUnitInGroup(u, this.w.hit) and IsUnitInRangeXY(u, this.w.r.x, this.w.r.y, 0.5*this.w.r.radius) and TargetFilter(u, this.w.r.owner) then
                                call GroupAddUnit(this.w.hit, u)
                                call Damage.element.apply(this.w.r.caster, u, this.w.r.dmg, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_FIRE)
                            endif
                        endloop
                    else
                        loop
                            set u = FirstOfGroup(thistype.g)
                            exitwhen u == null
                            call GroupRemoveUnit(thistype.g, u)
                            set a = Atan2(GetUnitY(u) - this.w.r.y, GetUnitX(u) - this.w.r.x)
                            if a < 0 then
                                set a = a + 2*bj_PI
                            endif
                            if a >= this.part*bj_PI/3 and a < (this.part + 1)*bj_PI/3 and not IsUnitInGroup(u, this.w.hit) and TargetFilter(u, this.w.r.owner) then
                                call GroupAddUnit(this.w.hit, u)
                                call Damage.element.apply(this.w.r.caster, u, this.w.r.dmg, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_FIRE)
                            endif
                        endloop
                    endif
                    call this.destroy()
                endif
                set this = this.next
            endloop
        endmethod

        implement List

        static method add takes Wave w, real x, real y, integer part returns nothing
            local thistype this = thistype(Missile.create())
            set this.w = w
            set w.fires = w.fires + 1
            set this.part = part
            set this.m = Missile(this)
            set this.m.autohide = false
            call this.m.sourceXYZ(x + 1, y + 1, HEIGHT + GetRandomReal(-300, 300))
            call this.m.targetXYZ(x, y, -HEIGHT)
            set this.m.speed = SPEED
            set this.m.model = MISSILE_MODEL
            call this.m.launch()
            call this.push(0.05)
        endmethod

        static method init takes nothing returns nothing
            set thistype.g = CreateGroup()
        endmethod
    endstruct

    private struct Wave extends array
        implement Alloc

        public integer fires
        public group hit
        public RainOfFire r
        private integer count

        method destroy takes nothing returns nothing
            if this.count == 1 then
                call r.destroy()
            endif
            call ReleaseGroup(this.hit)
            set this.hit = null
            call this.deallocate()
        endmethod

        static method add takes RainOfFire r, integer c returns nothing
            local thistype this = thistype.allocate()
            local real da = bj_PI/3
            local real a = bj_PI/6
            local real end = 2.1666*bj_PI
            local integer part = -1
            set this.r = r
            set this.hit = NewGroup()
            set this.fires = 0
            set this.count = c
            call Fire.add(this, r.x, r.y, part)
            loop
                exitwhen a >= end
                set part = part + 1
                call Fire.add(this, r.x + 0.6*r.radius*Cos(a), r.y + 0.6*r.radius*Sin(a), part)
                set a = a + da
            endloop
        endmethod

    endstruct
    
    struct RainOfFire extends array
        implement Alloc

        readonly unit caster
        readonly player owner
        readonly real radius
        readonly real x
        readonly real y
        readonly real dmg
        readonly integer count
        private timer t

        method destroy takes nothing returns nothing
            call ReleaseTimer(this.t)
            set this.t = null
            set this.caster = null
            set this.owner = null
            call this.deallocate()
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            if this.count > 0 then
                call Wave.add(this, this.count)
                set this.count = this.count - 1
            endif
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            local integer lvl
            set this.caster = GetTriggerUnit()
            set this.owner = GetTriggerPlayer()
            set lvl = GetUnitAbilityLevel(this.caster, SPELL_ID)
            set this.x = GetSpellTargetX()
            set this.y = GetSpellTargetY()
            set this.radius = Radius(lvl)
            set this.dmg = WaveDamage(lvl)
            set this.count = NumberOfWaves(lvl)
            set this.t = NewTimerEx(this)
            call TimerStart(this.t, TIMEOUT, true, function thistype.onPeriod)
            call Wave.add(this, this.count)
            set this.count = this.count - 1
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call Fire.init()
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SystemTest.end()
        endmethod

    endstruct
    
endscope