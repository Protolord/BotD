scope MotionController

    globals
        private constant integer SPELL_ID = 'AH64'
        private constant integer UNIT_ID = 'hMCo'
        private constant string SFX_APPEAR = "Models\\Effects\\MotionControllerEntrance.mdx"
        private constant real SUMMON_OFFSET = 100.0
        private constant real TIMEOUT = 0.03125
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

    struct MotionController extends array
        implement Alloc
        implement List

        private real x
        private real y
        private unit target
        private real angle
        private real range
        private unit device
        private Lightning l
        private SpellBuff b

        private static Table tb

        private method destroy takes nothing returns nothing
            call this.pop()
            call this.b.remove()
            call this.l.destroy()
            call thistype.tb.remove(GetHandleId(this.device))
            if UnitAlive(this.device) then
                call KillUnit(this.device)
            endif
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