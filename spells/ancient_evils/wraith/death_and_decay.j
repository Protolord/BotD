scope DeathAndDecay
    
    globals
        private constant integer SPELL_ID = 'A311'
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
        private constant string SFX = "Models\\Effects\\DeathAndDecay.mdx"
    endglobals
    
    private function DamageFactor takes integer level returns real
        if level == 11 then
            return 12.0
        endif
        return 1.0 + 0.5*level
    endfunction
    
    private function Radius takes integer level returns real
        return 400.0 + 0.0*level
    endfunction
    
    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE)
    endfunction
    
    struct DeathAndDecay extends array
        
        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local player owner = GetTriggerPlayer()
            local integer lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            local group g = NewGroup()
            local real x = GetSpellTargetX()
            local real y = GetSpellTargetY()
            local unit u
            local unit dummy = GetRecycledDummyAnyAngle(x, y, 10)
            call DestroyEffect(AddSpecialEffectTarget(SFX, dummy, "origin"))
            call SetUnitScale(dummy, 1.5, 0, 0)
            call GroupUnitsInArea(g, x, y, Radius(lvl))
            loop
                set u = FirstOfGroup(g)
                exitwhen u == null
                call GroupRemoveUnit(g, u)
                if TargetFilter(u, owner) then
                    call Damage.element.apply(caster, u, 100.0*DamageFactor(lvl)*GetWidgetLife(u)/GetUnitState(u, UNIT_STATE_MAX_LIFE), ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_DARK)
                endif
            endloop
            call ReleaseGroup(g)
            set g = null
            set caster = null
            set owner = null
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope