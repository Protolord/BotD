scope StickyLiquid

    globals
        private constant integer SPELL_ID = 'AH63'
        private constant string SFX = "Models\\Effects\\StickyLiquid.mdx"
        private constant real SPACING = 87.5
    endglobals

    private function Radius takes integer level returns real
        return 0.0*level + 350.0
    endfunction

    private function Slow takes integer level returns real
        return 0.0*level + 0.45
    endfunction

    private function Duration takes integer level returns real
        return 0.3*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction

    private struct SpellBuff extends Buff

        readonly Movespeed ms

        private static constant integer RAWCODE = 'DH63'
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

    private struct Liquid extends array
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

    struct StickyLiquid extends array

        private unit caster
        private player owner
        private group g
        private real radius
        private real duration
        private real x
        private real y
        private real slow
        private SpellBuff b
        private Table tb
        private Liquid liquidHead

        private static thistype global
        private static group enumG

        private method remove takes nothing returns nothing
            local unit u
            loop
                set u = FirstOfGroup(this.g)
                exitwhen u == null
                call GroupRemoveUnit(this.g, u)
                call Buff(this.tb[GetHandleId(u)]).remove()
            endloop
            call this.liquidHead.clear()
            call this.liquidHead.destroy()
            call this.tb.destroy()
            call ReleaseGroup(this.g)
            set this.g = null
            set this.caster = null
            call this.destroy()
        endmethod

        private static method picked takes nothing returns nothing
            local unit u = GetEnumUnit()
            local SpellBuff b
            local integer id
            if not TargetFilter(u, global.owner) or not IsUnitInRangeXY(u, global.x, global.y, global.radius) then
                call GroupRemoveUnit(global.g, u)
                set id = GetHandleId(u)
                if Buff.has(global.caster, u, SpellBuff.typeid) then
                    call Buff(global.tb[id]).remove()
                endif
            endif
            set u = null
        endmethod

        implement CTL
            local unit u
            local SpellBuff b
        implement CTLExpire
            set this.duration = this.duration - CTL_TIMEOUT
            if this.duration > 0 then
                call GroupEnumUnitsInRange(thistype.enumG, this.x, this.y, this.radius + MAX_COLLISION_SIZE, null)
                set thistype.global = this
                loop
                    set u = FirstOfGroup(thistype.enumG)
                    exitwhen u == null
                    call GroupRemoveUnit(thistype.enumG, u)
                    if IsUnitInRangeXY(u, this.x, this.y, this.radius) and TargetFilter(u, this.owner) and not IsUnitInGroup(u, this.g) then
                        set b = SpellBuff.add(this.caster, u)
                        call b.ms.change(this.slow, 0)
                        set this.tb[GetHandleId(u)] = b
                        call GroupAddUnit(this.g, u)
                    endif
                endloop
                call ForGroup(this.g, function thistype.picked)
            else
                call this.remove()
            endif
        implement CTLEnd

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.create()
            local integer lvl
            local real angle
            local real endAngle
            local real da
            local real radius
            set this.caster = GetTriggerUnit()
            set this.g = NewGroup()
            set this.owner = GetTriggerPlayer()
            set lvl = GetUnitAbilityLevel(this.caster, SPELL_ID)
            set this.x = GetSpellTargetX()
            set this.y = GetSpellTargetY()
            set this.radius = Radius(lvl)
            set this.duration = Duration(lvl)
            set this.slow = -Slow(lvl)
            set this.liquidHead = Liquid.head()
            set this.tb = Table.create()
            set radius = this.radius - SPACING
            call Liquid.add(this.liquidHead, this.x, this.y)
            loop
                exitwhen radius < SPACING
                set da = 2*bj_PI/R2I(2*bj_PI*radius/SPACING)
                if da > bj_PI/3 then
                    set da = bj_PI/3
                endif
                set angle = da
                set endAngle = da + 2*bj_PI - 0.0001
                loop
                    exitwhen angle >= endAngle
                    call Liquid.add(this.liquidHead, this.x + radius*Cos(angle), this.y + radius*Sin(angle))
                    set angle = angle + da
                endloop
                set radius = radius - SPACING
            endloop

            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            set thistype.enumG = CreateGroup()
            call SpellBuff.initialize()
            call SystemTest.end()
        endmethod

    endstruct

endscope