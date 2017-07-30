scope Overgrowth

    globals
        private constant integer SPELL_ID = 'AHK3'
    endglobals

    //In percent
    private function Chance takes integer level returns real
        return 3.0 + 3.0*level
    endfunction

    private function Duration takes integer level returns real
        return 2.0 + 0.0*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE)
    endfunction

    private struct SpellBuff extends Buff

        private Root r

        private static constant integer RAWCODE = 'DHK3'
        private static constant integer DISPEL_TYPE = BUFF_NEGATIVE
        private static constant integer STACK_TYPE = BUFF_STACK_PARTIAL

        method onRemove takes nothing returns nothing
            call this.r.destroy()
        endmethod

        method onApply takes nothing returns nothing
            set this.r = Root.create(this.target)
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod

        implement BuffApply
    endstruct

    struct Overgrowth extends array

        private static method onDamage takes nothing returns nothing
            local integer level = GetUnitAbilityLevel(Damage.target, SPELL_ID)
            if Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.coded and level > 0 and TargetFilter(Damage.target, GetOwningPlayer(Damage.source)) and GetRandomReal(0, 100) <= Chance(level) and CombatStat.isMelee(Damage.source) then
                set SpellBuff.add(Damage.target, Damage.source).duration = Duration(level)
            endif
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call SpellBuff.initialize()
            call Damage.registerModifier(function thistype.onDamage)
            call SystemTest.end()
        endmethod

    endstruct

endscope