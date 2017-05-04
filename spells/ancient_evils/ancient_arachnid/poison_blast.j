scope PoisonBlast
 
    globals
        private constant integer SPELL_ID = 'A443'
        private constant string SFX = "Models\\Effects\\PoisonBlast.mdx"
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
    endglobals
    
    private function HealBase takes integer level returns real
        if level == 11 then
            return 2000.0
        endif
        return 100.0*level
    endfunction
    
    private function DamageFactor takes integer level returns real
        if level == 11 then
            return 0.75
        endif
        return 0.05*level
    endfunction
    
    private function Radius takes integer level returns real
        return 0.0*level + 800.0
    endfunction
    
    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction
    
    struct PoisonBlast extends array
        
        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local player owner = GetTriggerPlayer()
            local integer lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            local group g = NewGroup()
            local real x = GetUnitX(caster)
            local real y = GetUnitY(caster)
            local real total = HealBase(lvl)
            local real factor = DamageFactor(lvl)
            local real dmg
            local unit u
            local unit dummy
            call GroupUnitsInArea(g, x, y, Radius(lvl))
            loop
                set u = FirstOfGroup(g)
                exitwhen u == null
                if TargetFilter(u, owner) then
                    set dmg = factor*GetWidgetLife(u)
                    set total = total + dmg
                    call Damage.element.apply(caster, u, dmg, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_POISON)
                endif
                call GroupRemoveUnit(g, u)
            endloop
            set dummy = GetRecycledDummyAnyAngle(x, y, 50)
            call DummyAddRecycleTimer(dummy, 2.5)
            call SetUnitScale(dummy, Radius(lvl)/700, 0, 0)
            call SetUnitVertexColor(dummy, 255, 255, 255, 150)
            
            call DestroyEffect(AddSpecialEffectTarget(SFX, dummy, "origin"))
            call Heal.unit(caster, caster, total, 1.0, true)
            call ReleaseGroup(g)
            set g = null
            set caster = null
            set owner = null
            set dummy = null
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope