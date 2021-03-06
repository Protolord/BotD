scope Bloodlust

    globals
        private constant integer SPELL_ID = 'A824'
        private constant string BUFF_SFX = ""
        private constant real LIMIT = 500.0
    endglobals

    private function Duration takes integer level returns real
        if level == 11 then
            return 30.0
        endif
        return 10.0
    endfunction

    //Speed Growth when unit is hit
    private function UnitGrowth takes integer level returns real
        if level == 11 then
            return 0.05 //5%
        endif
        return 0.005*level //0.5%
    endfunction

    //Speed Growth when building is hit
    private function StructureGrowth takes integer level returns real
        if level == 11 then
            return 0.005 //0.5%
        endif
        return 0.0005*level //0.05%
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p)
    endfunction

    private struct SpellBuff extends Buff

        public real bonus
        readonly Atkspeed as
        readonly Movespeed ms

        private static constant integer RAWCODE = 'B824'
        private static constant integer DISPEL_TYPE = BUFF_POSITIVE
        private static constant integer STACK_TYPE = BUFF_STACK_NONE

        method onRemove takes nothing returns nothing
            call this.as.destroy()
            call this.ms.destroy()
        endmethod

        method onApply takes nothing returns nothing
            set this.bonus = 0
            set this.as = Atkspeed.create(this.target, 0)
            set this.ms = Movespeed.create(this.target, 0, 0)
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod

        implement BuffApply
    endstruct

    struct Bloodlust extends array

        private static method onDamage takes nothing returns nothing
            local integer level = GetUnitAbilityLevel(Damage.source, SPELL_ID)
            local SpellBuff b
            if Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.coded and level > 0 and TargetFilter(Damage.target, GetOwningPlayer(Damage.source)) then
                set b = SpellBuff.add(Damage.source, Damage.source)
                set b.duration = Duration(level)
                if IsUnitType(Damage.target, UNIT_TYPE_STRUCTURE) then
                    set b.bonus = b.bonus + StructureGrowth(level)
                else
                    set b.bonus = b.bonus + UnitGrowth(level)
                endif
                if b.bonus > LIMIT then
                    set b.bonus = LIMIT
                endif
                call b.as.change(b.bonus)
                call b.ms.change(b.bonus, 0)
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