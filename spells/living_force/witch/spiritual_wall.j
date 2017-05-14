scope SpiritualWall

    globals
        private constant integer SPELL_ID = 'AH74'
        private constant string WALL_SFX = "Models\\Effects\\SpiritualWall.mdx"
        private constant string SPIRIT = "Models\\Effects\\SpiritualWallMissile.mdx"
        private constant real TIMEOUT = 0.05
        private constant integer SIDES = 8
        private constant real REV_PER_SECOND = 0.25
    endglobals

    private function MoveSlow takes integer level returns real
        return 0.9 + 0.0*level
    endfunction

    private function Radius takes integer level returns real
        return 400.0 + 0.0*level
    endfunction

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
            set this.e.scale = 0.8
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
        private real mslow
        private unit caster
        private Wall wallHead
        private Effect spirit1
        private real spiritAngle1
        private Effect spirit2
        private real spiritAngle2

        private static Table tb
        private static constant real RAD_PER_SECOND = 2*bj_PI*REV_PER_SECOND*TIMEOUT

        private method destroy takes nothing returns nothing
            call this.pop()
            call this.spirit1.destroy()
            call this.spirit2.destroy()
            call this.wallHead.clear()
            call this.wallHead.destroy()
            set this.caster = null
            call this.deallocate()
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this = thistype(0).next
            loop
                exitwhen this == 0
                set this.spiritAngle1 = this.spiritAngle1 + thistype.RAD_PER_SECOND
                call this.spirit1.setXY(this.x + this.radius*Cos(this.spiritAngle1), this.y + this.radius*Sin(this.spiritAngle1))
                set this.spiritAngle2 = this.spiritAngle2 + thistype.RAD_PER_SECOND
                call this.spirit2.setXY(this.x + this.radius*Cos(this.spiritAngle2), this.y + this.radius*Sin(this.spiritAngle2))
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
            set this.caster = GetTriggerUnit()
            set this.x = GetUnitX(this.caster)
            set this.y = GetUnitY(this.caster)
            set lvl = GetUnitAbilityLevel(this.caster, SPELL_ID)
            set this.radius = Radius(lvl)
            set this.mslow = MoveSlow(lvl)
            set this.wallHead = Wall.head()
            loop
                exitwhen i >= SIDES
                set a = 2*bj_PI*i/SIDES
                call Wall.create(this.wallHead, this.x + this.radius*Cos(a), this.y + this.radius*Sin(a), a)
                set i = i + 1
            endloop
            set this.spiritAngle1 = 0
            set this.spiritAngle2 = bj_PI
            set this.spirit1 = Effect.createAnyAngle(SPIRIT, this.x + this.radius*Cos(this.spiritAngle1), this.y + this.radius*Sin(this.spiritAngle1), 100)
            set this.spirit2 = Effect.createAnyAngle(SPIRIT, this.x + this.radius*Cos(this.spiritAngle2), this.y + this.radius*Sin(this.spiritAngle2), 200)
            set thistype.tb[GetHandleId(this.caster)] = this
            call this.push(TIMEOUT)
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