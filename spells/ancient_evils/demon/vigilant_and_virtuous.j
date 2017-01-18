scope VigilantAndVirtuous

    globals
        private constant integer SPELL_ID = 'A5XX'
        private constant integer BUFF_ID = 'D5XX'
        private constant string SFX = "Models\\Effects\\VigilantAndVirtuous.mdx"
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
        private effect sfx
        
        method rawcode takes nothing returns integer
            return BUFF_ID
        endmethod
        
        method dispelType takes nothing returns integer
            return BUFF_NEGATIVE
        endmethod
        
        method stackType takes nothing returns integer
            return BUFF_STACK_PARTIAL
        endmethod
        
        method onRemove takes nothing returns nothing
            call ReleaseTimer(this.t)
            call DestroyEffect(this.sfx)
            set this.sfx = null
            set this.t = null
        endmethod
        
        static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            local real dmg
            if TargetFilter(this.target, GetOwningPlayer(this.source)) then
                set dmg = GetHeroLevel(this.source)*DAMAGE_FACTOR
                if dmg > GetWidgetLife(this.target) then
                    set VigilantAndVirtuous.dying = this.target
                    call EnableTrigger(VigilantAndVirtuous.preventDying)
                    call Damage.apply(this.source, this.target, dmg, ATTACK_TYPE, DAMAGE_TYPE)
                    call DisableTrigger(VigilantAndVirtuous.preventDying)
                else
                    call Damage.element.apply(this.source, this.target, dmg, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_FIRE)
                endif
            endif
        endmethod
        
        method onApply takes nothing returns nothing
            set this.t = NewTimerEx(this)
            set this.sfx = AddSpecialEffectTarget(SFX, this.target, "overhead")
            call TimerStart(this.t, 1.00, true, function thistype.onPeriod)
        endmethod
        
        implement BuffApply
    endstruct
    
    struct VigilantAndVirtuous extends array
        
        public static unit dying
        readonly static trigger preventDying
        
        private static method onPrevent takes nothing returns boolean
            if thistype.dying == Damage.target and Damage.amount > GetWidgetLife(Damage.target) then
                set Damage.amount = GetWidgetLife(Damage.target) - 0.6
                call FloatingTextSplat(Element.string(DAMAGE_ELEMENT_FIRE) + I2S(R2I(Damage.amount)) + "|r", Damage.target, 1.0).setVisible(GetLocalPlayer() == GetOwningPlayer(Damage.source) and IsUnitVisible(Damage.target, GetLocalPlayer()))
            endif
            set thistype.dying = null
            return false
        endmethod
        
        private static method onDamage takes nothing returns nothing
            local integer level
            local SpellBuff b
            if Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.element.coded and GetUnitAbilityLevel(Damage.source, SPELL_ID) > 0 and TargetFilter(Damage.target, GetOwningPlayer(Damage.source)) then
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
            call PreloadSpell(BUFF_ID)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope