scope ShadowsOfCorruption

    //Configuration
    globals
        private constant integer SPELL_ID = 'A123'
        private constant integer SPELL_BUFF = 'a123'
    endglobals

    private function SlowEffect takes integer level returns real
        return -0.50 + 0.0*level
    endfunction

    private function SlowDuration takes integer level returns real
        if level == 11 then
            return 15.0
        endif
        return 5.0 + 0.5*level
    endfunction

    private function BonusSpeed takes integer level returns real
        if level == 11 then
            return 0.3
        endif
        return 0.02*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction

    private struct SpellBuff extends Buff

        public Movespeed ms

        private static constant integer RAWCODE = 'D123'
        private static constant integer DISPEL_TYPE = BUFF_NEGATIVE
        private static constant integer STACK_TYPE = BUFF_STACK_PARTIAL

        method onRemove takes nothing returns nothing
            call this.ms.destroy()
        endmethod

        method onApply takes nothing returns nothing
            set this.ms = Movespeed.create(this.target, 0, 0)
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod

        implement BuffApply
    endstruct

    struct ShadowsOfCorruption extends array

        private unit caster
        private integer lvl
        private Invisible inv
        private Movespeed ms

        private static Table tb


        private method remove takes nothing returns nothing
            call thistype.tb.remove(GetHandleId(this.caster))
            call this.inv.destroy()
            call this.ms.destroy()
            set this.caster = null
            call this.destroy()
        endmethod

        private static method onDamage takes nothing returns nothing
            local integer id = GetHandleId(Damage.source)
            local SpellBuff b
            local integer lvl
             if Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.coded and thistype.tb.has(id) then
                if TargetFilter(Damage.target, GetOwningPlayer(Damage.source)) then
                    set lvl = thistype(thistype.tb[id]).lvl
                    set b = SpellBuff.add(Damage.source, Damage.target)
                    set b.duration = SlowDuration(lvl)
                    call b.ms.change(SlowEffect(lvl), 0)
                endif
                call UnitRemoveAbility(Damage.source, SPELL_BUFF)
            endif
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
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SpellBuff.initialize()
            set thistype.tb = Table.create()
            call SystemTest.end()
        endmethod

    endstruct

endscope