scope HellishCloud
  
    //Configuration
    globals
        private constant integer SPELL_ID = 'A522'
        private constant integer SPELL_BUFF = 'a522'
        private constant string SFX = "Models\\Effects\\HellishCloud.mdx"
        private constant string SFX_BUFF = "Models\\Effects\\HellishCloudBuff.mdx"
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
    endglobals
    
    private function DamageDealt takes integer level returns real
        if level == 11 then
            return 1000.0
        endif
        return 50.0*level
    endfunction
    
    private function Radius takes integer level returns real
        return 0.0*level + 400.0
    endfunction
    
    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction

    struct HellishCloud extends array
        
        private unit caster
        private integer lvl
        private effect sfx
        private Invisible inv
        
        private static Table tb
        private static group g
        private static trigger trg
        
        private static method onDamage takes nothing returns boolean
            local integer id = GetHandleId(Damage.source)
            local integer level
            local thistype this
            local unit u
            local real dmg
            local player p
            local real x
            local real y
            if Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.coded and thistype.tb.has(id) then
                set this = thistype.tb[id]
                set dmg = DamageDealt(this.lvl)
                set level = GetUnitAbilityLevel(Damage.source, SPELL_ID)
                set p = GetOwningPlayer(Damage.source)
                set x = GetUnitX(Damage.target)
                set y = GetUnitY(Damage.target)
                call DestroyEffect(AddSpecialEffect(SFX, x, y))
                call GroupUnitsInArea(thistype.g, x, y, Radius(this.lvl))
                call DisableTrigger(thistype.trg)
                loop
                    set u = FirstOfGroup(thistype.g)
                    exitwhen u == null
                    call GroupRemoveUnit(thistype.g, u)
                    if TargetFilter(u, p) then
                        call Damage.apply(Damage.source, u, dmg, ATTACK_TYPE, DAMAGE_TYPE)
                        call FloatingTextSplat(Element.string(DAMAGE_ELEMENT_FIRE) + I2S(R2I(dmg)) + "|r", u, 1.0).setVisible(GetLocalPlayer() == GetOwningPlayer(Damage.source) and IsUnitVisible(u, GetLocalPlayer()))
                    endif
                endloop
                call EnableTrigger(thistype.trg)
                call UnitRemoveAbility(Damage.source, SPELL_BUFF)
            endif
            return false
        endmethod
        
        private method remove takes nothing returns nothing
            call thistype.tb.remove(GetHandleId(this.caster))
            call DestroyEffect(this.sfx)
            call this.inv.destroy()
            set this.sfx = null
            set this.caster = null
            call this.destroy()
        endmethod
        
        implement CTLExpire
            if GetUnitAbilityLevel(this.caster, SPELL_BUFF) == 0 then
                call this.remove()
            endif
        implement CTLEnd

        private static method onCast takes nothing returns nothing
            local integer id = GetHandleId(GetTriggerUnit())
            local thistype this
            if thistype.tb.has(id) then
				set this = thistype.tb[id]
			else
                set this = thistype.create()
                set this.caster = GetTriggerUnit()
                set this.inv = Invisible.create(this.caster, 0)
                set this.sfx = AddSpecialEffectTarget(SFX_BUFF, this.caster, "origin")
                set thistype.tb[id] = this
            endif
			set this.lvl = GetUnitAbilityLevel(this.caster, SPELL_ID)
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            set thistype.trg = CreateTrigger()
            set thistype.tb = Table.create()
            set thistype.g = CreateGroup()
            call Damage.registerTrigger(thistype.trg)
            call TriggerAddCondition(thistype.trg, function thistype.onDamage)
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope