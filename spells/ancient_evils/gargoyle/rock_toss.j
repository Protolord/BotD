scope RockToss

    globals
        private constant integer SPELL_ID = 'A632'
        private constant string MODEL = "Abilities\\Weapons\\AncientProtectorMissile\\AncientProtectorMissile.mdl"
        private constant string SFX_HIT = "Models\\Effects\\RockToss.mdx"
        private constant real SPEED = 1000.0
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

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction
    
    struct RockToss extends array
        
        private unit caster
        private unit dummy
        private integer lvl
        private player owner
        private Missile m
        private FlySight fs
        private TrueSight ts

        private static group g
        
        private method destroy takes nothing returns nothing
            call this.fs.destroy()
            call this.ts.destroy()
            call this.m.destroy()
            set this.caster = null
            set this.owner = null
        endmethod

        private static method expires takes nothing returns nothing
            call thistype(ReleaseTimer(GetExpiredTimer())).destroy()
        endmethod
        
        private static method onHit takes nothing returns nothing
            local thistype this = Missile.getHit()
            local real radius = Radius(this.lvl)
            local unit u = GetRecycledDummyAnyAngle(this.m.x, this.m.y, 0)
            call SetUnitScale(u, StunRadius(this.lvl)/300, 0, 0)
            call DestroyEffect(AddSpecialEffectTarget(SFX_HIT, u, "origin"))
            call DummyAddRecycleTimer(u, 6.0)
            call SetUnitOwner(this.m.u, this.owner, false)
            call ShowDummy(this.m.u, false)
            set this.fs = FlySight.create(this.m.u, radius)
            set this.ts = TrueSight.create(this.m.u, radius)
            //Stun
            call GroupUnitsInArea(thistype.g, this.m.x, this.m.y, StunRadius(this.lvl))
            loop
                set u = FirstOfGroup(thistype.g)
                exitwhen u == null
                call GroupRemoveUnit(thistype.g, u)
                if TargetFilter(u, this.owner) then
                    call Stun.create(u, StunDuration(this.lvl), false)
                endif
            endloop
            call TimerStart(NewTimerEx(this), Duration(this.lvl), false, function thistype.expires)
        endmethod
        
        private static method onCast takes nothing returns nothing
            local thistype this = thistype(Missile.create())
            local real x = GetSpellTargetX()
            local real y = GetSpellTargetY()
            set this.caster = GetTriggerUnit()
            set this.owner = GetTriggerPlayer()
            set this.lvl = GetUnitAbilityLevel(this.caster, SPELL_ID)
            set this.m = Missile(this)
            set this.m.sourceUnit = this.caster
            call this.m.targetXYZ(x, y, GetPointZ(x, y) + 5.0)
            set this.m.speed = SPEED
            set this.m.model = MODEL
            set this.m.autohide = true
            set this.m.projectile = true
            set this.m.arc = 1.75
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