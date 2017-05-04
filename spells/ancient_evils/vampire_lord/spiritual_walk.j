scope SpiritualWalk

    //Configuration
    globals
        private constant integer SPELL_ID = 'A122'
        private constant integer SPELL_BUFF = 'a122'
    endglobals

    private function StealMana takes integer level returns real
        if level == 11 then
            return 0.5
        endif
        return 0.15 + 0.02*level
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

    struct SpiritualWalk extends array

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
            local real amount
            local real mana
            if Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.coded and thistype.tb.has(id) then
                if TargetFilter(Damage.target, GetOwningPlayer(Damage.source)) then
                    set mana = GetUnitState(Damage.target, UNIT_STATE_MANA)
                    set amount = StealMana(thistype(thistype.tb[id]).lvl)*GetUnitState(Damage.target, UNIT_STATE_MAX_MANA)
                    if mana < amount then
                        set amount = mana
                    endif
                    if amount > 0 then
                        call SetUnitState(Damage.target, UNIT_STATE_MANA, mana - amount)
                        call SetUnitState(Damage.source, UNIT_STATE_MANA, GetUnitState(Damage.source, UNIT_STATE_MANA) + amount)
                        call FloatingTextTag("|cff0099ff-" + I2S(R2I(amount)) + "|r", Damage.target, 2.5)
                    endif
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
            set thistype.tb = Table.create()
            call SystemTest.end()
        endmethod

    endstruct

endscope