scope ChillingTouch
    
    globals
        private constant integer SPELL_ID = 'A3XX'
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
        private VertexColor vc

        private static constant integer RAWCODE = 'D3XX'
        private static constant integer DISPEL_TYPE = BUFF_NEGATIVE
        private static constant integer STACK_TYPE = BUFF_STACK_PARTIAL
        
        method onRemove takes nothing returns nothing
            call this.ms.destroy()
            call this.as.destroy()
            call DestroyEffect(this.sfx)
            call this.vc.destroy()
            set this.sfx = null
        endmethod
        
        method onApply takes nothing returns nothing
            set this.ms = Movespeed.create(this.target, 0, 0)
            set this.as = Atkspeed.create(this.target, 0)
            set this.sfx = AddSpecialEffectTarget(SFX, this.target, "chest")
            set this.vc = VertexColor.create(this.target, -200, -50, 255, 0)
            set this.vc.speed = 500
        endmethod

        method reapply takes nothing returns nothing
            local real slow = -0.01*GetHeroLevel(this.source)
			call this.ms.change(slow, 0)
			call this.as.change(slow)
		endmethod
        
        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod

        implement BuffApply
    endstruct
    
    struct ChillingTouch extends array
        
        private static method onDamage takes nothing returns nothing
            local integer level = GetUnitAbilityLevel(Damage.source, SPELL_ID)
            local SpellBuff b
            
            if Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.coded and level > 0 and TargetFilter(Damage.target, GetOwningPlayer(Damage.source))  then
                set b = SpellBuff.add(Damage.source, Damage.target)
                set b.duration = Duration(level)
                call b.reapply()
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