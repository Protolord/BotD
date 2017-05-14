scope Totem

    globals
        private constant integer SPELL_ID = 'A841'
        private constant integer UNIT_ID = 'uTot'
        private constant real MIN_RANGE = 250 //Range that will deal max healing
        private constant string HEAL_SFX = "Abilities\\Spells\\Human\\Heal\\HealTarget.mdl"
        private constant real TIMEOUT = 1.0
    endglobals

    //When unit is at this range, the healing is minimum
    //Units farther than this range takes no healing
    private function Range takes integer level returns real
        return 0.0*level + 2500.0
    endfunction

    //When unit is within MIN_RANGE, that unit will get healed by HealPerSecond_Max
    private function HealPerSecond_Max takes integer level returns real
        if level == 11 then
            return 400.0
        endif
        return 100.0 + 10.0*level
    endfunction

    //Minimum healing experience by units within range
    private function HealPerSecond_Min takes integer level returns real
        if level == 11 then
            return 40.0
        endif
        return 10.0 + 1.0*level
    endfunction

    private function HP takes integer level returns real
        if level == 11 then
            return 20.0
        endif
        return 10.0 + 1.0*level
    endfunction

    private function Duration takes integer level returns real
        return 60 + 0.0*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitAlly(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and GetUnitTypeId(u) != UNIT_ID
    endfunction

    struct Totem extends array
        implement Alloc

        private unit caster
        private player owner
        private unit totem
        private real x
        private real y
        private real range
        private real duration
        private timer t

        private real maxHeal
        private real minHeal
        private real m

        private static group g

        private method destroy takes nothing returns nothing
            call ReleaseTimer(this.t)
            set this.totem = null
            set this.caster = null
            set this.owner = null
            set this.t = null
            call this.deallocate()
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            local real heal
            local real d
            local unit u
            local real dx
            local real dy
            if UnitAlive(this.totem) then
                call GroupEnumUnitsInRange(thistype.g, this.x, this.y, this.range + MAX_COLLISION_SIZE, null)
                loop
                    set u = FirstOfGroup(thistype.g)
                    exitwhen u == null
                    call GroupRemoveUnit(thistype.g, u)
                    if IsUnitInRangeXY(u, this.x, this.y, this.range) and TargetFilter(u, this.owner) then
                        set dx = this.x - GetUnitX(u)
                        set dy = this.y - GetUnitY(u)
                        set d = SquareRoot(dx*dx + dy*dy)
                        if d <= MIN_RANGE then
                            set heal = this.maxHeal
                        else
                            set heal = this.maxHeal - this.m*(d - MIN_RANGE)
                        endif
                        call Heal.unit(this.caster, u, heal, 4.0, true)
                        call AddSpecialEffectTimer(AddSpecialEffectTarget(HEAL_SFX, u, "chest"), 3.0)
                    endif
                endloop
            else
                call this.destroy()
            endif
        endmethod

        private static method onDamage takes nothing returns nothing
            if GetUnitTypeId(Damage.target) == UNIT_ID then
                set Damage.amount = 1.0
                call Damage.lockAmount()
            endif
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            local integer lvl
            set this.caster = GetTriggerUnit()
            set lvl = GetUnitAbilityLevel(this.caster, SPELL_ID)
            set this.owner = GetTriggerPlayer()
            set this.x = GetSpellTargetX()
            set this.y = GetSpellTargetY()
            set this.totem = CreateUnit(this.owner, UNIT_ID, this.x, this.y, 0)
            set this.range = Range(lvl)
            set this.maxHeal = HealPerSecond_Max(lvl)*TIMEOUT
            set this.minHeal = HealPerSecond_Min(lvl)*TIMEOUT
            call SetUnitMaxState(this.totem, UNIT_STATE_MAX_LIFE, HP(lvl))
            set this.m = (this.maxHeal - this.minHeal)/(this.range - MIN_RANGE)
            set this.t = NewTimerEx(this)
            call UnitApplyTimedLife(this.totem, 'BTLF', Duration(lvl))
            call TimerStart(this.t, TIMEOUT, true, function thistype.onPeriod)
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call Damage.registerModifier(function thistype.onDamage)
            set thistype.g = CreateGroup()
            call PreloadUnit(UNIT_ID)
            call SystemTest.end()
        endmethod

    endstruct

endscope