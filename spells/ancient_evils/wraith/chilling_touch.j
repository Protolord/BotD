scope ChillingTouch
    
    globals
        private constant integer SPELL_ID = 'A3XX'
        private constant integer SPELL_BUFF = 'D3XX'
        private constant string SFX = "Abilities\\Spells\\Other\\FrostDamage\\FrostDamage.mdl"
    endglobals
    
    private function Duration takes integer level returns real
        return 5.00 + 0.0*level
    endfunction
    
    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction
    
    
    private struct SpellBuff extends Buff
        
        readonly Movespeed ms
        readonly Atkspeed as
        private effect sfx
        
        method rawcode takes nothing returns integer
            return SPELL_BUFF
        endmethod
        
        method dispelType takes nothing returns integer
            return BUFF_NEGATIVE
        endmethod
        
        method stackType takes nothing returns integer
            return BUFF_STACK_PARTIAL
        endmethod
        
        method onRemove takes nothing returns nothing
            call this.ms.destroy()
            call this.as.destroy()
            call DestroyEffect(this.sfx)
            set this.sfx = null
        endmethod
        
        method onApply takes nothing returns nothing
            set this.ms = Movespeed.create(this.target, 0, 0)
            set this.as = Atkspeed.create(this.target, 0)
            set this.sfx = AddSpecialEffectTarget(SFX, this.target, "chest")
        endmethod
        
        implement BuffApply
    endstruct
    
    struct ChillingTouch extends array
        
        private static method onDamage takes nothing returns nothing
            local integer level = GetUnitAbilityLevel(Damage.source, SPELL_ID)
            local real slow
            local SpellBuff b
            
            if Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.element.coded and level > 0 and TargetFilter(Damage.target, GetOwningPlayer(Damage.source))  then
                set slow = -0.01*GetHeroLevel(Damage.source)
                set b = SpellBuff.add(Damage.source, Damage.target)
                set b.duration = Duration(level)
                call b.ms.change(slow, 0)
                call b.as.change(slow)
            endif
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call Damage.register(function thistype.onDamage)
            call PreloadSpell(SPELL_BUFF)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope