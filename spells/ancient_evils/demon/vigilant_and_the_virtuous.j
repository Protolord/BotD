scope VigilantAndTheVirtuous

    globals
        private constant integer SPELL_ID = 'A5XX'
        private constant integer DURATION = 30
        private constant real DAMAGE_FACTOR = 3.0
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
    endglobals


    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction

    private struct SpellBuff extends Buff

        private timer t

        private static constant integer RAWCODE = 'D5XX'
        private static constant integer DISPEL_TYPE = BUFF_NEGATIVE
        private static constant integer STACK_TYPE = BUFF_STACK_PARTIAL

        method onRemove takes nothing returns nothing
            call ReleaseTimer(this.t)
            set this.t = null
        endmethod

        static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            if TargetFilter(this.target, GetOwningPlayer(this.source)) then
                call Damage.element.apply(this.source, this.target, GetHeroLevel(this.source)*DAMAGE_FACTOR, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_FIRE)
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

    struct VigilantAndTheVirtuous extends array

        private static method onDamage takes nothing returns nothing
            local integer level
            local SpellBuff b
            if Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.coded and GetUnitAbilityLevel(Damage.source, SPELL_ID) > 0 and TargetFilter(Damage.target, GetOwningPlayer(Damage.source)) then
                set b = SpellBuff.add(Damage.source, Damage.target)
                set b.duration = DURATION
            endif
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call SpellBuff.initialize()
            call SystemTest.end()
        endmethod

    endstruct

endscope