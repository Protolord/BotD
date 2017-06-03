scope UnholyEnergy

    globals
        private constant integer SPELL_ID = 'A742'
        private constant integer BUFF_ID = 'B742'
        private constant real TIMEOUT = 0.1
        private constant real MIN_RANGE = 250 //Range that will deal max damage
        private constant string SFX_EXTRA = "Abilities\\Spells\\Other\\Drain\\DrainTarget.mdl"
        private constant integer EXTRA_THRESHOLD = 10
    endglobals

    private function Range takes integer level returns real
        if level == 11 then
            return 500.0
        endif
        return 250 + 20.0*level
    endfunction

    private function BonusRegenPerUnit takes integer level returns real
        if level == 11 then
            return 75.0
        endif
        return 50.0
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction

    struct UnholyEnergy extends array
        implement Alloc

        private unit u
        private real factor
        private real range
        private effect sfxExtra

        private static Table tb
        private static group g

        private static method onPeriod takes nothing returns nothing
            local thistype this = thistype.top
            local player p
            local unit u
            local integer i
            loop
                exitwhen this == 0
                if UnitAlive(this.u) then
                    set p = GetOwningPlayer(this.u)
                    set i = 0
                    call GroupEnumUnitsInRange(thistype.g, GetUnitX(this.u), GetUnitY(this.u), this.range, null)
                    loop
                        set u = FirstOfGroup(thistype.g)
                        exitwhen u == null
                        call GroupRemoveUnit(thistype.g, u)
                        if TargetFilter(u, p) then
                            set i = i + 1
                        endif
                    endloop
                    if i >= EXTRA_THRESHOLD and this.sfxExtra == null then
                        set this.sfxExtra = AddSpecialEffectTarget(SFX_EXTRA, this.u, "overhead")
                    elseif i < EXTRA_THRESHOLD and this.sfxExtra != null then
                        call DestroyEffect(this.sfxExtra)
                        set this.sfxExtra = null
                    endif
                    call Heal.unit(this.u, this.u, i*this.factor, 4.0, false)
                endif
                set this = this.next
            endloop
        endmethod

        implement Stack

        private static method ultimates takes nothing returns boolean
            local unit u = GetTriggerUnit()
            local integer id = GetHandleId(u)
            local thistype this
            if thistype.tb.has(id) then
                set this = thistype.tb[id]
                set this.range = Range(11)
                set this.factor = BonusRegenPerUnit(11)*TIMEOUT
            endif
            set u = null
            return false
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
                    set thistype.tb[id] = this
                    call this.push(TIMEOUT)
                    call UnitAddAbility(u, BUFF_ID)
                    call UnitMakeAbilityPermanent(u, true, BUFF_ID)
                else
                    set this = thistype.tb[id]
                endif
                set lvl = GetUnitAbilityLevel(u, SPELL_ID)
                set this.range = Range(lvl)
                set this.factor = BonusRegenPerUnit(lvl)*TIMEOUT
                set u = null
            endif
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_SKILL, function thistype.learn)
            call PlayerStat.ultimateEvent(function thistype.ultimates)
            set thistype.tb = Table.create()
            set thistype.g = CreateGroup()
            call SystemTest.end()
        endmethod

    endstruct

endscope