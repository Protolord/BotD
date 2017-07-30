scope Companion

    globals
        private constant integer SPELL_ID = 'AH83'
        private constant real TIMEOUT = 0.5
        private constant real MAX_DISTANCE = 800.0
        private constant real ROAM_RADIUS = 400.0
        private constant integer OWL = 1
        private constant integer EAGLE = 2
        private constant integer FALCON = 3
        private integer array UNIT_ID
    endglobals

    //In Percent
    private function DamagePercent takes integer level returns real
        return 10.0*level
    endfunction

    //In Percent
    private function EagleCritChance takes integer level returns real
        return 25.0 + 0.0*level
    endfunction

    private function EagleCritMultiplier takes integer level returns real
        return 2.5 + 0.0*level
    endfunction

    //In Percent
    private function FalconPauseChance takes integer level returns real
        return 25.0 + 0.0*level
    endfunction

    struct Companion extends array
        implement Alloc

        private real dmg
        private unit caster
        private real proc
        private real m
        private integer id
        private unit u

        private static Table tb
        private static group g

        private method destroy takes nothing returns nothing
            set this.caster = null
            set this.u = null
            call this.deallocate()
        endmethod

        private static method onDamage takes nothing returns nothing
            local thistype this
            if Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.coded then
                if IsUnitInGroup(Damage.source, thistype.g) then
                    set this = GetHandleId(Damage.source)
                    set Damage.amount = this.dmg*Damage.amount
                    //Special abilities
                    if this.id == EAGLE then
                        if GetRandomReal(0, 100) <= this.proc then
                            set Damage.amount = Damage.amount*this.m
                        endif
                    elseif this.id == FALCON then
                        if GetRandomReal(0, 100) <= this.proc then
                            call IssueImmediateOrderById(Damage.target, ORDER_stop)
                        endif
                    endif
                endif
            endif
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this = thistype(0).next
            local real r
            local real a
            loop
                exitwhen this == 0
                if UnitAlive(this.u) then
                    set r = GetRandomReal(0, ROAM_RADIUS)
                    set a = GetRandomReal(-bj_PI, bj_PI)
                    if IsUnitInRange(this.u, this.caster, MAX_DISTANCE) then
                        if GetUnitCurrentOrder(this.u) == 0 then
                            call ForcedOrder.change(this.u, ORDER_attack, GetUnitX(this.caster) + r*Cos(a), GetUnitY(this.caster) + r*Sin(a))
                        endif
                    else
                        call ForcedOrder.change(this.u, ORDER_move, GetUnitX(this.caster) + r*Cos(a), GetUnitY(this.caster) + r*Sin(a))
                    endif
                else
                    call this.destroy()
                endif
                set this = this.next
            endloop
        endmethod

        implement List

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            local integer lvl
            local real r = GetRandomReal(100, 500)
            local real a = GetRandomReal(-bj_PI, bj_PI)
            set this.caster = GetTriggerUnit()
            set lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            set this.id = thistype.tb[GetHandleId(this.caster)]
            set this.dmg = 0.01*DamagePercent(lvl)
            set this.u = CreateUnit(GetTriggerPlayer(), UNIT_ID[id], GetUnitX(this.caster), GetUnitY(this.caster), GetUnitFacing(this.caster))
            if this.id == OWL then
                call TrueSight.create(this.u, 350)
            elseif this.id == EAGLE then
                set this.proc = EagleCritChance(lvl)
                set this.m = EagleCritMultiplier(lvl)
            elseif this.id == FALCON then
                set this.proc = FalconPauseChance(lvl)
            endif
            call GroupAddUnit(thistype.g, this.u)
            set thistype.tb[GetHandleId(this.u)] = this
            call ForcedOrder.create(this.u, ORDER_attack, GetUnitX(this.caster) + r*Cos(a), GetUnitY(this.caster) + r*Sin(a))
            //Make next summon different
            if this.id == FALCON then
                set thistype.tb[GetHandleId(this.caster)] = OWL
            else
                set thistype.tb[GetHandleId(this.caster)] = this.id + 1
            endif
            call this.push(TIMEOUT)
            call SystemMsg.create(GetUnitName(this.caster) + " cast thistype")
        endmethod

        private static method add takes unit u returns nothing
            set thistype.tb[GetHandleId(u)] = OWL
        endmethod

        private static method initUnits takes nothing returns nothing
            set UNIT_ID[OWL] = 'hOwl'
            set UNIT_ID[EAGLE] = 'hEag'
            set UNIT_ID[FALCON] = 'hFal'
            call PreloadUnit(UNIT_ID[OWL])
            call PreloadUnit(UNIT_ID[EAGLE])
            call PreloadUnit(UNIT_ID[FALCON])
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            set thistype.tb = Table.create()
            set thistype.g = CreateGroup()
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call thistype.add(PlayerStat.initializer.unit)
            call thistype.initUnits()
            call SystemTest.end()
        endmethod

    endstruct

endscope