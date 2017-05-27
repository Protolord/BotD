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
            local real dmg
            if TargetFilter(this.target, GetOwningPlayer(this.source)) then
                set dmg = GetHeroLevel(this.source)*DAMAGE_FACTOR
                if dmg > GetWidgetLife(this.target) then
                    set VigilantAndTheVirtuous.dying = this.target
                    call EnableTrigger(VigilantAndTheVirtuous.preventDying)
                    call Damage.apply(this.source, this.target, dmg, ATTACK_TYPE, DAMAGE_TYPE)
                    call DisableTrigger(VigilantAndTheVirtuous.preventDying)
                else
                    call Damage.element.apply(this.source, this.target, dmg, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_FIRE)
                endif
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

        public static unit dying
        readonly static trigger preventDying

        private static method onPrevent takes nothing returns boolean
            if thistype.dying == Damage.target and Damage.amount > GetWidgetLife(Damage.target) then
                set Damage.amount = GetWidgetLife(Damage.target) - 0.6
                if Damage.amount + 0.5 >= 1 then
                    call FloatingTextSplat(Element.string(DAMAGE_ELEMENT_FIRE) + I2S(R2I(Damage.amount + 0.5)) + "|r", Damage.target, 1.0).setVisible(GetLocalPlayer() == GetOwningPlayer(Damage.source) and IsUnitVisible(Damage.target, GetLocalPlayer()))
                endif
            endif
            set thistype.dying = null
            return false
        endmethod

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
            set thistype.preventDying = CreateTrigger()
            call TriggerAddCondition(thistype.preventDying, function thistype.onPrevent)
            call Damage.register(function thistype.onDamage)
            call Damage.registerTrigger(thistype.preventDying)
            call SpellBuff.initialize()
            call SystemTest.end()
        endmethod

    endstruct

endscope