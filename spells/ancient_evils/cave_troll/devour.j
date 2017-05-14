scope Devour

    globals
        private constant integer SPELL_ID = 'A842'
        private constant string BUFF_SFX = "Objects\\Spawnmodels\\Human\\HumanBlood\\BloodElfSpellThiefBlood.mdl"
        private constant real TIMEOUT = 1.0
        private constant real RANGE = 200.0
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
    endglobals

    private function HealPercent takes integer level returns real
        if level == 11 then
            return 20.0
        endif
        return 10.0
    endfunction

    private struct SpellBuff extends Buff

        private effect sfx
        private real ctr
        private real factor
        private Pause p

        private static constant integer RAWCODE = 'D842'
        private static constant integer DISPEL_TYPE = BUFF_NONE
        private static constant integer STACK_TYPE = BUFF_STACK_PARTIAL
        private static constant real PERIODIC = 0.1
        private static constant integer BUFF_RAWCODE = 'B842'

        method onRemove takes nothing returns nothing
            call this.pop()
            call IssueImmediateOrderById(this.source, ORDER_stop)
            call UnitRemoveAbility(this.source, BUFF_RAWCODE)
            call DestroyEffect(this.sfx)
            call this.p.destroy()
            set this.sfx = null
        endmethod

        private method eat takes nothing returns nothing
            local real amount = this.factor*GetUnitState(this.target, UNIT_STATE_MAX_LIFE)*TIMEOUT
            call Damage.element.apply(this.source, this.target, amount, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_NORMAL)
            call Heal.unit(this.source, this.source, amount, 1.0, true)
            call DestroyEffect(AddSpecialEffectTarget(BUFF_SFX, this.target, "chest"))
            call DestroyEffect(AddSpecialEffectTarget(BUFF_SFX, this.source, "chest"))
        endmethod

        static method onPeriod takes nothing returns nothing
            local thistype this = thistype(0).next
            loop
                exitwhen this == 0
                if IsUnitInRange(this.source, this.target, RANGE) and UnitAlive(this.target) and not IsUnitType(this.source, UNIT_TYPE_ETHEREAL) and not IsUnitType(this.target, UNIT_TYPE_ETHEREAL) then
                    set this.ctr = this.ctr + thistype.PERIODIC
                    if this.ctr > TIMEOUT then
                        set this.ctr = 0
                        call this.eat()
                    endif
                else
                    call IssueImmediateOrderById(this.source, ORDER_stop)
                endif
                set this = this.next
            endloop
        endmethod

        implement List

        method onApply takes nothing returns nothing
            set this.sfx = AddSpecialEffectTarget(BUFF_SFX, this.target, "overhead")
            set this.p = Pause.create(this.target)
            set this.ctr = 0
            set this.factor = HealPercent(GetUnitAbilityLevel(this.source, SPELL_ID))/100.0
            call UnitAddAbility(this.source, BUFF_RAWCODE)
            call this.eat()
            call this.push(thistype.PERIODIC)
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod

        implement BuffApply
    endstruct


    struct Devour extends array

        private static Table tb

        private static method onStop takes nothing returns nothing
            local integer id = GetHandleId(GetTriggerUnit())
            if thistype.tb.has(id) then
                call SpellBuff(thistype.tb[id]).remove()
            endif
        endmethod

        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local SpellBuff b = SpellBuff.add(caster, GetSpellTargetUnit())
            set thistype.tb[GetHandleId(caster)] = b
            set caster = null
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            set thistype.tb = Table.create()
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call RegisterSpellEndcastEvent(SPELL_ID, function thistype.onStop)
            call SpellBuff.initialize()
            call SystemTest.end()
        endmethod

    endstruct
endscope