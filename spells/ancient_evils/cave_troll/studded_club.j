scope StuddedClub

    globals
        private constant integer SPELL_ID = 'A814'
        private constant string SFX_ATTACH = "Models\\Effects\\StuddedClubAttach.mdx"
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
    endglobals

    private function Duration takes integer level returns real
        if level == 11 then
            return 60.0
        endif
        return 10.0 + 2.0*level
    endfunction

    private function DamagePerSecond takes integer level returns real
        if level == 11 then
            return 30.0
        endif
        return 15.0 + 0.0*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction

    private struct SpellBuff extends Buff

        private timer t
        public real dmg

        private static constant integer RAWCODE = 'D814'
        private static constant integer DISPEL_TYPE = BUFF_NEGATIVE
        private static constant integer STACK_TYPE = BUFF_STACK_PARTIAL

        method onRemove takes nothing returns nothing
            call ReleaseTimer(this.t)
            set this.t = null
        endmethod

        static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            if TargetFilter(this.target, GetOwningPlayer(this.source)) then
                call Damage.element.apply(this.source, this.target, this.dmg, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_NORMAL)
            endif
        endmethod

        method onApply takes nothing returns nothing
            set this.t = NewTimerEx(this)
            call TimerStart(this.t, 1.00, true, function thistype.onPeriod)
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod

        implement BuffApply
    endstruct

    struct StuddedClub extends array

        private static Table tb

        private static method onDamage takes nothing returns nothing
            local integer level = GetUnitAbilityLevel(Damage.source, SPELL_ID)
            local SpellBuff b

            if level > 0 and Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.coded and TargetFilter(Damage.target, GetOwningPlayer(Damage.source))  then
                set b = SpellBuff.add(Damage.source, Damage.target)
                set b.dmg = DamagePerSecond(level)
                set b.duration = Duration(level)
            endif
        endmethod

        private static method learn takes nothing returns nothing
            local unit u = GetTriggerUnit()
            if GetLearnedSkill() == SPELL_ID and not thistype.tb.has(GetHandleId(u)) then
                set thistype.tb[GetHandleId(u)] = 1
                call AddSpecialEffectTarget(SFX_ATTACH, u, "weapon right")
            endif
            set u = null
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call Damage.register(function thistype.onDamage)
            call SpellBuff.initialize()
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_SKILL, function thistype.learn)
            set thistype.tb = Table.create()
            call SystemTest.end()
        endmethod

    endstruct

endscope