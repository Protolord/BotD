scope FieryDust

    globals
        private constant integer SPELL_ID = 'AHM4'
        private constant integer BUFF_ID = 'BHM4'
        private constant real TIMEOUT = 0.25
        private constant real MIN_RANGE = 100 //Range that will deal max damage
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
        private constant string SFX = "Abilities\\Spells\\Items\\AIfb\\AIfbSpecialArt.mdl"
    endglobals

    //When unit is at this range, the damage is minimum
    //Units farther than this range takes no dmg
    private function Range takes integer level returns real
        return 0.0*level + 200.0
    endfunction

    //In percent
    private function HealthPercentDamage_Max takes integer level returns real
        return 3.0*level
    endfunction

    //In percent
    private function HealthPercentDamage_Min takes integer level returns real
        return 1.5*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction

    struct FieryDust extends array
        implement Alloc

        private unit u
        private real range
        private real maxDmg
        private real minDmg
        private real m

        private static Table tb
        private static group g

        private static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            local player p
            local real x
            local real y
            local real dx
            local real dy
            local real d
            local real dmg
            local unit u
            if UnitAlive(this.u) then
                set x = GetUnitX(this.u)
                set y = GetUnitY(this.u)
                set p = GetOwningPlayer(this.u)
                call GroupEnumUnitsInRange(thistype.g, x, y, this.range, null)
                call FloatingText.setSplatProperties(TIMEOUT)
                loop
                    set u = FirstOfGroup(thistype.g)
                    exitwhen u == null
                    call GroupRemoveUnit(thistype.g, u)
                    if TargetFilter(u, p) then
                        set dx = x - GetUnitX(u)
                        set dy = y - GetUnitY(u)
                        set d = SquareRoot(dx*dx + dy*dy)
                        if d <= MIN_RANGE then
                            set dmg = this.maxDmg
                        else
                            set dmg = this.maxDmg - this.m*(d - MIN_RANGE)
                        endif
                        call Damage.element.apply(this.u, u, 0.01*dmg*GetUnitState(u, UNIT_STATE_MAX_LIFE), ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_FIRE)
                        call DestroyEffect(AddSpecialEffectTarget(SFX, u, "chest"))
                    endif
                endloop
                call FloatingText.resetSplatProperties()
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
                    set thistype.tb[id] = this
                    call TimerStart(NewTimerEx(this), TIMEOUT, true, function thistype.onPeriod)
                    call UnitAddAbility(u, BUFF_ID)
                    call UnitMakeAbilityPermanent(u, true, BUFF_ID)
                else
                    set this = thistype.tb[id]
                endif
                set lvl = GetUnitAbilityLevel(u, SPELL_ID)
                set this.range = Range(lvl)
                set this.maxDmg = HealthPercentDamage_Max(lvl)*TIMEOUT
                set this.minDmg = HealthPercentDamage_Min(lvl)*TIMEOUT
                set this.m = (this.maxDmg - this.minDmg)/(this.range - MIN_RANGE)
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