scope CursedRift
    
    globals
        private constant integer SPELL_ID = 'A321'
        private constant integer SPELL_BUFF = 'a321'
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
        private constant real RADIUS = 150.0
        private constant string SFX = "Abilities\\Weapons\\ZigguratMissile\\ZigguratMissile.mdl"
    endglobals
    
    private function DamageAmount takes integer level returns real
        if level == 11 then
            return 500.0
        endif
        return 50.0*level
    endfunction
    
    private function BonusSpeed takes integer level returns real
        return 0.3 + 0.0*level
    endfunction
    
    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE)
    endfunction
    
    struct CursedRift extends array
        
        private unit caster
        private group affected
        private real dmg
        private effect sfx
        private Invisible inv
        private Movespeed ms
        
        private static group g
        
        private method remove takes nothing returns nothing
            call DestroyGroup(this.affected)
            call this.inv.destroy()
            call this.ms.destroy()
            call DestroyEffect(this.sfx)
            set this.sfx = null
            set this.caster = null
            set this.affected = null
            call this.destroy()
        endmethod
        
        implement CTL
            local unit u
            local player owner
        implement CTLExpire
            if GetUnitAbilityLevel(this.caster, SPELL_BUFF) > 0 then
                call GroupUnitsInArea(thistype.g, GetUnitX(this.caster), GetUnitY(this.caster), RADIUS)
                set owner = GetOwningPlayer(this.caster)
                loop
                    set u = FirstOfGroup(thistype.g)
                    exitwhen u == null
                    call GroupRemoveUnit(thistype.g, u)
                    if not IsUnitInGroup(u, this.affected) and TargetFilter(u, owner) then
                        call GroupAddUnit(this.affected, u)
                        call Damage.element.apply(this.caster, u, this.dmg, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_SPIRIT)
                        call DestroyEffect(AddSpecialEffectTarget(SFX, u, "chest"))
                    endif
                endloop
            else
                call this.remove()
            endif
        implement CTLNull
            set owner = null
        implement CTLEnd
        
        private static method onCast takes nothing returns nothing
            local thistype this = thistype.create()
            local integer lvl
            set this.caster = GetTriggerUnit()
            set lvl = GetUnitAbilityLevel(this.caster, SPELL_ID)
            set this.affected = CreateGroup()
            set this.inv = Invisible.create(this.caster, 0)
            set this.ms = Movespeed.create(this.caster, BonusSpeed(lvl), 0)
            set this.dmg = DamageAmount(lvl)
            set this.sfx = AddSpecialEffectTarget(SFX, this.caster, "chest")
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            set thistype.g = CreateGroup()
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope