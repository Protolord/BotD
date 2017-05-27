scope FrostArmor

    globals
        private constant integer SPELL_ID = 'AH43'
    endglobals

    //In Percent
    private function AttackSlow takes integer level returns real
        return 0.5 + 0*level
    endfunction

    private function MoveSlow takes integer level returns real
        return 0.5 + 0.0*level
    endfunction

    private function Duration takes integer level returns real
        return 20.0 + 0.0*level
    endfunction

    private function DebuffDuration takes integer level returns real
        return 0.5*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and CombatStat.isMelee(u) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction

    private struct SpellBuff extends Buff

        private VertexColor vc
        private Movespeed ms
        private Atkspeed as

        private static constant integer RAWCODE = 'DH43'
        private static constant integer DISPEL_TYPE = BUFF_NEGATIVE
        private static constant integer STACK_TYPE = BUFF_STACK_NONE

        method onRemove takes nothing returns nothing
            call this.ms.destroy()
            call this.as.destroy()
            call this.vc.destroy()
        endmethod

        method onApply takes nothing returns nothing
            set this.vc = VertexColor.create(this.target, -200, -50, 255, 0)
            set this.ms = Movespeed.create(this.target, 0, 0)
            set this.as = Atkspeed.create(this.target, 0)
            set this.vc.speed = 500
        endmethod

        method reapply takes integer lvl returns nothing
            call this.ms.change(-MoveSlow(lvl), 0)
            call this.as.change(-AttackSlow(lvl))
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod

        implement BuffApply
    endstruct

    private struct FrostArmorBuff extends Buff

        private integer lvl

        private static constant integer RAWCODE = 'BH43'
        private static constant integer DISPEL_TYPE = BUFF_POSITIVE
        private static constant integer STACK_TYPE = BUFF_STACK_NONE

        private static method onDamage takes nothing returns nothing
            local thistype this = Buff.get(null, Damage.target, thistype.typeid)
            local SpellBuff b
            if Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.coded and TargetFilter(Damage.source, GetOwningPlayer(Damage.target)) and this > 0 then
                set b = SpellBuff.add(Damage.target, Damage.source)
                set b.duration = DebuffDuration(this.lvl)
                call b.reapply(this.lvl)
            endif
        endmethod

        method reapply takes integer level returns nothing
            set this.lvl = level
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
            call Damage.register(function thistype.onDamage)
        endmethod

        implement BuffApply
    endstruct

    struct FrostArmor extends array
        implement Alloc

        private unit target

        private static method expires takes nothing returns nothing
            local thistype this = ReleaseTimer(GetExpiredTimer())
            call UnitRemoveAbility(this.target, 'BUfa')
            set this.target = null
            call this.deallocate()
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            local unit caster = GetTriggerUnit()
            local integer lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            local FrostArmorBuff f
            set this.target = GetSpellTargetUnit()
            set f = FrostArmorBuff.add(caster, this.target)
            set f.duration = Duration(lvl)
            call f.reapply(lvl)
            call TimerStart(NewTimerEx(this), 0.0, false, function thistype.expires)
            set caster = null
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SpellBuff.initialize()
            call FrostArmorBuff.initialize()
            call SystemTest.end()
        endmethod

    endstruct

endscope