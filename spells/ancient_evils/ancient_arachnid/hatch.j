scope Hatch

    globals
        private constant integer SPELL_ID = 'A422'
        private constant integer UNIT_ID = 'uHat'
        private constant integer TRANSFORM_ID = 'T422'
        private constant real PERIMETER = 800.0
        private constant integer INIT_DAMAGE = 1
        private constant string SFX = "Doodads\\Dungeon\\Terrain\\EggSack\\EggSack0.mdl"
        private constant real DEFAULT_SIGHT = 800 //Sight Radius of Hatchling in Object Editor
    endglobals

    private function Speed takes integer level returns real
        if level == 11 then
            return 522.0
        endif
        return 0.0*level + 250
    endfunction

    private function Damage takes integer level returns integer
        return 0*level + 25
    endfunction

    private function AttackSpeedBonus takes integer level returns real
        if level == 11 then
            return 0.33   //Causes it to have an attack cooldown of 0.75 second
        endif
        return 0.0
    endfunction


    private function Duration takes integer level returns real
        return 2.0*level + 10
    endfunction

    private function SightRadius takes integer level returns real
        return 0.0*level + 800.0
    endfunction

    private function NumberOfUnits takes integer level returns integer
        return 0*level + 5
    endfunction

    struct Hatch extends array

        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local player owner = GetTriggerPlayer()
            local real angle = GetUnitFacing(caster)*bj_DEGTORAD
            local real x = GetUnitX(caster) - 100*Cos(angle)
            local real y = GetUnitY(caster) - 100*Sin(angle)
            local integer lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            local integer i = NumberOfUnits(lvl)
            local real duration = Duration(lvl)
            local integer damage = Damage(lvl) - INIT_DAMAGE
            local real spd = Speed(lvl)
            local real radius = SightRadius(lvl)
            local unit u
            loop
                exitwhen i == 0
                set u = CreateUnit(owner, 'dumi', x, y, 0)
                call Unselectable(u, TRANSFORM_ID)
                call UnitApplyTimedLife(u, 'BTLF', duration)
                call UnitSetBonus(u, BONUS_DAMAGE, damage)
                call SetUnitMoveSpeed(u, spd)
                call UnitSetBonus(u, BONUS_SIGHT_RANGE, R2I(radius - DEFAULT_SIGHT))
                call UnitSetBonus(u, BONUS_ATK_SPEED, R2I(100*AttackSpeedBonus(lvl)))
                call IssuePointOrderById(u, ORDER_attack, x + GetRandomReal(-PERIMETER, PERIMETER), y + GetRandomReal(-PERIMETER, PERIMETER))
                if lvl == 11 then
                    call SetUnitVertexColor(u, 20, 255, 20, 255)
                endif
                set i = i - 1
            endloop
            call DestroyEffect(AddSpecialEffect(SFX, x, y))
            set u = null
            set caster = null
            set owner = null
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call PreloadUnit(UNIT_ID)
            call SystemTest.end()
        endmethod

    endstruct

endscope