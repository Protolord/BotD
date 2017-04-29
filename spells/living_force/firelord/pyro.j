scope Pyro

    globals
        private constant integer SPELL_ID = 'AH51'
        private constant integer UNIT_ID = 0
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
    endglobals

    globals
        //Burn Debuff
        private constant integer ATK_PERCENT_REDUCE = 30
        private constant string SFX_BUFF = "Environment\\LargeBuildingFire\\LargeBuildingFire2.mdl"
    endglobals
    
    private function BaseDamage takes integer level returns real
        return 50.0 + 0.0*level
    endfunction

    private function ExtraDamage takes integer level returns real
        return 60.0 + 0.0*level
    endfunction

    private function Duration takes integer level returns real
        return 10.0 + 0.0*level
    endfunction

    private function BurnDuration takes integer level returns real
        return 3.0 + 0.0*level
    endfunction
    
    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and IsUnitType(u, UNIT_TYPE_MELEE_ATTACKER) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction

    struct Burn extends Buff

        private effect sfx
        private AtkDamagePercent adp
        
		private static constant integer RAWCODE = 'DH50'
        private static constant integer DISPEL_TYPE = BUFF_NEGATIVE
        private static constant integer STACK_TYPE = BUFF_STACK_NONE
        
        method onRemove takes nothing returns nothing
            call DestroyEffect(this.sfx)
            call this.adp.destroy()
            set this.sfx = null
        endmethod
        
        method onApply takes nothing returns nothing
            set this.sfx = AddSpecialEffectTarget(SFX_BUFF, this.target, "chest")
            set this.adp = AtkDamagePercent.create(this.target, -ATK_PERCENT_REDUCE/100.0)
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod
        
        implement BuffApply
    endstruct
    
    struct Pyro extends array
        implement Alloc

        private integer lvl

        private static Table tb

        private static method onDamage takes nothing returns nothing
            local thistype this = thistype.tb[GetHandleId(Damage.target)]
            local Burn b
            if this > 0 and GetUnitTypeId(Damage.target) == UNIT_ID and Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.coded and TargetFilter(Damage.source, GetOwningPlayer(Damage.target)) then
                set b = Buff.get(null, Damage.source, Burn.typeid)
                if b > 0 then
                    call Damage.element.apply(Damage.target, Damage.source, BaseDamage(this.lvl) + ExtraDamage(this.lvl)*b.duration, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_FIRE)
                else
                    call Damage.element.apply(Damage.target, Damage.source, BaseDamage(this.lvl), ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_FIRE)
                endif
            endif
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            local unit caster = GetTriggerUnit()
            set this.lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            set caster = null
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call Damage.register(function thistype.onDamage)
            set thistype.tb = Table.create()
            call Burn.initialize()
            call SystemTest.end()
        endmethod
        
    endstruct
endscope