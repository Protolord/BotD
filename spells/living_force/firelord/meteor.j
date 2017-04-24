scope Meteor

    globals
        private constant integer SPELL_ID = 'AH54'
        private constant string SFX = "Models\\Effects\\Meteor.mdx"
        private constant string SFX_BUFF = "Environment\\LargeBuildingFire\\LargeBuildingFire2.mdl"
        private constant real HIT_DELAY = 0.8
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
    endglobals
    
    //In Percent
    private function MaxHPDamage takes integer level returns real
        return 10.0 + 0.0*level
    endfunction
    
    //In Percent
    private function MaxHPDamagePerSecond takes integer level returns real
        return 0.4*level - 0.3
    endfunction

    private function Duration takes integer level returns real
        return 5.0 + 0.0*level
    endfunction

    private function Radius takes integer level returns real
        return 250.0 + 0.0*level
    endfunction
    
    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction

    private struct SpellBuff extends Buff

        private effect sfx
        private timer t
        private real dmgFactor
        
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
            call Damage.element.apply(this.source, this.target, this.dmgFactor*GetUnitState(this.target, UNIT_STATE_MAX_LIFE)/100.0, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_FIRE)
        endmethod
        
        method onApply takes nothing returns nothing
            set this.sfx = AddSpecialEffectTarget(SFX_BUFF, this.target, "chest")
            set this.t = NewTimerEx(this)
            call TimerStart(this.t, 1.0, true, function thistype.onPeriod)
        endmethod

        method reapply takes integer lvl returns nothing
			set this.dmgFactor = MaxHPDamagePerSecond(lvl)
		endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod
        
        implement BuffApply
    endstruct
    
    struct Meteor extends array
        implement Alloc

        private unit caster
        private player owner
        private integer lvl
        private real x 
        private real y
        private static group g

        private method destroy takes nothing returns nothing
            set this.caster = null
            set this.owner = null
            call this.deallocate()
        endmethod

        private static method onHit takes nothing returns nothing
            local thistype this = ReleaseTimer(GetExpiredTimer())
            local real dmgFactor = MaxHPDamage(this.lvl)
            local SpellBuff b
            local unit u
            call GroupUnitsInArea(thistype.g, this.x, this.y, Radius(this.lvl))
            loop
                set u = FirstOfGroup(thistype.g)
                exitwhen u == null 
                call GroupRemoveUnit(thistype.g, u)
                if TargetFilter(u, this.owner) then
                    call Damage.element.apply(this.caster, u, dmgFactor*GetUnitState(u, UNIT_STATE_MAX_LIFE)/100.0, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_FIRE)
                    set b = SpellBuff.add(this.caster, u)
                    set b.duration = Duration(this.lvl)
                    call b.reapply(this.lvl)
                endif
            endloop
            call this.destroy()
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            local Effect e
            set this.caster = GetTriggerUnit()
            set this.owner = GetTriggerPlayer()
            set this.lvl = GetUnitAbilityLevel(this.caster, SPELL_ID)
            set this.x = GetSpellTargetX()
            set this.y = GetSpellTargetY()
            set e = Effect.create(SFX, this.x, this.y, 0, Atan2(this.y - GetUnitY(this.caster), this.x - GetUnitX(this.caster))*bj_RADTODEG)
            set e.duration = HIT_DELAY
            set e.scale = 0.75
            call e.destroy()
            call TimerStart(NewTimerEx(this), HIT_DELAY, false, function thistype.onHit)
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SpellBuff.initialize()
            set thistype.g = CreateGroup()
            call SystemTest.end()
        endmethod
        
    endstruct
endscope