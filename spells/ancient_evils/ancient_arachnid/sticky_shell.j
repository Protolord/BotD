scope StickyShell
    
    globals
        private constant integer SPELL_ID = 'A423'
        private constant string SFX = "Models\\Effects\\StickyShellBuff.mdx"
        private constant real TIMEOUT = 1.0
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
    endglobals
    
    private function AtkSpeedSlow takes integer level returns real
        return 0.0*level + 0.5
    endfunction
    
    private function Duration takes integer level returns real
        if level == 11 then
            return 20.0
        endif
        return 1.0*level
    endfunction
    
    private function DamagePerSecond takes integer level returns real
        return 0.0*level + 50.0
    endfunction
    
    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and CombatStat.isMelee(u) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction
    
    private struct SpellBuff extends Buff
        
        readonly Atkspeed as
        private timer t
        private effect sfx
        public real dmg
        
        private static constant integer RAWCODE = 'D423'
        private static constant integer DISPEL_TYPE = BUFF_NEGATIVE
        private static constant integer STACK_TYPE = BUFF_STACK_PARTIAL
        
        method onRemove takes nothing returns nothing
            call ReleaseTimer(this.t)
            call DestroyEffect(this.sfx)
            call this.as.destroy()
            set this.sfx = null
            set this.t = null
        endmethod
        
        static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            if TargetFilter(this.target, GetOwningPlayer(this.source)) then
                call Damage.element.apply(this.source, this.target, this.dmg, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_POISON)
            else
                call this.remove()
            endif
        endmethod
        
        method onApply takes nothing returns nothing
            set this.sfx = AddSpecialEffectTarget(SFX, this.target, "chest")
            set this.t = NewTimerEx(this)
            set this.as = Atkspeed.create(this.target, 0)
            call TimerStart(this.t, TIMEOUT, true, function thistype.onPeriod)
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod
        
        implement BuffApply
    endstruct
    
    struct StickyShell extends array

        private static method onDamage takes nothing returns nothing
            local integer level = GetUnitAbilityLevel(Damage.target, SPELL_ID)
            local thistype this
            local SpellBuff b
            if Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.coded and level > 0 and TargetFilter(Damage.source, GetOwningPlayer(Damage.target)) then
                set b = SpellBuff.add(Damage.target, Damage.source)
                set b.duration = Duration(level)
                set b.dmg = DamagePerSecond(level)*TIMEOUT
                call b.as.change(-AtkSpeedSlow(level))
            endif
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call Damage.register(function thistype.onDamage)
            call SpellBuff.initialize()
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope