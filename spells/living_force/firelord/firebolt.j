scope Firebolt

    globals
        private constant integer SPELL_ID = 'AH52'
        private constant string MODEL = "Models\\Effects\\Firebolt.mdx"
        private constant string SFX_BUFF = "Environment\\LargeBuildingFire\\LargeBuildingFire2.mdl"
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
    endglobals
    
    private function DamageDealt takes integer level returns real
        if level == 11 then
            return 1200.0
        endif
        return 60.0*level
    endfunction
    
    private function DamagePerSecond takes integer level returns real
        return 10.0 + 0.0*level
    endfunction

    private function Duration takes integer level returns real
        return 5.0 + 0.0*level
    endfunction

    private function Speed takes integer level returns real
        return 1000.0 + 0.0*level
    endfunction
    
    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction

    private struct SpellBuff extends Buff

        private effect sfx
        private timer t
        private real dmg
        
		private static constant integer RAWCODE = 'DH52'
        private static constant integer DISPEL_TYPE = BUFF_NEGATIVE
        private static constant integer STACK_TYPE = BUFF_STACK_PARTIAL
        
        method onRemove takes nothing returns nothing
            call ReleaseTimer(this.t)
            call DestroyEffect(this.sfx)
            set this.t = null
            set this.sfx = null
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            call Damage.element.apply(this.source, this.target, this.dmg, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_FIRE)
        endmethod
        
        method onApply takes nothing returns nothing
            set this.sfx = AddSpecialEffectTarget(SFX_BUFF, this.target, "chest")
            set this.t = NewTimerEx(this)
            call TimerStart(this.t, 1.0, true, function thistype.onPeriod)
        endmethod

        method reapply takes integer lvl returns nothing
			set this.dmg = DamagePerSecond(lvl)
		endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod
        
        implement BuffApply
    endstruct
    
    struct Firebolt extends array
        
        private unit caster
        private unit target
        private integer lvl
        private player owner
        private Missile m
        
        private method destroy takes nothing returns nothing
            call this.m.destroy()
            set this.caster = null
            set this.target = null
            set owner = null
        endmethod
        
        private static method onHit takes nothing returns nothing
            local thistype this = Missile.getHit()
            local SpellBuff b
            if not SpellBlock.has(this.target) and TargetFilter(this.target, this.owner) then
                call Damage.element.apply(this.caster, this.target, DamageDealt(this.lvl), ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_FIRE)
                set b = SpellBuff.add(this.caster, this.target)
                set b.duration = Duration(this.lvl)
                call b.reapply(this.lvl)
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
            set this.m.model = MODEL
            set this.m.speed = Speed(this.lvl)
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