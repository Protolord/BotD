scope SoulBreak

    globals
        private constant integer SPELL_ID = 'A711'
        private constant string MODEL = "Models\\Effects\\SoulBreak.mdx"
        private constant string BUFF_SFX = "Abilities\\Spells\\Undead\\Curse\\CurseTarget.mdl"
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
        private constant real TIMEOUT = 1.0
    endglobals
    
    private function Duration takes integer level returns real
        if level == 11 then
            return 20.0
        endif
        return 1.0*level
    endfunction

    private function DamagePerSecond takes integer level returns real
        if level == 11 then
            return 40.0
        endif
        return 20.0 + 0.0*level
    endfunction

    private function Ministun takes integer level returns real
        if level == 11 then
            return 0.5
        endif
        return 0.3 + 0.0*level
    endfunction
    
    private function Speed takes integer level returns real
        return 800.0 + 0.0*level
    endfunction
    
    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction

    private struct SpellBuff extends Buff
        
        private timer t
        private effect sfx
        public real dmg
        public real ministun

        private static constant integer RAWCODE = 'D711'
        private static constant integer DISPEL_TYPE = BUFF_NEGATIVE
        private static constant integer STACK_TYPE = BUFF_STACK_FULL
        
        method onRemove takes nothing returns nothing
            call ReleaseTimer(this.t)
            call DestroyEffect(this.sfx)
            set this.sfx = null
            set this.t = null
        endmethod
        
        static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            call Damage.element.apply(this.source, this.target, this.dmg, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_DARK)
            call Stun.create(this.target, this.ministun, false)
        endmethod
        
        method onApply takes nothing returns nothing
            set this.t = NewTimerEx(this)
            set this.sfx = AddSpecialEffectTarget(BUFF_SFX, this.target, "overhead")
            call TimerStart(this.t, TIMEOUT, true, function thistype.onPeriod)
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod
        
        implement BuffApply
    endstruct
    
    struct SoulBreak extends array
        
        private unit caster
        private unit target
        private integer lvl
        private player owner
        private Missile m
        
        private method destroy takes nothing returns nothing
            call this.m.destroy()
            set this.caster = null
            set this.target = null
            set this.owner = null
        endmethod
        
        private static method onHit takes nothing returns nothing
            local thistype this = Missile.getHit()
            local SpellBuff b
            if not SpellBlock.has(this.target) and TargetFilter(this.target, this.owner) then
                set b = SpellBuff.add(this.caster, this.target)
                set b.dmg = DamagePerSecond(this.lvl)*TIMEOUT
                set b.ministun = Ministun(this.lvl)
                set b.duration = Duration(this.lvl)
            endif
            call this.destroy()
        endmethod
        
        private static method onCast takes nothing returns nothing
            local thistype this = thistype(Missile.create())
            set this.caster = GetTriggerUnit()
            set this.owner = GetTriggerPlayer()
            set this.target = GetSpellTargetUnit()
            set this.lvl = GetUnitAbilityLevel(this.caster, SPELL_ID)
            set this.m = Missile(this)
            set this.m.sourceUnit = this.caster
            set this.m.targetUnit = this.target
            set this.m.speed = Speed(this.lvl)
            set this.m.model = MODEL
            call this.m.registerOnHit(function thistype.onHit)
            call this.m.launch()
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SpellBuff.initialize()
            call SystemTest.end()
        endmethod
        
    endstruct
endscope