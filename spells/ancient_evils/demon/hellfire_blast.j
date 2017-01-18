scope HellfireBlast
 
    globals
        private constant integer SPELL_ID = 'A542'
        private constant integer BUFF_ID = 'B542'
        private constant string SFX = ""
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
        private constant real TIMEOUT = 1.0
    endglobals
    
    private function HealPerExplosion takes integer level returns real
        if level == 11 then
            return 800.0
        endif
        return 40.0*level
    endfunction
    
    private function DamagePerExplosion takes integer level returns real
        if level == 11 then
            return 800.0
        endif
        return 40.0*level
    endfunction
    
    private function Radius takes integer level returns real
        return 0.0*level + 300.0
    endfunction
    
    private function Duration takes integer level returns real
        return 10.0 + 0.0*level
    endfunction
    
    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction
    
    private function HealFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitAlly(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE)
    endfunction
    
    private struct SpellBuff extends Buff
        
        public real radius
        public real dmg
        public real heal
        
        private timer t
        private effect sfx
        
        public static group g
        
        method rawcode takes nothing returns integer
            return BUFF_ID
        endmethod
        
        method dispelType takes nothing returns integer
            return BUFF_POSITIVE
        endmethod
        
        method stackType takes nothing returns integer
            return BUFF_STACK_NONE
        endmethod
        
        method onRemove takes nothing returns nothing
            call ReleaseTimer(this.t)
            call DestroyEffect(this.sfx)
            set this.sfx = null
            set this.t = null
        endmethod
        
        static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            local player owner = GetOwningPlayer(this.target)
            local real x = GetUnitX(this.target)
            local real y = GetUnitY(this.target)
            local unit u
            local unit dummy
            call GroupUnitsInArea(thistype.g, x, y, this.radius)
            loop
                set u = FirstOfGroup(thistype.g)
                exitwhen u == null
                if TargetFilter(u, owner) then
                    call Damage.element.apply(this.target, u, this.dmg, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_FIRE)                 
                endif
                if HealFilter(u, owner) then
                    call Heal.unit(u, this.heal, 4.0)                  
                endif
                call GroupRemoveUnit(thistype.g, u)
            endloop
            set dummy = GetRecycledDummyAnyAngle(x, y, 50)
            call DummyAddRecycleTimer(dummy, 2.5)
            call SetUnitScale(dummy, this.radius/500, 0, 0)
            call DestroyEffect(AddSpecialEffectTarget(SFX, dummy, "origin"))
        endmethod
        
        method onApply takes nothing returns nothing
            set this.t = NewTimerEx(this)
            set this.sfx = AddSpecialEffectTarget(SFX, this.target, "overhead")
            call TimerStart(this.t, TIMEOUT, true, function thistype.onPeriod)
        endmethod
        
        implement BuffApply 
    endstruct
    
    struct HellfireBlast extends array
        implement Alloc
        
        private unit caster
        
        private static method debuff takes nothing returns nothing
            local thistype this = ReleaseTimer(GetExpiredTimer())
            call UnitRemoveAbility(this.caster, 'Bbsk')
            set this.caster = null
            call this.deallocate()
        endmethod
        
        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            local unit caster = GetTriggerUnit()
            local integer lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            local SpellBuff b = SpellBuff.add(caster, caster)
            set b.duration = Duration(lvl)
            set b.heal = HealPerExplosion(lvl)
            set b.dmg = DamagePerExplosion(lvl)
            set b.radius = Radius(lvl)
            set this.caster = caster
            call TimerStart(NewTimerEx(this), 0.00, false, function thistype.debuff)
            set caster = null
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            set SpellBuff.g = CreateGroup()
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope