scope Rebuild

    globals
        private constant integer SPELL_ID = 'A644'
        private constant integer BUFF_ID = 'B644'
        private constant real DECAY_RATE = 0.05
        private constant string HEAL_SFX = "Models\\Effects\\RebuildHeal.mdx"
        private constant string MISSILE_MODEL = "Abilities\\Weapons\\Catapult\\CatapultMissile.mdl"
        private constant string ROCK_MODEL = "Doodads\\Underground\\Rocks\\UndergoundRock\\UndergoundRock9.mdl"
        private constant real SPEED = 500.0
        private constant real TIMEOUT = 0.1
        private constant real DISTANCE_PER_DAMAGE = 0.25
        private constant real MIN_DISTANCE = 150.0
        private constant real PICK_RADIUS = 100.0
    endglobals

    private function DamageThreshold takes integer level returns real
        return 200.0 + 0.0*level
    endfunction

    //In Percent
    private function RecoverRate takes integer level returns real
        return 25.0 + 5.0*level
    endfunction

    private struct RockPiece extends array
        implement List

        private Missile m
        private Effect e
        private unit source
        private real hp
        private real hpLoss

        private static group g

        private method destroy takes nothing returns nothing
            call this.pop()
            call ShowDummy(this.m.u, true)
            set this.e.scale = 0
            call this.e.destroy()
            call this.m.destroy()
            set this.source = null
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this = thistype(0).next
            local unit u
            loop
                exitwhen this == 0
                if this.hp > 0 then
                    call GroupEnumUnitsInRange(thistype.g, this.m.x, this.m.y, PICK_RADIUS, null)
                    loop
                        set u = FirstOfGroup(thistype.g)
                        exitwhen u == null
                        call GroupRemoveUnit(thistype.g, u)
                        if u == this.source then
                            call Heal.unit(u, u, this.hp, 1.0, true)
                            call DestroyEffect(AddSpecialEffectTarget(HEAL_SFX, u, "origin"))
                            call this.destroy()
                        endif
                    endloop
                    set this.hp = this.hp - this.hpLoss
                else
                    call this.destroy()
                endif
                set this = this.next
            endloop
        endmethod

        private static method onHit takes nothing returns nothing
            local thistype this = Missile.getHit()
            call ShowDummy(this.m.u, false)
            set this.e = Effect.createAnyAngle(ROCK_MODEL, this.m.x, this.m.y, 5)
            set this.e.scale = 0.4 + this.hp/2000.0
            call this.push(TIMEOUT)
        endmethod

        static method create takes unit source, real hp, real x, real y returns thistype
            local thistype this = thistype(Missile.create())
            set this.source = source
            set this.hp = hp
            set this.hpLoss = hp*DECAY_RATE*TIMEOUT
            set this.m = Missile(this)
            set this.m.sourceUnit = source
            call this.m.targetXYZ(x, y, GetPointZ(x, y) + 5.0)
            set this.m.speed = SPEED
            set this.m.model = MISSILE_MODEL
            set this.m.autohide = false
            set this.m.projectile = true
            set this.m.arc = 1.0
            call this.m.registerOnHit(function thistype.onHit)
            call this.m.launch()
            return this
        endmethod

        static method init takes nothing returns nothing
            set thistype.g = CreateGroup()
        endmethod

    endstruct

    struct Rebuild extends array
        implement Alloc

        private unit u
        private real factor
        private real dmg
        private real dmgThreshold

        private static Table tb
        private static constant real ANGLE_OFFSET = 6

        private static method onDamage takes nothing returns nothing
            local thistype this = thistype.tb[GetHandleId(Damage.target)]
            local real angle
            local real x1
            local real y1
            local real x2
            local real y2
            local real dist
            local real a
            local integer cliff
            local integer i = 1
            local integer j = 1
            if this > 0 then
                set this.dmg = this.dmg + Damage.amount
                if this.dmg >= this.dmgThreshold then
                    set x1 = GetUnitX(Damage.source)
                    set y1 = GetUnitY(Damage.source)
                    set x2 = GetUnitX(Damage.target)
                    set y2 = GetUnitY(Damage.target)
                    set cliff = GetTerrainCliffLevel(x2, y2)
                    set angle = Atan2(y2 - y1, x2 - x1)
                    set dist = RMaxBJ(MIN_DISTANCE, DISTANCE_PER_DAMAGE*this.dmg) + GetRandomReal(0, 50)
                    set x1 = x2 + dist*Cos(angle)
                    set y1 = y2 + dist*Sin(angle)
                    loop
                        exitwhen IsTerrainBuildable(x1, y1) and cliff == GetTerrainCliffLevel(x1, y1)
                        set i = i + 1
                        set j = -j
                        set a = angle + i*j*thistype.ANGLE_OFFSET
                        set x1 = x2 + dist*Cos(a)
                        set y1 = y2 + dist*Sin(a)
                    endloop
                    call RockPiece.create(Damage.target, this.dmg*this.factor, x1, y1)
                    set this.dmg = 0
                endif
            endif
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod

        private static method learn takes nothing returns nothing
            local thistype this
            local unit u
            local integer id
            local integer lvl
            if GetLearnedSkill() == SPELL_ID then
                set u = GetTriggerUnit()
                set id = GetHandleId(u)
                if not thistype.tb.has(id) then
                    set this = thistype.allocate()
                    set this.u = u
                    set this.dmg = 0
                    set thistype.tb[id] = this
                    call UnitAddAbility(u, BUFF_ID)
                    call UnitMakeAbilityPermanent(u, true, BUFF_ID)
                else
                    set this = thistype.tb[id]
                endif
                set lvl = GetUnitAbilityLevel(u, SPELL_ID)
                set this.dmgThreshold = DamageThreshold(lvl)
                set this.factor = RecoverRate(lvl)/100.0
                set u = null
            endif
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call Damage.register(function thistype.onDamage)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_SKILL, function thistype.learn)
            set thistype.tb = Table.create()
            call RockPiece.init()
            call SystemTest.end()
        endmethod

    endstruct

endscope