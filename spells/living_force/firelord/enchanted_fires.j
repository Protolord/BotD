scope EnchantedFires

    globals
        private constant integer SPELL_ID = 'AH53'
        private constant string SFX = "Models\\Effects\\EnchantedFires.mdx"
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
    endglobals
    
    //In Percent
    private function Chance takes integer level returns real
        return 1.0*level
    endfunction

    private function Chance_Pyro takes integer level returns real 
        return 2.0*level
    endfunction

    private function Radius takes integer level returns real
        return 250.0 + 0.0*level
    endfunction
    
    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction

    struct EnchantedFires extends array
        
        private static group g

        private static method onDamage takes nothing returns nothing
            local integer level = GetUnitAbilityLevel(Damage.target, SPELL_ID)
            local player p = GetOwningPlayer(Damage.target)
            local boolean b
            local real x 
            local real y
            local unit u 
            if Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.coded and level > 0 and TargetFilter(Damage.source, p) and CombatStat.isMelee(Damage.source) then
                if Pyro.has(Damage.target) then
                    set b = GetRandomReal(0, 100) <= Chance_Pyro(level)
                else
                    set b = GetRandomReal(0, 100) <= Chance(level)
                endif
                if b then
                    set x = GetUnitX(Damage.source)
                    set y = GetUnitY(Damage.source)
                    call GroupUnitsInArea(thistype.g, x, y, Radius(level))
                    loop
                        set u = FirstOfGroup(thistype.g)
                        exitwhen u == null
                        call GroupRemoveUnit(thistype.g, u)
                        if TargetFilter(u, p) then
                            call Damage.element.apply(Damage.target, u, GetWidgetLife(Damage.target), ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_FIRE)
                        endif
                    endloop
                    call DestroyEffect(AddSpecialEffect(SFX, x, y))
                    call SystemMsg.create(GetUnitName(Damage.target) + " procs thistype")
                endif
            endif
            set p = null
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            set thistype.g = CreateGroup()
            call Damage.register(function thistype.onDamage)
            call SystemTest.end()
        endmethod
        
    endstruct
endscope