scope UpliftPurpose

    globals
        private constant integer SPELL_ID = 'A621'
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_SIEGE
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_NORMAL
    endglobals

    private function HPSacrifice takes integer level returns real
        if level == 11 then
            return 0.20
        endif
        return 0.01*level
    endfunction

    private function Duration takes integer level returns real
        return 0.0*level + 10
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p)
    endfunction

    private struct SpellBuff extends Buff

        public real dmg

        private static constant integer RAWCODE = 'B621'
        private static constant integer DISPEL_TYPE = BUFF_NEGATIVE
        private static constant integer STACK_TYPE = BUFF_STACK_FULL

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod

        implement BuffApply
    endstruct

    struct UpliftPurpose extends array
        implement Alloc

        private unit u

        private static trigger trg

        private static method onDamage takes nothing returns boolean
            local SpellBuff b
            if Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.coded and Buff.has(Damage.source, Damage.source, SpellBuff.typeid) and TargetFilter(Damage.target, GetOwningPlayer(Damage.source)) then
                set b = Buff.get(Damage.source, Damage.source, SpellBuff.typeid)
                if b > 0 then
                    call DisableTrigger(thistype.trg)
                    call UnitDamageTarget(Damage.source, Damage.target, b.dmg, true, false, ATTACK_TYPE, DAMAGE_TYPE, null)
                    call FloatingTextSplat(Element.string(DAMAGE_ELEMENT_EARTH) + "+" + I2S(R2I(b.dmg + 0.5)) + "|r", Damage.target, 1.0).setVisible(GetLocalPlayer() == GetOwningPlayer(Damage.source))
                    call EnableTrigger(thistype.trg)
                    call b.remove()
                endif
            endif
            return false
        endmethod

        private static method expires takes nothing returns nothing
            local thistype this = ReleaseTimer(GetExpiredTimer())
            call UnitRemoveAbility(this.u, 'Bbsk')
            set this.u = null
            call this.deallocate()
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            local unit caster = GetTriggerUnit()
            local integer lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            local real bonus = HPSacrifice(lvl)*GetUnitState(caster, UNIT_STATE_MAX_LIFE)
            local real hp = GetWidgetLife(caster)
            local SpellBuff b
            if hp > bonus then
                call SetWidgetLife(caster, hp - bonus)
                set b = SpellBuff.add(caster, caster)
                set b.duration = Duration(lvl)
                set b.dmg = bonus
            else
                call Damage.kill(caster, caster)
            endif
            set this.u = caster
            set caster = null
            call TimerStart(NewTimerEx(this), 0.00, false, function thistype.expires)
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            set thistype.trg = CreateTrigger()
            call Damage.registerTrigger(thistype.trg)
            call TriggerAddCondition(thistype.trg, function thistype.onDamage)
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SpellBuff.initialize()
            call SystemTest.end()
        endmethod

    endstruct
endscope
