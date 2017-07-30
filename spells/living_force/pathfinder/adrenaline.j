scope Adrenaline

    globals
        private constant integer SPELL_ID = 'AHN1'
        private constant real TIMEOUT = 0.2
    endglobals

    private function Range takes integer level returns real
        return 100.0*level
    endfunction

    private function MoveSpeed takes integer level returns real
        return 0.05*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and IsUnitType(u, UNIT_TYPE_UNDEAD) and IsUnitType(u, UNIT_TYPE_HERO) and IsUnitVisible(u, p)
    endfunction

    private struct SpellBuff extends Buff

        private Movespeed ms

        private static constant integer RAWCODE = 'BHN1'
        private static constant integer DISPEL_TYPE = BUFF_POSITIVE
        private static constant integer STACK_TYPE = BUFF_STACK_NONE

        method onRemove takes nothing returns nothing
            call this.ms.destroy()
        endmethod

        method onApply takes nothing returns nothing
            set this.ms = Movespeed.create(this.target, 0, 0)
        endmethod

        method reapply takes real moveSlow returns nothing
            call this.ms.change(moveSlow, 0)
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod

        implement BuffApply
    endstruct

    struct Adrenaline extends array
        implement Alloc

        private unit u
        private real range
        private real ms
        private boolean hasBonus
        private SpellBuff b

        private static Table tb
        private static group g

        private static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            local boolean b = false
            local player p
            local real x
            local real y
            local unit u
            if UnitAlive(this.u) then
                set x = GetUnitX(this.u)
                set y = GetUnitY(this.u)
                set p = GetOwningPlayer(this.u)
                call GroupEnumUnitsInRange(thistype.g, x, y, this.range, null)
                loop
                    set u = FirstOfGroup(thistype.g)
                    exitwhen u == null
                    call GroupRemoveUnit(thistype.g, u)
                    if TargetFilter(u, p) then
                        set b = true
                        if this.hasBonus then
                            set u = null
                            exitwhen true
                        else
                            set this.hasBonus = true
                            set this.b = SpellBuff.add(this.u, this.u)
                            call this.b.reapply(this.ms)
                            set u = null
                            exitwhen true
                        endif
                    endif
                endloop
                if this.hasBonus and not b then
                    set this.hasBonus = false
                    call this.b.remove()
                endif
                set p = null
            endif
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
                    set this.hasBonus = false
                    set thistype.tb[id] = this
                    call TimerStart(NewTimerEx(this), TIMEOUT, true, function thistype.onPeriod)
                else
                    set this = thistype.tb[id]
                endif
                set lvl = GetUnitAbilityLevel(u, SPELL_ID)
                set this.range = Range(lvl)
                set this.ms = MoveSpeed(lvl)
                if this.hasBonus then
                    call this.b.reapply(this.ms)
                endif
                set u = null
            endif
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call SpellBuff.initialize()
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_SKILL, function thistype.learn)
            set thistype.tb = Table.create()
            set thistype.g = CreateGroup()
            call SystemTest.end()
        endmethod

    endstruct

endscope