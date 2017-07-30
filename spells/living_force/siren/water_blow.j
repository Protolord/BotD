scope WaterBlow

    globals
        private constant integer SPELL_ID = 'AHH3'
        private constant real EXPLODE_INTERVAL = 150.0
        private constant real EXPLODE_RADIUS = 125.0
        private constant real EXPLODE_TIMEOUT = 0.125
        private constant string SFX_EXPLODE = "Objects\\Spawnmodels\\Naga\\NagaDeath\\NagaDeath.mdl"
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
    endglobals

    private function Range takes integer level returns real
        return 700.0 + 0.0*level
    endfunction

    private function AirDuration takes integer level returns real
        return 1.0 + 0.0*level
    endfunction

    private function DamageDealt takes integer level returns real
        return 20.0*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction

    struct WaterBlow extends array
        implement Alloc

        private unit caster
        private player owner
        private group affected
        private real x
        private real y
        private real dx
        private real dy
        private real dmg
        private integer explodeNum
        private real airDuration
        private timer t

        private static group enumG

        private method destroy takes nothing returns nothing
            call ReleaseTimer(this.t)
            call ReleaseGroup(this.affected)
            set this.t = null
            set this.affected = null
            set this.caster = null
            set this.owner = null
            call this.deallocate()
        endmethod

        private method explode takes nothing returns nothing
            local unit u
            //local Knockback kb
            call GroupEnumUnitsInRange(thistype.enumG, this.x, this.y, EXPLODE_RADIUS + MAX_COLLISION_SIZE, null)
            loop
                set u = FirstOfGroup(thistype.enumG)
                exitwhen u == null
                call GroupRemoveUnit(thistype.enumG, u)
                if not IsUnitInGroup(u, this.affected) and TargetFilter(u, this.owner) then
                    call GroupAddUnit(this.affected, u)
                    call Damage.element.apply(this.caster, u, this.dmg, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_WATER)
                    //Knock up
                    //set kb = Knockback.create(u, 0, 0, <some value so that total air time matches this.stunDuration>)
                    //set kb.pauseUnit = true
                endif
            endloop
            call DestroyEffect(AddSpecialEffect(SFX_EXPLODE, this.x, this.y))
            set this.x = this.x + this.dx
            set this.y = this.y + this.dy
            set this.explodeNum = this.explodeNum - 1
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            if this.explodeNum >= 0 then
                call this.explode()
            else
                call this.destroy()
            endif
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            local real tx = GetSpellTargetX()
            local real ty = GetSpellTargetY()
            local real a
            local integer lvl
            set this.caster = GetTriggerUnit()
            set this.owner = GetTriggerPlayer()
            set this.affected = NewGroup()
            set lvl = GetUnitAbilityLevel(this.caster, SPELL_ID)
            set this.x = GetUnitX(this.caster)
            set this.y = GetUnitY(this.caster)
            set a = Atan2(ty - this.y, tx - this.x)
            set this.dx = EXPLODE_INTERVAL*Cos(a)
            set this.dy = EXPLODE_INTERVAL*Sin(a)
            set this.explodeNum = R2I(Range(lvl)/EXPLODE_INTERVAL + 0.5)
            set this.airDuration = AirDuration(lvl)
            set this.dmg = DamageDealt(lvl)
            set this.t = NewTimerEx(this)
            call TimerStart(this.t, EXPLODE_TIMEOUT, true, function thistype.onPeriod)
            call this.explode()
            call SystemMsg.create(GetUnitName(this.caster) + " cast thistype")
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            set thistype.enumG = CreateGroup()
            call SystemTest.end()
        endmethod

    endstruct

endscope