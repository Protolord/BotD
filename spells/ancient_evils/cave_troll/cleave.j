scope Cleave

    globals
        private constant integer SPELL_ID = 'A8XX'
        private constant real MAX_RANGE = 200.0
        private constant real MIN_RANGE = 100.0
        private constant real MAX_PERCENT_DAMAGE = 50.0
        private constant real MIN_PERCENT_DAMAGE = 20.0
        private constant real ANGLE_RANGE = 120.0 //In degrees
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_SIEGE
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_NORMAL
        private constant string SFX = "Models\\Effects\\Cleave.mdx"
    endglobals


    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p)
    endfunction

    struct Cleave extends array

        private static group g
        private static trigger trg

        private static constant real RATE = -(MAX_PERCENT_DAMAGE - MIN_PERCENT_DAMAGE)/(MAX_RANGE - MIN_RANGE)

        private static method onDamage takes nothing returns boolean
            local integer level = GetUnitAbilityLevel(Damage.source, SPELL_ID)
            local player p = GetOwningPlayer(Damage.source)
            local real dmg
            local unit dummy
            local unit u
            local real x
            local real y
            local real x2
            local real y2
            local real dx
            local real dy
            local real angle
            local real d
            if Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.coded and level > 0 and TargetFilter(Damage.target, p) then
                set x = GetUnitX(Damage.source)
                set y = GetUnitY(Damage.source)
                set x2 = GetUnitX(Damage.target)
                set y2 = GetUnitY(Damage.target)
                set dmg = CombatStat.getDamage(Damage.source)*HeavySwing.get(Damage.source)
                set angle = Atan2(y2 - y, x2 - x)
                call GroupUnitsInArea(thistype.g, x2, y2, MAX_RANGE)
                call DisableTrigger(thistype.trg)
                loop
                    set u = FirstOfGroup(thistype.g)
                    exitwhen u == null
                    call GroupRemoveUnit(thistype.g, u)
                    if u != Damage.target and TargetFilter(u, p) then
                        set dx = GetUnitX(u) - x
                        set dy = GetUnitY(u) - y
                        //If within angle range
                        set d = SquareRoot(dy*dy + dx*dx)
                        if RAbsBJ(angle - Atan2(dy, dx)) <= ANGLE_RANGE*bj_DEGTORAD then
                            if d <= MIN_RANGE then
                                call Damage.apply(Damage.source, u, dmg*MAX_PERCENT_DAMAGE/100.0, ATTACK_TYPE, DAMAGE_TYPE)
                            else
                                call Damage.apply(Damage.source, u, (dmg*((d - MIN_RANGE)*RATE + MAX_PERCENT_DAMAGE))/100.0, ATTACK_TYPE, DAMAGE_TYPE)
                            endif
                        endif
                    endif
                endloop
                call EnableTrigger(thistype.trg)
                set dummy = GetRecycledDummy(x, y, 0, angle*bj_RADTODEG + 180)
                call DestroyEffect(AddSpecialEffectTarget(SFX, dummy, "origin"))
                call DummyAddRecycleTimer(dummy, 1.0)
                set dummy = null
            endif
            set p = null
            return false
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            set thistype.trg = CreateTrigger()
            set thistype.g = CreateGroup()
            call Damage.registerTrigger(thistype.trg)
            call TriggerAddCondition(thistype.trg, function thistype.onDamage)
            call SystemTest.end()
        endmethod

    endstruct

endscope