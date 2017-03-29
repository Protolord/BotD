scope Burrow 
    globals
        private constant integer SPELL_ID = 'A4XX'
        private constant integer BURROWED_UNIT_ID = 'UBAr'
        private constant real RADIUS = 150.0
        private constant real SPACING = 100.0
        private constant real DELAY = 1.0
        private constant string SFX = "Objects\\Spawnmodels\\Undead\\ImpaleTargetDust\\ImpaleTargetDust.mdl"
        private constant string SFX_SPIKE = "Abilities\\Spells\\Undead\\Impale\\ImpaleMissTarget.mdl"
    endglobals
    
    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction
    
    struct Burrow extends array
        
        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local real x = GetUnitX(caster)
            local real y = GetUnitY(caster)
            local unit u
            local real da
            local real angle
            local real endAngle
            local group g
            local player owner
            if GetUnitTypeId(caster) == BURROWED_UNIT_ID then
                set g = NewGroup()
                set owner = GetTriggerPlayer()
                call GroupUnitsInArea(g, x, y, RADIUS)
                loop
                    set u = FirstOfGroup(g)
                    exitwhen u == null
                    call GroupRemoveUnit(g, u)
                    if TargetFilter(u, owner) then
                        call Damage.kill(caster, u)
                    endif
                endloop
                //Create SFX
                set da = 2*bj_PI/R2I(2*bj_PI*(RADIUS - 25)/SPACING)
                if da > bj_PI/3 then
                    set da = bj_PI/3
                endif
                set angle = da
                set endAngle = da + 2*bj_PI - 0.0001
                loop
                    exitwhen angle >= endAngle
                    call DestroyEffect(AddSpecialEffect(SFX_SPIKE, x + (RADIUS - 25)*Cos(angle), y + (RADIUS - 25)*Sin(angle)))
                    set angle = angle + da
                endloop
                call ReleaseGroup(g)
                set g = null
                set owner = null
            endif
            call DestroyEffect(AddSpecialEffect(SFX, x, y))
            set caster = null
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope