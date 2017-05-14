scope ChainLightning

    globals
        private constant integer SPELL_ID = 'AH12'
        private constant string SFX = "Abilities\\Spells\\Items\\AIlb\\AIlbSpecialArt.mdl"
        private constant string LIGHTNING_CODE = "CLPB"
        private constant string LIGHTNING_CODE2 = "CLSB"
        private constant real LIGHTNING_DURATION = 0.8
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
        private constant real BOUNCE_DELAY = 0.2
    endglobals

    private function DamageDealt takes integer level returns real
        if level == 11 then
            return 1400.0
        endif
        return 70.0*level
    endfunction

    private function NumberOfBounces takes integer level returns integer
        return 2 + 0*level
    endfunction

    private function BounceRange takes integer level returns real
        return 500.0 + 0.0*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction

    struct ChainLightning extends array
        implement Alloc

        private unit caster
        private unit target
        private player owner
        private group affected
        private real dmg
        private real radius
        private integer bounces
        private timer t

        private static group g

        private method destroy takes nothing returns nothing
            call ReleaseGroup(this.affected)
            call ReleaseTimer(this.t)
            set this.t = null
            set this.affected = null
            set this.caster = null
            set this.target = null
            call this.deallocate()
        endmethod

        private method applyDamage takes string codeName, unit source returns nothing
            local Lightning l = Lightning.createUnits(codeName, source, this.target)
            set l.duration = LIGHTNING_DURATION
            call l.startColor(1.0, 1.0, 1.0, 1.0)
            call l.endColor(1.0, 1.0, 1.0, 0.1)
            call Damage.element.apply(this.caster, this.target, this.dmg, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_ELECTRIC)
            call GroupAddUnit(this.affected, this.target)
            call DestroyEffect(AddSpecialEffectTarget(SFX, this.target, "origin"))
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            local unit source = this.target
            local real minDistance = 2*this.radius*this.radius
            local unit newTarget = null
            local real x = GetUnitX(this.target)
            local real y = GetUnitY(this.target)
            local real tempDistance
            local real dx
            local real dy
            local unit u
            if this.bounces > 0 then
                call GroupEnumUnitsInRange(thistype.g, x, y, this.radius, null)
                loop
                    set u = FirstOfGroup(thistype.g)
                    exitwhen u == null
                    call GroupRemoveUnit(thistype.g, u)
                    //Find closest unit
                    if not IsUnitInGroup(u, this.affected) and TargetFilter(u, this.owner) then
                        set dx = GetUnitX(u) - x
                        set dy = GetUnitY(u) - y
                        set tempDistance = SquareRoot(dx*dx + dy*dy)
                        if tempDistance <= minDistance then
                            set newTarget = u
                            set minDistance = tempDistance
                        endif
                    endif
                endloop
                if newTarget == null then
                    call this.destroy()
                else
                    set this.target = newTarget
                    call this.applyDamage(LIGHTNING_CODE2, source)
                    set this.bounces = this.bounces - 1
                    set newTarget = null
                endif
            else
                call this.destroy()
            endif
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            local integer lvl
            set this.caster = GetTriggerUnit()
            set this.target = GetSpellTargetUnit()
            set this.owner = GetTriggerPlayer()
            set lvl = GetUnitAbilityLevel(this.caster, SPELL_ID)
            set this.affected = NewGroup()
            set this.bounces = NumberOfBounces(lvl)
            set this.dmg = DamageDealt(lvl)
            set this.radius = BounceRange(lvl)
            set this.t = NewTimerEx(this)
            call this.applyDamage(LIGHTNING_CODE, this.caster)
            call TimerStart(this.t, BOUNCE_DELAY, true, function thistype.onPeriod)
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            set thistype.g = CreateGroup()
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SystemTest.end()
        endmethod

    endstruct

endscope