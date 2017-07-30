scope SpiritLink

    globals
        private constant integer SPELL_ID = 'AHF1'
        private constant string SFX = "Abilities\\Spells\\Orc\\SpiritLink\\SpiritLinkZapTarget.mdl"
        private constant string LIGHTNING_CODE = "SPLK"
        private constant string LIGHTNING_CODE2 = "SPL2"
        private constant real LIGHTNING_DURATION = 0.8
        private constant real LIGHTNING_DURATION2 = 0.2
        private constant real BOUNCE_DELAY = 0.1
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_CHAOS
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_UNIVERSAL
    endglobals

    private function NumberOfBounces takes integer level returns integer
        return 1 + R2I(0.5*level)
    endfunction

    private function BounceRange takes integer level returns real
        return 700.0 + 0.0*level
    endfunction

    private function Duration takes integer level returns real
        return 15.0 + 0.0*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitAlly(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE)
    endfunction

    private struct SpellBuff extends Buff

        private SpiritLink sl

        private static constant integer RAWCODE = 'BHF1'
        private static constant integer DISPEL_TYPE = BUFF_POSITIVE
        private static constant integer STACK_TYPE = BUFF_STACK_PARTIAL

        private static method delayedCheck takes nothing returns nothing
            call SpiritLink(ReleaseTimer(GetExpiredTimer())).updateAffected()
        endmethod

        method onRemove takes nothing returns nothing
            call TimerStart(NewTimerEx(this.sl), 0.01, false, function thistype.delayedCheck)
            set this.sl = 0
        endmethod

        method onApply takes nothing returns nothing
            set this.sl = SpiritLink.global
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod

        implement BuffApply
    endstruct

    struct SpiritLink extends array
        implement Alloc

        private unit caster
        private unit target
        private player owner
        private group affected
        private integer count
        private real radius
        private integer bounces
        private timer t
        private trigger trg
        private real dur

        private static group g
        private static Table tb
        readonly static thistype global
        private static unit tempSource
        private static unit tempTarget
        private static real tempDamage

        private method destroy takes nothing returns nothing
            local unit u
            local SpellBuff b
            call thistype.tb.remove(GetHandleId(this.trg))
            call thistype.tb.remove(GetHandleId(this.caster))
            loop
                set u = FirstOfGroup(this.affected)
                exitwhen u == null
                call GroupRemoveUnit(this.affected, u)
                set b = Buff.get(this.caster, u, SpellBuff.typeid)
                if b > 0 then
                    call b.remove()
                endif
            endloop
            call DestroyTrigger(this.trg)
            call ReleaseGroup(this.affected)
            set this.trg = null
            set this.affected = null
            set this.caster = null
            set this.target = null
            call this.deallocate()
        endmethod

        private static method picked takes nothing returns nothing
            local thistype this = thistype.global
            local unit u = GetEnumUnit()
            if not Buff.has(null, u, SpellBuff.typeid) then
                call GroupRemoveUnit(this.affected, u)
                set this.count = this.count - 1
                if this.count == 0 then
                    call this.destroy()
                endif
            endif
        endmethod

        method updateAffected takes nothing returns nothing
            if this.affected != null then
                set thistype.global = this
                call ForGroup(this.affected, function thistype.picked)
            endif
        endmethod

        private method apply takes string codeName, unit lightningSource, real time returns nothing
            local Lightning l
            local SpellBuff b
            set thistype.global = this
            set b = SpellBuff.add(this.caster, this.target)
            set b.duration = time
            if this.caster != this.target then
                set l = Lightning.createUnits(codeName, lightningSource, this.target)
                set l.duration = LIGHTNING_DURATION
                call l.startColor(1.0, 1.0, 1.0, 1.0)
                call l.endColor(1.0, 1.0, 1.0, 0.1)
            endif
            set this.count = this.count + 1
            call GroupAddUnit(this.affected, this.target)
            call AddSpecialEffectTimer(AddSpecialEffectTarget(SFX, this.target, "origin"), 1.25)
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            local real minDistance = 2*this.radius*this.radius
            local unit newTarget = null
            local unit lightningSource = this.target
            local real x = GetUnitX(this.target)
            local real y = GetUnitY(this.target)
            local real tempDistance
            local real dx
            local real dy
            local unit u
            if this.bounces > 0 then
                set this.dur = this.dur - BOUNCE_DELAY
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
                    set this.bounces = 0
                else
                    set this.target = newTarget
                    call this.apply(LIGHTNING_CODE, lightningSource, this.dur)
                    set this.bounces = this.bounces - 1
                    set newTarget = null
                endif
            else
                call ReleaseTimer(this.t)
                set this.t = null
            endif
        endmethod

        private static method pickedDamage takes nothing returns nothing
            local unit u = GetEnumUnit()
            local Lightning l
            if thistype.tempTarget != u then
                call Damage.apply(thistype.tempSource, u, thistype.tempDamage, ATTACK_TYPE, DAMAGE_TYPE)
                set l = Lightning.createUnits(LIGHTNING_CODE2, thistype.tempTarget, u)
                set l.duration = LIGHTNING_DURATION2
                call l.startColor(1.0, 1.0, 1.0, 1.0)
                call l.endColor(1.0, 1.0, 1.0, 0.1)
            endif
            set u = null
        endmethod

        private static method onDamage takes nothing returns boolean
            local thistype this = thistype.tb[GetHandleId(Damage.triggeringTrigger)]
            if this > 0 and IsUnitInGroup(Damage.target, this.affected) then
                call DisableTrigger(this.trg)
                set thistype.tempDamage = Damage.amount/this.count
                set Damage.amount = thistype.tempDamage
                set thistype.tempSource = Damage.source
                set thistype.tempTarget = Damage.target
                call ForGroup(this.affected, function thistype.pickedDamage)
                call EnableTrigger(this.trg)
            endif
            return false
        endmethod

        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local integer id = GetHandleId(caster)
            local thistype this
            local integer lvl
            if thistype.tb.has(id) then
                call thistype(thistype.tb[id]).destroy()
            endif
            set this = thistype.allocate()
            set this.caster = caster
            set this.owner = GetTriggerPlayer()
            set lvl = GetUnitAbilityLevel(this.caster, SPELL_ID)
            set this.affected = NewGroup()
            set this.bounces = NumberOfBounces(lvl)
            set this.radius = BounceRange(lvl)
            set this.dur = Duration(lvl)
            set this.count = 0
            set this.target = this.caster
            call this.apply(LIGHTNING_CODE, this.caster, this.dur)
            set this.target = GetSpellTargetUnit()
            call this.apply(LIGHTNING_CODE, this.caster, this.dur)
            set this.t = NewTimerEx(this)
            set this.trg = CreateTrigger()
            call Damage.registerModifierTrigger(this.trg)
            call TriggerAddCondition(this.trg, function thistype.onDamage)
            set thistype.tb[GetHandleId(this.trg)] = this
            set thistype.tb[id] = this
            call TimerStart(this.t, BOUNCE_DELAY, true, function thistype.onPeriod)
            call SystemMsg.create(GetUnitName(caster) + " cast thistype")
            set caster = null
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            set thistype.g = CreateGroup()
            set thistype.tb = Table.create()
            call SpellBuff.initialize()
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SystemTest.end()
        endmethod

    endstruct

endscope