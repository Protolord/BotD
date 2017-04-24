scope SoulRip
    
    globals
        private constant integer SPELL_ID = 'A713'
        private constant string MODEL = "Models\\Effects\\SoulRipMissile.mdx"
        private constant string SFX_HIT = "Abilities\\Spells\\Undead\\DeathCoil\\DeathCoilSpecialArt.mdl"
        private constant string AREA_NODE = "Models\\Effects\\SoulRipEffect.mdx"
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
		private constant real SPACING = 150.0
    endglobals
    
    private function HealPerUnit takes integer level returns real
        if level == 11 then
            return 1000.0
        endif
        return 100.0 + 50.0*level
    endfunction
    
    private function Radius takes integer level returns real
        if level == 11 then
            return 1000.0
        endif
        return 100.0*level
    endfunction
    
    private function Speed takes integer level returns real
        return 200.0 + 0.0*level
    endfunction
    
    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE)
    endfunction
    
    private struct Soul extends array
        
        private Missile m
        private unit caster
        private real heal
        
        private method destroy takes nothing returns nothing
            call this.m.destroy()
            set this.caster = null
        endmethod
        
        private static method onHit takes nothing returns nothing
            local thistype this = Missile.getHit()
            if UnitAlive(this.caster) then
                call DestroyEffect(AddSpecialEffectTarget(SFX_HIT, this.caster, "origin"))
                call Heal.unit(this.caster, this.heal, 1.0)
            endif
            call this.destroy()
        endmethod
        
        static method add takes unit source, unit target returns nothing
            local thistype this = thistype(Missile.create())
            local integer lvl = GetUnitAbilityLevel(source, SPELL_ID)
            set this.caster = source
            set this.heal = HealPerUnit(lvl)
            set this.m = Missile(this)
            set this.m.sourceUnit = target
            set this.m.targetUnit = source
            set this.m.speed = Speed(lvl)
            set this.m.model = MODEL
            call this.m.registerOnHit(function thistype.onHit)
            call this.m.launch()
            call Damage.element.apply(source, target, this.heal, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_SPIRIT)
        endmethod
        
    endstruct
    
    struct SoulRip extends array
        
        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local player p = GetTriggerPlayer()
            local integer level = GetUnitAbilityLevel(caster, SPELL_ID)
            local real x = GetUnitX(caster)
            local real y = GetUnitY(caster)
            local group g = NewGroup()
			local real radius = Radius(level)
			local real da
            local real angle
            local real endAngle
            local unit u
            call GroupUnitsInArea(g, x, y, Radius(level))
            loop
                set u = FirstOfGroup(g)
                exitwhen u == null
                call GroupRemoveUnit(g, u)
                if TargetFilter(u, p) then
                    call Soul.add(caster, u)
                endif
            endloop
			set da = 2*bj_PI/R2I(2*bj_PI*radius/SPACING)
			if da > bj_PI/3 then
				set da = bj_PI/3
			endif
			set angle = da
			set endAngle = da + 2*bj_PI - 0.0001
			loop
				exitwhen angle >= endAngle
				call DestroyEffect(AddSpecialEffect(AREA_NODE, x + radius*Cos(angle), y + radius*Sin(angle)))
				set angle = angle + da
			endloop
            call ReleaseGroup(g)
            set g = null
            set caster = null
            set p = null
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope