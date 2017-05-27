scope SpiritualWall

    globals
        private constant integer SPELL_ID = 'AH74'
        private constant string WALL_SFX = "Models\\Effects\\SpiritualWall.mdx"
        private constant string SPIRIT = "Models\\Effects\\SpiritualWallMissile.mdx"
        private constant real TIMEOUT = 0.05
        private constant integer SIDES = 12
        private constant real REV_PER_SECOND = 0.25
        private constant integer NUM_OF_SPIRITS = 15
    endglobals

    private function MoveSlow takes integer level returns real
        return 0.9 + 0.0*level
    endfunction

    private function Radius takes integer level returns real
        return 400.0 + 0.0*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction

    private struct SpellBuff extends Buff

        readonly Movespeed ms

        private static constant integer RAWCODE = 'DH74'
        private static constant integer DISPEL_TYPE = BUFF_NONE
        private static constant integer STACK_TYPE = BUFF_STACK_FULL

        method onRemove takes nothing returns nothing
            call this.ms.destroy()
        endmethod

        method onApply takes nothing returns nothing
            set this.ms = Movespeed.create(this.target, 0, 0)
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod

        implement BuffApply
    endstruct

    private struct Spirit extends array
        private Missile m
        private real x
        private real y
        private real radius

        private thistype next
        private thistype prev

        method destroy takes nothing returns nothing
            set this.prev.next = this.next
            set this.next.prev = this.prev
            call this.m.destroy()
        endmethod

        method newTarget takes real x, real y, real z returns nothing
            local real a = GetRandomReal(0, 2*bj_PI)
            local real x2 = x + this.radius*Cos(a)
            local real y2 = y + this.radius*Sin(a)
            call this.m.targetXYZ(x2, y2, z)
        endmethod

        private static method onHit takes nothing returns nothing
            local thistype this = Missile.getHit()
            call this.newTarget(this.x, this.y, this.m.z)
            call TimerStart(NewTimerEx(this), 0.0, false, function thistype.registerAgain)
            call this.m.launch()
        endmethod

        private static method registerAgain takes nothing returns nothing
            call thistype(ReleaseTimer(GetExpiredTimer())).m.registerOnHit(function thistype.onHit)
        endmethod

        static method create takes thistype head, unit source, real radius returns thistype
            local thistype this = thistype(Missile.create())
            local real z = GetRandomReal(50, 200)
            set this.x = GetUnitX(source)
            set this.y = GetUnitY(source)
            set this.radius = radius
            set this.m = Missile(this)
            set this.m.scale = 2.0
            call this.m.sourceXYZ(this.x, this.y, z)
            call this.newTarget(this.x, this.y, z)
            set this.m.model = SPIRIT
            set this.m.speed = 400
            call this.m.registerOnHit(function thistype.onHit)
            call this.m.launch()
            set this.next = head
            set this.prev = head.prev
            set this.next.prev = this
            set this.prev.next = this
            return this
        endmethod

        method clear takes nothing returns nothing
            local thistype node = this.next
            loop
                exitwhen node == this
                call node.destroy()
                set node = node.next
            endloop
        endmethod

        method head takes nothing returns nothing
            set this.next = this
            set this.prev = this
        endmethod
    endstruct

    private struct Wall extends array
        implement Alloc

        private Effect e

        private thistype next
        private thistype prev

        private static constant real ANGLE_OFFSET = 45

        method destroy takes nothing returns nothing
            set this.prev.next = this.next
            set this.next.prev = this.prev
            call this.e.destroy()
            call this.deallocate()
        endmethod

        static method create takes thistype head, real x, real y, real facing returns thistype
            local thistype this = thistype.allocate()
            set this.e = Effect.create(WALL_SFX, x, y, 0, facing*bj_RADTODEG - ANGLE_OFFSET)
            set this.e.scale = 0.55
            set this.next = head
            set this.prev = head.prev
            set this.next.prev = this
            set this.prev.next = this
            return this
        endmethod

        method clear takes nothing returns nothing
            local thistype node = this.next
            loop
                exitwhen node == this
                call node.destroy()
                set node = node.next
            endloop
        endmethod

        static method head takes nothing returns thistype
            local thistype this = thistype.allocate()
            set this.next = this
            set this.prev = this
            return this
        endmethod
    endstruct

    struct SpiritualWall extends array
        implement Alloc
        implement List

        private real x
        private real y
        private real radius
        private group g
        private real mslow
        private unit caster
        private player owner
        private Wall wallHead
        private Spirit spiritHead
        private Table t

        private static Table tb
        private static thistype global
        private static group enumG
        private static constant real RAD_PER_SECOND = 2*bj_PI*REV_PER_SECOND*TIMEOUT

        private method destroy takes nothing returns nothing
            local unit u
            loop
                set u = FirstOfGroup(this.g)
                exitwhen u == null
                call GroupRemoveUnit(this.g, u)
                call Buff(this.t[GetHandleId(u)]).remove()
            endloop
            call this.pop()
            call ReleaseGroup(this.g)
            call this.t.destroy()
            call this.spiritHead.clear()
            call this.spiritHead.destroy()
            call this.wallHead.clear()
            call this.wallHead.destroy()
            set this.g = null
            set this.caster = null
            set this.owner = null
            call this.deallocate()
        endmethod

        private static method picked takes nothing returns nothing
            local unit u = GetEnumUnit()
            local SpellBuff b
            local integer id
            if not TargetFilter(u, global.owner) or not IsUnitInRangeXY(u, global.x, global.y, global.radius) then
                call GroupRemoveUnit(global.g, u)
                set id = GetHandleId(u)
                if Buff.has(global.caster, u, SpellBuff.typeid) then
                    call Buff(global.t[id]).remove()
                endif
            endif
            set u = null
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this = thistype(0).next
            local SpellBuff b
            local unit u
            loop
                exitwhen this == 0
                call GroupEnumUnitsInRange(thistype.enumG, this.x, this.y, this.radius, null)
                set thistype.global = this
                loop
                    set u = FirstOfGroup(thistype.enumG)
                    exitwhen u == null
                    call GroupRemoveUnit(thistype.enumG, u)
                    if IsUnitInRangeXY(u, this.x, this.y, this.radius) and TargetFilter(u, this.owner) and not IsUnitInGroup(u, this.g) then
                        set b = SpellBuff.add(this.caster, u)
                        call b.ms.change(this.mslow, 0)
                        set this.t[GetHandleId(u)] = b
                        call GroupAddUnit(this.g, u)
                    endif
                endloop
                call ForGroup(this.g, function thistype.picked)
                set this = this.next
            endloop
        endmethod

        private static method onStop takes nothing returns nothing
            local integer id = GetHandleId(GetTriggerUnit())
            local thistype this
            if thistype.tb.has(id) then
                set this = thistype.tb[id]
                call thistype.tb.remove(id)
                call this.destroy()
            endif
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            local real i = 0
            local integer lvl
            local real a
            set this.owner = GetTriggerPlayer()
            set this.caster = GetTriggerUnit()
            set this.x = GetUnitX(this.caster)
            set this.y = GetUnitY(this.caster)
            set this.g = NewGroup()
            set this.t = Table.create()
            set lvl = GetUnitAbilityLevel(this.caster, SPELL_ID)
            set this.radius = Radius(lvl)
            set this.mslow = -MoveSlow(lvl)
            set this.wallHead = Wall.head()
            set this.spiritHead = Spirit.create(0, this.caster, this.radius)
            call this.spiritHead.head()
            loop
                exitwhen i >= SIDES
                set a = 2*bj_PI*i/SIDES
                call Wall.create(this.wallHead, this.x + this.radius*Cos(a), this.y + this.radius*Sin(a), a)
                set i = i + 1
            endloop
            set i = 1
            loop
                exitwhen i >= NUM_OF_SPIRITS
                call Spirit.create(this.spiritHead, this.caster, this.radius)
                set i = i + 1
            endloop
            set thistype.tb[GetHandleId(this.caster)] = this
            call this.push(TIMEOUT)
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            set thistype.tb = Table.create()
            set thistype.enumG = CreateGroup()
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call RegisterSpellEndcastEvent(SPELL_ID, function thistype.onStop)
            call SpellBuff.initialize()
            call SystemTest.end()
        endmethod

    endstruct

endscope