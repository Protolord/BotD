scope Prowl

    //Configuration
    globals
        private constant integer SPELL_ID = 'A221'
        private constant integer PROWL_BUFF = 'a221'
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_SIEGE
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_NORMAL
    endglobals

    private function DamageDealt takes integer level returns real
        if level == 11 then
            return 2500.0
        endif
        return 125.0*level
    endfunction

    private function BonusSpeed takes integer level returns real
        return -0.2
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p)
    endfunction

    struct Prowl extends array

        private unit caster
        private integer lvl
        private Movespeed ms
        private Invisible inv

        private static Table tb
        private static trigger trg

        private method remove takes nothing returns nothing
            call this.inv.destroy()
            call thistype.tb.remove(GetHandleId(this.caster))
            call this.ms.destroy()
            set this.caster = null
            call this.destroy()
        endmethod

        private static method onDamage takes nothing returns boolean
            local integer id = GetHandleId(Damage.source)
            local real dmg
            if Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.coded and thistype.tb.has(id) then
                if TargetFilter(Damage.target, GetOwningPlayer(Damage.source)) then
                    set dmg = DamageDealt(thistype(thistype.tb[id]).lvl)
                    call DisableTrigger(thistype.trg)
                    call Damage.apply(Damage.source, Damage.target, dmg, ATTACK_TYPE, DAMAGE_TYPE)
                    call EnableTrigger(thistype.trg)
                    call FloatingTextSplat(Element.string(DAMAGE_ELEMENT_NORMAL) + "+" + I2S(R2I(dmg + 0.5)) + "|r", Damage.target, 1.0).setVisible(GetLocalPlayer() == GetOwningPlayer(Damage.source))
                endif
                call UnitRemoveAbility(Damage.source, PROWL_BUFF)
            endif
            return false
        endmethod

        implement CTLExpire
            if GetUnitAbilityLevel(this.caster, PROWL_BUFF) == 0 then
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
            set thistype.tb = Table.create()
            set thistype.trg = CreateTrigger()
            call Damage.registerTrigger(thistype.trg)
            call TriggerAddCondition(thistype.trg, function thistype.onDamage)
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SystemTest.end()
        endmethod

    endstruct

endscope