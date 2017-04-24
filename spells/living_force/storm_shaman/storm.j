scope Storm
 
    globals
        private constant integer SPELL_ID = 'AH14'
        private constant string SFX = "Models\\Effects\\Storm.mdx"
        private constant string SFX_HIT = "Abilities\\Weapons\\Bolt\\BoltImpact.mdl" 
        private constant string LIGHTNING_CODE = "CLPB"
        private constant real LIGHTNING_DURATION = 0.8
        private constant integer UNIT_ID = 'HT01'
		private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
    endglobals
    
    private function Duration takes integer level returns real
        return 10.0*level
    endfunction

    private function Radius takes integer level returns real
        return 900.0 + 0.0*level
    endfunction

    private function DamagePerAttack takes integer level returns real
        return 1000.0 + 0.0*level
    endfunction

    private function AttackCooldown takes integer level returns real
        return 1.0 + 0.0*level
    endfunction

    private function MovementSlow takes integer level returns real
        return 0.2 + 0.0*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and IsUnitVisible(u, p)
    endfunction
    
    private struct SpellBuff extends Buff
        
        private effect sfx
        private timer t
        private real dmg
        private real radius
        private Movespeed ms

        private static group g

        private static constant integer RAWCODE = 'BH14'
        private static constant integer DISPEL_TYPE = BUFF_POSITIVE
        private static constant integer STACK_TYPE = BUFF_STACK_NONE
        
        method onRemove takes nothing returns nothing
            call this.ms.destroy()
            call ReleaseTimer(this.t)
            call DestroyEffect(this.sfx)
            set this.t = null
            set this.sfx = null
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            local player p = GetOwningPlayer(this.source)
            local unit u
            local Lightning l
            call GroupUnitsInArea(thistype.g, GetUnitX(this.source), GetUnitY(this.source), this.radius)
            loop
                set u = FirstOfGroup(thistype.g)
                exitwhen u == null
                call GroupRemoveUnit(thistype.g, u)
                if TargetFilter(u, p) then
                    set l = Lightning.createUnits(LIGHTNING_CODE, this.source, u)
                    set l.duration = LIGHTNING_DURATION
                    call l.startColor(1.0, 1.0, 1.0, 1.0)
                    call l.endColor(1.0, 1.0, 1.0, 0.1)
                    call DestroyEffect(AddSpecialEffectTarget(SFX_HIT, u, "origin"))
                    call Damage.element.apply(this.source, u, this.dmg, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_ELECTRIC)
                endif
            endloop
            set p = null
        endmethod

        private static method fallHeight takes nothing returns nothing
            call SetUnitFlyHeight(thistype(ReleaseTimer(GetExpiredTimer())).target, 0, 200)
        endmethod

        private static method raiseHeight takes nothing returns nothing
            local timer t = GetExpiredTimer()
            local thistype this = GetTimerData(t)
            call SetUnitFlyHeight(this.target, 200, 200)
            call TimerStart(t, this.duration - 1.0, false, function thistype.fallHeight)
        endmethod
        
        method onApply takes nothing returns nothing
            set this.sfx = AddSpecialEffectTarget(SFX, this.target, "overhead")
            set this.ms = Movespeed.create(this.target, 0, 0)
            set this.t = NewTimerEx(this)
            call TimerStart(NewTimerEx(this), 0.0, false, function thistype.raiseHeight)
        endmethod

        method reapply takes integer level returns nothing
			set this.duration = Duration(level)
            set this.dmg = DamagePerAttack(level)
            set this.radius = Radius(level)
            call this.ms.change(-MovementSlow(level), 0)
            call TimerStart(this.t, AttackCooldown(level), true, function thistype.onPeriod)
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
            set thistype.g = CreateGroup()
        endmethod
        
        implement BuffApply
    endstruct
    
    struct Storm extends array
        
        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local integer lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            local SpellBuff b
            if GetUnitTypeId(caster) != UNIT_ID then
                set b = SpellBuff.add(caster, caster)
                call b.reapply(lvl)
            endif
            set caster = null
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SpellBuff.initialize()
            call PreloadUnit(UNIT_ID)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope