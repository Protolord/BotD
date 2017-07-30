scope Fissure

    globals
        private constant integer SPELL_ID = 'A622'
        private constant string MODEL = "Models\\Effects\\FissureMissile.mdx"
        private constant real TIMEOUT = 0.03125
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
    endglobals

    private function DamageDealt takes integer level returns real
        if level == 11 then
            return 800.0
        endif
        return 40.0*level
    endfunction

    private function Range takes integer level returns real
        return 800.0 + 0.0*level
    endfunction

    private function Radius takes integer level returns real
        return 150.0 + 0.0*level
    endfunction

    private function Speed takes integer level returns real
        return 1000.0 + 0.0*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction

    struct Fissure extends array

        private unit caster
        private player owner
        private real dmg
        private real radius
        private group hit
        private Missile m

        private static group g

        private method destroy takes nothing returns nothing
            call this.pop()
            call ReleaseGroup(this.hit)
            set this.hit = null
            set this.caster = null
            call this.m.destroy()
        endmethod

        private static method onHit takes nothing returns nothing
            call thistype(Missile.getHit()).destroy()
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this = thistype(0).next
            local unit u
            loop
                exitwhen this == 0
                call GroupUnitsInArea(thistype.g, this.m.x, this.m.y, this.radius)
                loop
                    set u = FirstOfGroup(thistype.g)
                    exitwhen u == null
                    call GroupRemoveUnit(thistype.g, u)
                    if not IsUnitInGroup(u, this.hit) and TargetFilter(u, this.owner) then
                        call GroupAddUnit(this.hit, u)
                        call Damage.element.apply(this.caster, u, this.dmg, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_EARTH)
                    endif
                endloop
                set this = this.next
            endloop
        endmethod

        implement List

        private static method onCast takes nothing returns nothing
            local thistype this = thistype(Missile.create())
            local integer lvl
            local real x
            local real y
            local real x2
            local real y2
            local real angle
            set this.caster = GetTriggerUnit()
            set this.owner = GetTriggerPlayer()
            set lvl = GetUnitAbilityLevel(this.caster, SPELL_ID)
            set x = GetUnitX(this.caster)
            set y = GetUnitY(this.caster)
            set angle = Atan2(GetSpellTargetY() - y, GetSpellTargetX() - x)
            set x2 = x + Range(lvl)*Cos(angle)
            set y2 = y + Range(lvl)*Sin(angle)
            set this.hit = NewGroup()
            set this.dmg = DamageDealt(lvl)
            set this.radius = Radius(lvl)
            set this.m = Missile(this)
            set this.m.autohide = false
            set this.m.wave = true
            call this.m.sourceXYZ(x, y, -256)
            call this.m.targetXYZ(x2, y2, -256)
            set this.m.speed = Speed(lvl)
            set this.m.model = MODEL
            call this.m.registerOnHit(function thistype.onHit)
            call this.m.launch()
            call this.push(TIMEOUT)
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