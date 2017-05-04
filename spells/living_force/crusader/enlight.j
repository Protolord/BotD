scope Enlight

    globals
        private constant integer SPELL_ID = 'AH22'
        private constant string SFX = "Abilities\\Spells\\Human\\HolyBolt\\HolyBoltSpecialArt.mdl"
        private constant string SFX_BUFF = "Abilities\\Spells\\Items\\StaffOfSanctuary\\Staff_Sanctuary_Target.mdl"
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
    endglobals

    private function BaseDamage takes integer level returns real
        return 25.0 + 0.0*level
    endfunction

    private function ExtraDamage takes integer level returns real
        return 25.0 + 0.0*level
    endfunction

    private function Manacost takes integer level returns real
        if level == 11 then
            return 300.0
        endif
        return 20.0*level
    endfunction

    private function Duration takes integer level returns real
        if level == 11 then
            return 6.0
        endif
        return 0.3*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and IsUnitType(u, UNIT_TYPE_HERO)
    endfunction

    private struct SpellBuff extends Buff

        private effect sfx

        private static constant integer RAWCODE = 'DH22'
        private static constant integer DISPEL_TYPE = BUFF_NEGATIVE
        private static constant integer STACK_TYPE = BUFF_STACK_NONE

        method onRemove takes nothing returns nothing
            call DestroyEffect(this.sfx)
            set this.sfx = null
        endmethod

        method onApply takes nothing returns nothing
            set this.sfx = AddSpecialEffectTarget(SFX_BUFF, this.target, "chest")
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod

        implement BuffApply
    endstruct

    struct Enlight extends array
        implement Alloc

        private integer run
        private boolean hasMana
        private trigger manaTrg

        private static Table tb

        private static method onDamage takes nothing returns boolean
            local integer level = GetUnitAbilityLevel(Damage.source, SPELL_ID)
            local thistype this = thistype.tb[GetHandleId(Damage.source)]
            local SpellBuff b
            local player p
            if this > 0 and level > 0 and Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.coded and this.run > 0 and this.hasMana then
                set p = GetOwningPlayer(Damage.source)
                if TargetFilter(Damage.target, p) then
                    set b = Buff.get(null, Damage.target, SpellBuff.typeid)
                    if b > 0 then
                        call Damage.element.apply(Damage.source, Damage.target, BaseDamage(level) + b.duration*ExtraDamage(level), ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_FIRE)
                        set b.duration = b.duration + Duration(level)
                    else
                        call Damage.element.apply(Damage.source, Damage.target, BaseDamage(level), ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_FIRE)
                        set SpellBuff.add(Damage.source, Damage.target).duration = Duration(level)
                    endif
                endif
                set p = null
            endif
            return false
        endmethod

        private static method castDelay takes nothing returns nothing
            local thistype this = ReleaseTimer(GetExpiredTimer())
            set this.run = this.run - 1
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.tb[GetHandleId(GetTriggerUnit())]
            set this.run = this.run + 1
            call TimerStart(NewTimerEx(this), 0.01, false, function thistype.castDelay) //Because of missile delay
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod

        private static method onOrder takes nothing returns boolean
            local integer order = GetIssuedOrderId()
            local thistype this = thistype.tb[GetHandleId(GetTriggerUnit())]
            if order == ORDER_flamingarrows then
                set this.run = this.run + 1
            elseif order == ORDER_unflamingarrows then
                set this.run = this.run - 1
            endif
            return false
        endmethod

        private static method manaDelay takes nothing returns nothing
            local thistype this = ReleaseTimer(GetExpiredTimer())
            set this.hasMana = not this.hasMana
        endmethod

        private static method onMana takes nothing returns boolean
            local unit u = GetTriggerUnit()
            local thistype this = thistype.tb[GetHandleId(u)]
            call DestroyTrigger(this.manaTrg)
            set this.manaTrg = CreateTrigger()
            if this.hasMana then
                call TriggerRegisterUnitStateEvent(this.manaTrg, u, UNIT_STATE_MANA, GREATER_THAN_OR_EQUAL, Manacost(GetUnitAbilityLevel(u, SPELL_ID)))
            else
                call TriggerRegisterUnitStateEvent(this.manaTrg, u, UNIT_STATE_MANA, LESS_THAN, Manacost(GetUnitAbilityLevel(u, SPELL_ID)))
            endif
            call TriggerAddCondition(this.manaTrg, function thistype.onMana)
            call TimerStart(NewTimerEx(this), 0.01, false, function thistype.manaDelay)
            return false
        endmethod

        private static method onLevel takes nothing returns nothing
            local unit u
            local thistype this
            local integer lvl
            if GetLearnedSkill() == SPELL_ID then
                set u = GetTriggerUnit()
                set this = thistype.tb[GetHandleId(u)]
                set lvl = GetUnitAbilityLevel(u, SPELL_ID)
                if this.manaTrg != null then
                    call DestroyTrigger(this.manaTrg)
                endif
                set this.manaTrg = CreateTrigger()
                if GetUnitState(u, UNIT_STATE_MANA) >= Manacost(lvl) then
                    set this.hasMana = true
                    call TriggerRegisterUnitStateEvent(this.manaTrg, u, UNIT_STATE_MANA, LESS_THAN, Manacost(lvl))
                else
                    set this.hasMana = false
                    call TriggerRegisterUnitStateEvent(this.manaTrg, u, UNIT_STATE_MANA, GREATER_THAN_OR_EQUAL, Manacost(lvl))
                endif
                call TriggerAddCondition(this.manaTrg, function thistype.onMana)
                set u = null
            endif
        endmethod

        static method register takes unit u returns nothing
            local thistype this = thistype.allocate()
            local trigger orderTrg = CreateTrigger()
            set this.run = 0
            set this.manaTrg = null
            call TriggerRegisterUnitEvent(orderTrg, u, EVENT_UNIT_ISSUED_ORDER)
            call TriggerAddCondition(orderTrg, function thistype.onOrder)
            set thistype.tb[GetHandleId(u)] = this
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            set thistype.tb = Table.create()
            call Damage.registerModifier(function thistype.onDamage)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_SKILL, function thistype.onLevel)
            call thistype.register(PlayerStat.initializer.unit)
            call SpellBuff.initialize()
            call SystemTest.end()
        endmethod

    endstruct

endscope