scope Sandstorm

    globals
        private constant integer SPELL_ID = 'AHD2'
        private constant string SFX = "Models\\Effects\\Sandstorm.mdx"
        private constant real TIMEOUT = 0.05
        private constant real DAMAGE_TIMEOUT = 0.25
        private constant real SPACING = 60.0
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
    endglobals

    private function MoveSlow takes integer level returns real
        return 0.50 + 0.0*level
    endfunction

    private function Radius takes integer level returns real
        return 0.0*level + 150.0
    endfunction

    private function DamagePerSecond takes integer level returns real
        if level == 11 then
            return 400.0
        endif
        return 20.0*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction

    private struct SpellBuff extends Buff

        private Movespeed ms
        private Silence s
        private timer t
        private real dmg

        private static constant integer RAWCODE = 'DHD2'
        private static constant integer DISPEL_TYPE = BUFF_NEGATIVE
        private static constant integer STACK_TYPE = BUFF_STACK_PARTIAL

        method onRemove takes nothing returns nothing
            call this.ms.destroy()
            call this.s.destroy()
            call ReleaseTimer(this.t)
            set this.t = null
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            call FloatingText.setSplatProperties(DAMAGE_TIMEOUT)
            if TargetFilter(this.target, GetOwningPlayer(this.source)) then
                call Damage.element.apply(this.source, this.target, this.dmg, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_EARTH)
            else
                call this.remove()
            endif
            call FloatingText.resetSplatProperties()
        endmethod

        method onApply takes nothing returns nothing
            set this.ms = Movespeed.create(this.target, 0, 0)
            set this.s = Silence.create(this.target, 0)
            set this.t = NewTimerEx(this)
            call TimerStart(this.t, DAMAGE_TIMEOUT, true, function thistype.onPeriod)
        endmethod

        method reapply takes real slow, real dmg returns nothing
            set this.dmg = dmg
            call this.ms.change(slow, 0)
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod

        implement BuffApply
    endstruct

    private struct Sand extends array
        implement Alloc

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
            call this.deallocate()
        endmethod

        method clear takes nothing returns nothing
            local thistype node = this.next
            loop
                exitwhen node == this
                call node.destroy()
                set node = node.next
            endloop
        endmethod

        static method add takes thistype head, real x, real y returns nothing
            local thistype this = thistype.allocate()
            set this.next = head
            set this.prev = head.prev
            set this.next.prev = this
            set this.prev.next = this
            set this.sfx = AddSpecialEffect(SFX, x, y)
        endmethod

        static method head takes nothing returns thistype
            local thistype this = thistype.allocate()
            set this.next = this
            set this.prev = this
            return this
        endmethod

    endstruct

    struct Sandstorm extends array
        implement Alloc
        implement List

        private unit caster
        private player owner
        private integer id
        private real x
        private real y
        private real radius
        private real dmg
        private real slow
        private group g
        private Table t
        private Sand sandHead

        private static group enumG
        private static Table tb
        private static thistype global

        private method destroy takes nothing returns nothing
            local unit u
            loop
                set u = FirstOfGroup(this.g)
                exitwhen u == null
                call GroupRemoveUnit(this.g, u)
                call Buff(this.t[GetHandleId(u)]).remove()
            endloop
            call this.tb.remove(this.id)
            call this.sandHead.clear()
            call this.sandHead.destroy()
            call this.pop()
            call ReleaseGroup(this.g)
            call this.t.destroy()
            set this.g = null
            set this.caster = null
            set this.owner = null
            call this.deallocate()
        endmethod

        private static method onStop takes nothing returns nothing
            local thistype this = thistype.tb[GetHandleId(GetTriggerUnit())]
            if this > 0 then
                call this.destroy()
            endif
        endmethod

        private static method picked takes nothing returns nothing
            local unit u = GetEnumUnit()
            if not TargetFilter(u, thistype.global.owner) or not IsUnitInRangeXY(u, thistype.global.x, thistype.global.y, thistype.global.radius) then
                call GroupRemoveUnit(thistype.global.g, u)
                if Buff.has(thistype.global.caster, u, SpellBuff.typeid) then
                    call Buff(thistype.global.t[GetHandleId(u)]).remove()
                endif
            endif
            set u = null
        endmethod

        static method onPeriod takes nothing returns nothing
            local thistype this = thistype(0).next
            local unit u
            local SpellBuff b
            loop
                exitwhen this == 0
                call GroupEnumUnitsInRange(thistype.enumG, this.x, this.y, this.radius + MAX_COLLISION_SIZE, null)
                    set thistype.global = this
                    loop
                        set u = FirstOfGroup(thistype.enumG)
                        exitwhen u == null
                        call GroupRemoveUnit(thistype.enumG, u)
                        if IsUnitInRangeXY(u, this.x, this.y, this.radius) and TargetFilter(u, this.owner) and not IsUnitInGroup(u, this.g) then
                            set b = SpellBuff.add(this.caster, u)
                            call b.reapply(this.slow, this.dmg)
                            set this.t[GetHandleId(u)] = b
                            call GroupAddUnit(this.g, u)
                        endif
                    endloop
                call ForGroup(this.g, function thistype.picked)
                set this = this.next
            endloop
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            local integer lvl
            local real r
            local real angle
            local real endAngle
            local real da
            set this.caster = GetTriggerUnit()
            set this.owner = GetTriggerPlayer()
            set this.id = GetHandleId(this.caster)
            set this.x = GetSpellTargetX()
            set this.y = GetSpellTargetY()
            set lvl = GetUnitAbilityLevel(this.caster, SPELL_ID)
            set this.dmg = DamagePerSecond(lvl)*DAMAGE_TIMEOUT
            set this.slow = -MoveSlow(lvl)
            set this.g = NewGroup()
            set this.radius = Radius(lvl)
            set this.t = Table.create()
            set this.sandHead = Sand.head()
            set r = this.radius - SPACING - 10.0
            call Sand.add(this.sandHead, this.x, this.y)
            loop
                exitwhen r < SPACING
                set da = 2*bj_PI/R2I(2*bj_PI*r/SPACING)
                if da > bj_PI/3 then
                    set da = bj_PI/3
                endif
                set angle = da
                set endAngle = da + 2*bj_PI - 0.0001
                loop
                    exitwhen angle >= endAngle
                    call Sand.add(this.sandHead, this.x + r*Cos(angle), this.y + r*Sin(angle))
                    set angle = angle + da
                endloop
                set r = r - SPACING
            endloop

            call this.push(TIMEOUT)
            set this.tb[GetHandleId(this.caster)] = this
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call RegisterSpellEndcastEvent(SPELL_ID, function thistype.onStop)
            call SpellBuff.initialize()
            set thistype.enumG = CreateGroup()
            set thistype.tb = Table.create()
            call SystemTest.end()
        endmethod

    endstruct

endscope