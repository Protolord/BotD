scope Dissimulation

    //Configuration
    globals
        private constant integer SPELL_ID = 'A421'
        private constant integer SPELL_BUFF = 'a421'
    endglobals

    private function BonusSpeed takes integer level returns real
        return 0.0*level + 0.25
    endfunction

    private function SilenceDuration takes integer level returns real
        if level == 11 then
            return 20.0
        endif
        return 1.0*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction
    //End configuration

    struct Dissimulation extends array

        private unit caster
        private integer lvl
        private Movespeed ms
        private Invisible inv

        private static Table tb

        private static method onDamage takes nothing returns nothing
            local integer id = GetHandleId(Damage.source)
            if Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.coded and thistype.tb.has(id) then
                if TargetFilter(Damage.target, GetOwningPlayer(Damage.source)) then
                    call Silence.create(Damage.target, SilenceDuration(thistype(thistype.tb[id]).lvl))
                endif
                call UnitRemoveAbility(Damage.source, SPELL_BUFF)
            endif
        endmethod

        private method remove takes nothing returns nothing
            call thistype.tb.remove(GetHandleId(this.caster))
            call this.inv.destroy()
            call this.ms.destroy()
            set this.caster = null
            call this.destroy()
        endmethod

        implement CTLExpire
            if GetUnitAbilityLevel(this.caster, SPELL_BUFF) == 0 then
                call this.remove()
            endif
        implement CTLEnd

        private static method onCast takes nothing returns nothing
            local integer id = GetHandleId(GetTriggerUnit())
            local thistype this
            if thistype.tb.has(id) then
                set this = thistype.tb[id]
            else
                set this = thistype.create()
                set this.caster = GetTriggerUnit()
                set this.inv = Invisible.create(this.caster, 0)
                set thistype.tb[id] = this
            endif
            set this.lvl = GetUnitAbilityLevel(this.caster, SPELL_ID)
            set this.ms = Movespeed.create(this.caster, BonusSpeed(this.lvl), 0)
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call Damage.register(function thistype.onDamage)
            set thistype.tb = Table.create()
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SystemTest.end()
        endmethod

    endstruct

endscope