scope Reaper

    globals
        private constant integer SPELL_ID = 'A712'
    endglobals

    private function Duration takes integer level returns real
        return 5.0 + 0.0*level
    endfunction

    private function DamageGrowth takes integer level returns real
        return 30.0 + 0.0*level
    endfunction

    private function DamageMax takes integer level returns real
        if level == 11 then
            return 2000.0
        endif
        return 50.0*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE)
    endfunction

    private struct SpellBuff extends Buff

        private real bonus
        private AtkDamage ad

        private static constant integer RAWCODE = 'B712'
        private static constant integer DISPEL_TYPE = BUFF_POSITIVE
        private static constant integer STACK_TYPE = BUFF_STACK_NONE

        method onRemove takes nothing returns nothing
            call this.ad.destroy()
        endmethod

        method onApply takes nothing returns nothing
            set this.bonus = 0
            set this.ad = AtkDamage.create(this.target, 0)
        endmethod

        method reapply takes integer level returns nothing
            set this.duration = Duration(level)
            set this.bonus = this.bonus + DamageGrowth(level)
            if this.bonus > DamageMax(level) then
                set this.bonus = DamageMax(level)
            endif
            call this.ad.change(this.bonus)
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod

        implement BuffApply
    endstruct

    struct Reaper extends array

        private static method onDamage takes nothing returns nothing
            local integer level = GetUnitAbilityLevel(Damage.source, SPELL_ID)
            local SpellBuff b
            if Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.coded and level > 0 and TargetFilter(Damage.target, GetOwningPlayer(Damage.source)) then
                set b = SpellBuff.add(Damage.source, Damage.source)
                call b.reapply(level)
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