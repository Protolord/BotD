scope MotionController

    globals
        private constant integer SPELL_ID = 'AH64'
        private constant integer UNIT_ID = 'hMCo'
        private constant string CHAIN_ELEMENT = "Models\\Effects\\ChainElement.mdx"
        private constant string CHAIN_HEAD = "Models\\Effects\\ChainHead.mdx"
        private constant string SFX_APPEAR = "Models\\Effects\\MotionControllerEntrance.mdx"
        private constant real SUMMON_OFFSET = 100.0
        private constant real TIMEOUT = 0.03125
        private constant real CHAIN_INTERVAL = 55.0
        private constant real BREAK_DISTANCE = 500.0
        private constant real ANGLE_TOLERANCE = 30
    endglobals

    private function Range takes integer level returns real
        return 300.0 + 0.0*level
    endfunction

    private function Duration takes integer level returns real
        return 10.0*level - 5.0
    endfunction

    private function DeviceHP takes integer level returns real
        return 5.0 + 0.0*level
    endfunction

    private struct SpellBuff extends Buff

        private static constant integer RAWCODE = 'DH64'
        private static constant integer DISPEL_TYPE = BUFF_NEGATIVE
        private static constant integer STACK_TYPE = BUFF_STACK_FULL

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod

        implement BuffApply
    endstruct

    private struct Chain extends array
        implement Alloc

        readonly Effect e
        private thistype next
        private thistype prev

        method destroy takes nothing returns nothing
            set this.prev.next = this.next
            set this.next.prev = this.prev
            call this.e.destroy()
            call this.deallocate()
        endmethod

        static method create takes thistype head, real x, real y, real a returns thistype
            local thistype this = thistype.allocate()
            set this.next = head
            set this.prev = head.prev
            set this.next.prev = this
            set this.prev.next = this
            set this.e = Effect.create(CHAIN_ELEMENT, x, y, 50, a*bj_RADTODEG)
            return this
        endmethod

        method update takes string model, real x, real y, real angle returns nothing
            local real old = this.e.facing
            local real new = angle*bj_RADTODEG
            if RAbsBJ(new - old) >= ANGLE_TOLERANCE then
                call this.e.destroy()
                set this.e = Effect.create(model, x, y, 50, new)
            else
                set this.e.facing = new
            endif
            call this.e.setXY(x, y)
        endmethod

        method updateHead takes real x1, real y1, real x2, real y2, real angle, real range returns nothing
            local thistype node = this.next
            local real dx = -CHAIN_INTERVAL*Cos(angle)
            local real dy = -CHAIN_INTERVAL*Sin(angle)
            local real r = CHAIN_INTERVAL
            call this.update(CHAIN_HEAD, x2, y2, angle)
            loop
                exitwhen node == this and r >= range
                if r < range then
                    if node == this then
                        set node = thistype.create(this, x2 - r*Cos(angle), y2 - r*Sin(angle), angle)
                    else
                        call node.update(CHAIN_ELEMENT, x2 - r*Cos(angle), y2 - r*Sin(angle), angle)
                    endif
                else
                    call node.destroy()
                endif
                set r = r + CHAIN_INTERVAL
                set node = node.next
            endloop
        endmethod

        method clear takes nothing returns nothing
            local thistype node = this.next
            loop
                exitwhen node == this
                call node.destroy()
                set node = node.next
            endloop
        endmethod

        static method head takes real x, real y, real a returns thistype
            local thistype this = thistype.allocate()
            set this.next = this
            set this.prev = this
            set this.e = Effect.create(CHAIN_HEAD, x, y, 50, a*bj_RADTODEG)
            return this
        endmethod
    endstruct

    struct MotionController extends array
        implement Alloc
        implement List

        private real x
        private real y
        private unit target
        private real angle
        private real range
        private unit device
        private Chain chainHead
        private Lightning l
        private SpellBuff b

        private static Table tb

        private method destroy takes nothing returns nothing
            call this.pop()
            call this.b.remove()
            call this.l.destroy()
            call thistype.tb.remove(GetHandleId(this.device))
            call this.chainHead.clear()
            call this.chainHead.destroy()
            set this.device = null
            set this.target = null
            call this.deallocate()
        endmethod

        private static method remove takes unit u returns nothing
            local thistype this = thistype.tb[GetHandleId(u)]
            if this > 0 then
                call this.destroy()
            endif
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this = thistype(0).next
            local real newAngle
            local real x2
            local real y2
            local real dx
            local real dy
            local real dxy
            loop
                exitwhen this == 0
                if UnitAlive(this.target) and UnitAlive(this.device) then
                    set x2 = GetUnitX(this.target)
                    set y2 = GetUnitY(this.target)
                    set dx = x2 - this.x
                    set dy = y2 - this.y
                    set newAngle = Atan2(dy, dx)
                    set this.angle = newAngle
                    set dxy = SquareRoot(dx*dx + dy*dy)
                    if dxy < BREAK_DISTANCE then
                        if dxy > this.range then
                            set x2 = this.x + this.range*Cos(newAngle)
                            set y2 = this.y + this.range*Sin(newAngle)
                            call SetUnitX(this.target, x2)
                            call SetUnitY(this.target, y2)
                            call this.chainHead.updateHead(this.x, this.y, x2, y2, newAngle, this.range)
                        else
                            call this.chainHead.updateHead(this.x, this.y, x2, y2, newAngle, dxy)
                        endif
                    else
                        call this.destroy()
                    endif
                else
                    call this.destroy()
                endif
                set this = this.next
            endloop
        endmethod

        private static method onDamage takes nothing returns nothing
            if GetUnitTypeId(Damage.target) == UNIT_ID then
                set Damage.amount = 1.0
                call Damage.lockAmount()
            endif
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            local unit caster = GetTriggerUnit()
            local integer lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            local real x1 = GetUnitX(caster)
            local real y1 = GetUnitY(caster)
            local real x2
            local real y2
            set this.target = GetSpellTargetUnit()
            set x2 = GetUnitX(this.target)
            set y2 = GetUnitY(this.target)
            set this.angle = Atan2(y2 - y1, x2 - x1)
            set this.x = x2 - SUMMON_OFFSET*Cos(this.angle)
            set this.y = y2 - SUMMON_OFFSET*Sin(this.angle)
            set this.chainHead = Chain.head(x2, y2, this.angle)
            set this.range = Range(lvl)
            set this.device = CreateUnit(GetTriggerPlayer(), UNIT_ID, this.x, this.y, 0)
            call UnitApplyTimedLife(this.device, 'BTLF', Duration(lvl))
            call SetUnitMaxState(this.device, UNIT_STATE_MAX_LIFE, DeviceHP(lvl))
            set this.l = Lightning.createUnits("MCLI", this.device, this.target)
            set this.b = SpellBuff.add(caster, this.target)
            set thistype.tb[GetHandleId(this.device)] = this
            call this.push(TIMEOUT)
            call DestroyEffect(AddSpecialEffect(SFX_APPEAR, this.x, this.y))
            set caster = null
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            set thistype.tb = Table.create()
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call Damage.registerModifier(function thistype.onDamage)
            call PreloadUnit(UNIT_ID)
            call SpellBuff.initialize()
            call SystemTest.end()
        endmethod

    endstruct

endscope