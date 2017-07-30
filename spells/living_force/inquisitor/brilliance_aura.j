scope BrillanceAura

    globals
        private constant integer SPELL_ID   = 'AHA3'

        private constant integer BUFF_ID    = 'BHA3'

        private constant real TIMEOUT       = 0.25

        private constant real MIN_RANGE     = 0 //Range that will have max mana regen

        private constant string SFX         = "Models\\Effects\\BrillianceAura.mdx"
    endglobals

    //When unit is at this range, the damage is minimum
    //Units farther than this range takes no mana regeneration
    private function Range takes integer level returns real
        return 0.0*level + 900.0
    endfunction

    private function Regen_Max takes integer level returns real
        return 3.0*level
    endfunction

    private function Regen_Min takes integer level returns real
        return 0.0*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitAlly(u, p)
    endfunction

    struct BrillianceAura extends array
        implement Alloc

        private unit u
        private real range
        private real maxHeal
        private real minHeal
        private real m
        private effect sfx
        private group affected

        private static Table tb
        private static group g
        private static thistype global

        private static method picked takes nothing returns nothing
            local unit u = GetEnumUnit()
            if not IsUnitInRange(u, thistype.global.u, thistype.global.range) then
                call GroupRemoveUnit(thistype.global.affected, u)
                call UnitRemoveAbility(u, BUFF_ID)
                call UnitRemoveAbility(u, 'bHA3')
            endif
            set u = null
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            local player p
            local real x
            local real y
            local real dx
            local real dy
            local real d
            local real regen
            local unit u
            if UnitAlive(this.u) then
                set p = GetOwningPlayer(this.u)
                set x = GetUnitX(this.u)
                set y = GetUnitY(this.u)
                call GroupEnumUnitsInRange(thistype.g, x, y, this.range, null)
                loop
                    set u = FirstOfGroup(thistype.g)
                    exitwhen u == null
                    call GroupRemoveUnit(thistype.g, u)
                    if TargetFilter(u, p) then
                        set dx = x - GetUnitX(u)
                        set dy = y - GetUnitY(u)
                        set d = SquareRoot(dx*dx + dy*dy)
                        if d <= MIN_RANGE then
                            set regen = this.maxHeal
                        else
                            set regen = this.maxHeal - this.m*(d - MIN_RANGE)
                        endif
                        call SetUnitState(u, UNIT_STATE_MANA, GetUnitState(u, UNIT_STATE_MANA)+regen)
                        if not IsUnitInGroup(u, this.affected) then
                            call GroupAddUnit(this.affected, u)
                            call UnitAddAbility(u, BUFF_ID)
                        endif
                    endif
                endloop
                set thistype.global = this
                call ForGroup(this.affected, function thistype.picked)
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
                    set this.sfx = AddSpecialEffectTarget(SFX, u, "origin")
                    set this.affected = CreateGroup()
                    set thistype.tb[id] = this
                    call TimerStart(NewTimerEx(this), TIMEOUT, true, function thistype.onPeriod)
                    call UnitAddAbility(u, BUFF_ID)
                    call UnitMakeAbilityPermanent(u, true, BUFF_ID)
                else
                    set this = thistype.tb[id]
                endif
                set lvl = GetUnitAbilityLevel(u, SPELL_ID)
                set this.range = Range(lvl)
                set this.maxHeal = Regen_Max(lvl)
                set this.minHeal = Regen_Min(lvl)
                set this.m = (this.maxHeal - this.minHeal)/(this.range - MIN_RANGE)
                set u = null
            endif
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_SKILL, function thistype.learn)
            set thistype.tb = Table.create()
            set thistype.g = CreateGroup()
            call SystemTest.end()
        endmethod

    endstruct

endscope