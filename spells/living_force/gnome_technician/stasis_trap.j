scope StasisTrap

    globals
        private constant integer SPELL_ID = 'AH61'
        private constant integer UNIT_ID = 'hSta'
        private constant string SFX_SLOW = "Abilities\\Spells\\Orc\\StasisTrap\\StasisTotemTarget.mdl"
        private constant real TIMEOUT = 0.05
    endglobals

    private function UnitHP takes integer level returns real
        return 100.0 + 0.0*level
    endfunction

    private function TriggerRadius takes integer level returns real
        return 200.0 + 0.0*level
    endfunction

    private function DetonateRadius takes integer level returns real
        return 400.0 + 0.0*level
    endfunction

    private function MoveSlow takes integer level returns real
        return 0.5 + 0.0*level
    endfunction

    private function AtkSlow takes integer level returns real
        return 0.5 + 0.0*level
    endfunction

    private function SlowDuration takes integer level returns real
        return 0.5*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE) and not IsUnitType(u, UNIT_TYPE_STRUCTURE)
    endfunction

    private function TriggerTargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p)
    endfunction

    private struct SpellBuff extends Buff

        private Atkspeed as
        private Movespeed ms
        private effect sfx

        private static constant integer RAWCODE = 'DH61'
        private static constant integer DISPEL_TYPE = BUFF_NEGATIVE
        private static constant integer STACK_TYPE = BUFF_STACK_PARTIAL

        method onRemove takes nothing returns nothing
            call DestroyEffect(this.sfx)
            call this.as.destroy()
            call this.ms.destroy()
            set this.sfx = null
        endmethod

        method onApply takes nothing returns nothing
            set this.sfx = AddSpecialEffectTarget(SFX_SLOW, this.target, "overhead")
            set this.ms = Movespeed.create(this.target, 0, 0)
            set this.as = Atkspeed.create(this.target, 0)
        endmethod

        method reapply takes real moveSlow, real atkSlow returns nothing
            call this.ms.change(moveSlow, 0)
            call this.as.change(atkSlow)
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod

        implement BuffApply
    endstruct

    struct StasisTrap extends array
        implement Alloc
        implement List

        private unit trap
        private player p
        private integer lvl
        private real triggerRadius
        private real detonateRadius

        private static group g
        private static group g2

        private method destroy takes nothing returns nothing
            call this.pop()
            set this.trap = null
            set this.p = null
            call this.deallocate()
        endmethod

        private method detonate takes nothing returns nothing
            local real moveSlow = -MoveSlow(this.lvl)
            local real atkSlow = -AtkSlow(this.lvl)
            local real slowDuration = SlowDuration(this.lvl)
            local SpellBuff b
            local unit u
            call GroupUnitsInArea(thistype.g2, GetUnitX(this.trap), GetUnitY(this.trap), this.detonateRadius)
            loop
                set u = FirstOfGroup(thistype.g2)
                exitwhen u == null
                call GroupRemoveUnit(thistype.g2, u)
                if TargetFilter(u, this.p) then
                    set b = SpellBuff.add(this.trap, u)
                    call b.reapply(moveSlow, atkSlow)
                    set b.duration = slowDuration
                endif
            endloop
            call KillUnit(this.trap)
            call this.destroy()
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this = thistype(0).next
            local unit u
            loop
                exitwhen this == 0
                if UnitAlive(this.trap) then
                    call GroupEnumUnitsInRange(thistype.g, GetUnitX(this.trap), GetUnitY(this.trap), this.triggerRadius, null)
                    loop
                        set u = FirstOfGroup(thistype.g)
                        exitwhen u == null
                        call GroupRemoveUnit(thistype.g, u)
                        if TriggerTargetFilter(u, this.p) then
                            call this.detonate()
                            set u = null
                            exitwhen true
                        endif
                    endloop
                else
                    call this.destroy()
                endif
                set this = this.next
            endloop
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            local unit caster = GetTriggerUnit()
            local real x = GetSpellTargetX()
            local real y = GetSpellTargetY()
            set this.p = GetTriggerPlayer()
            set this.trap = CreateUnit(this.p, UNIT_ID, x, y, 0)
            set this.lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            call SetUnitMaxState(this.trap, UNIT_STATE_MAX_LIFE, UnitHP(this.lvl))
            set this.triggerRadius = TriggerRadius(this.lvl)
            set this.detonateRadius = DetonateRadius(this.lvl)
            call this.push(TIMEOUT)
            set caster = null
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call PreloadUnit(UNIT_ID)
            call SpellBuff.initialize()
            set thistype.g = CreateGroup()
            set thistype.g2 = CreateGroup()
            call SystemTest.end()
        endmethod

    endstruct

endscope