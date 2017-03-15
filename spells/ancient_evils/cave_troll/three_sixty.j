scope ThreeSixty

    globals
        private constant integer SPELL_ID = 'A812'
        private constant string SFX = "Models\\Effects\\EarthShatter.mdx"
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
    endglobals

    private function DamageDealt takes integer level returns real
        if level == 11 then
            return 2000.0
        endif
        return 100.0*level
    endfunction
    
    private function Radius takes integer level returns real
        return 350.0 + 0.0*level
    endfunction
    
    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction
    
    struct ThreeSixty extends array
        
        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local player owner = GetTriggerPlayer()
            local integer lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            local real dmg = DamageDealt(lvl)
            local real x = GetUnitX(caster)
            local real y = GetUnitY(caster)
            local group g = NewGroup()
            local unit dummy = GetRecycledDummyAnyAngle(x, y, 50)
            local unit u
            call DummyAddRecycleTimer(dummy, 2.5)
            call SetUnitScale(dummy, Radius(lvl)/300.0, 0, 0)
            call DestroyEffect(AddSpecialEffectTarget(SFX, dummy, "origin"))
            call GroupUnitsInArea(g, x, y, Radius(lvl))
            loop
                set u = FirstOfGroup(g)
                exitwhen u == null
                call GroupRemoveUnit(g, u)
                if TargetFilter(u, owner) then
                    call Damage.element.apply(caster, u, dmg, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_NORMAL)
                endif
            endloop
            call ReleaseGroup(g)
            set g = null
            set u = null
            set dummy = null
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