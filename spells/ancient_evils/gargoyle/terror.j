scope Terror

    globals
        private constant integer SPELL_ID = 'A614'
        private constant string SFX = "Models\\Effects\\Terror.mdx"
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
    endglobals

    private function DamageDealt takes integer level returns real
        if level == 11 then
            return 700.0
        endif
        return 35.0*level
    endfunction
    
    private function RunDistance takes integer level returns real
        return 250.0 + 0.0*level
    endfunction

    private function Radius takes integer level returns real
        return 400.0 + 0.0*level
    endfunction
    
    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction
    
    struct Terror extends array
        
        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local player owner = GetTriggerPlayer()
            local integer lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            local real dmg = DamageDealt(lvl)
            local real dist = RunDistance(lvl)
            local real x = GetUnitX(caster)
            local real y = GetUnitY(caster)
            local real tx
            local real ty
            local group g = NewGroup()
            local unit dummy = GetRecycledDummyAnyAngle(x, y, 50)
            local real angle
            local unit u
            call DummyAddRecycleTimer(dummy, 2.5)
            call SetUnitScale(dummy, Radius(lvl)/250.0, 0, 0)
            call DestroyEffect(AddSpecialEffectTarget(SFX, dummy, "origin"))
            call GroupUnitsInArea(g, x, y, Radius(lvl))
            loop
                set u = FirstOfGroup(g)
                exitwhen u == null
                call GroupRemoveUnit(g, u)
                if TargetFilter(u, owner) then
                    set tx = GetUnitX(u)
                    set ty = GetUnitY(u)
                    set angle = Atan2(ty - y, tx - x)
                    call IssuePointOrderById(u, ORDER_move, tx + dist*Cos(angle), ty + dist*Sin(angle))
                    call Damage.element.apply(caster, u, dmg, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_EARTH)
                endif
            endloop
            call ReleaseGroup(g)
            set g = null
            set u = null
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