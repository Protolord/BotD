scope Avander

    globals
        private constant integer SPELL_ID = 'AH24'
        private constant string SFX = "Models\\Effects\\AvanderEffect.mdx"
    endglobals

    private function Duration takes integer level returns real
        return 1.0*level
    endfunction

    //In percent
    private function Chance takes integer level returns real
        return 30.0*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE)
    endfunction

    private struct SpellBuff extends Buff

        private Root r
        private TurningOff to
        private Disarm d

        private static constant integer RAWCODE = 'DH24'
        private static constant integer DISPEL_TYPE = BUFF_NEGATIVE
        private static constant integer STACK_TYPE = BUFF_STACK_FULL

        method onRemove takes nothing returns nothing
            call this.d.destroy()
            call this.r.destroy()
            call this.to.destroy()
        endmethod

        method onApply takes nothing returns nothing
            set this.d = Disarm.create(this.target)
            set this.r = Root.create(this.target)
            set this.to = TurningOff.create(this.target)
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod

        implement BuffApply
    endstruct

    struct Avander extends array

        private static method onDamage takes nothing returns nothing
            local integer level = GetUnitAbilityLevel(Damage.source, SPELL_ID)
            local SpellBuff b
            if Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.coded and level > 0 and TargetFilter(Damage.target, GetOwningPlayer(Damage.source)) and GetRandomReal(0, 100) <= Chance(level) then
                set SpellBuff.add(Damage.source, Damage.target).duration = Duration(level)
                call DestroyEffect(AddSpecialEffect(SFX, GetUnitX(Damage.target), GetUnitY(Damage.target)))
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