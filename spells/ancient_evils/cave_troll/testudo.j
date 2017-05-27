scope Testudo

    globals
        private constant integer SPELL_ID = 'A821'
        private constant integer UNIT_ID = 'UTCT'
        private constant real DELAY = 1.0
        private constant string SFX = "Abilities\\Spells\\Orc\\Voodoo\\VoodooAuraTarget.mdl"
    endglobals

    private function ArmorBonus takes integer level returns integer
        if level == 11 then
            return 300
        endif
        return 30*level
    endfunction

    private function SpellResistBonus takes integer level returns real
        if level == 11 then
            return 0.0  //Spell Immunity will be added instead
        endif
        return 50.0
    endfunction

    private struct SpellBuffUlt extends Buff

        private integer lvl
        private Armor a
        private SpellImmunity si

        private static constant integer RAWCODE = 'B821'
        private static constant integer DISPEL_TYPE = BUFF_NONE
        private static constant integer STACK_TYPE = BUFF_STACK_NONE

        method onRemove takes nothing returns nothing
            local PlayerStat ps = PlayerStat.get(GetOwningPlayer(this.target))
            call SetPlayerAbilityAvailable(ps.player, ps.spell1.id, true)
            call SetPlayerAbilityAvailable(ps.player, ps.spell3.id, true)
            call SetPlayerAbilityAvailable(ps.player, ps.spell4.id, true)
            call this.si.destroy()
            call this.a.destroy()
        endmethod

        method onApply takes nothing returns nothing
            local PlayerStat ps = PlayerStat.get(GetOwningPlayer(this.target))
            set this.lvl = GetUnitAbilityLevel(this.target, SPELL_ID)
            set this.a = Armor.create(this.target, ArmorBonus(this.lvl))
            set this.si = SpellImmunity.create(this.target)
            call SetPlayerAbilityAvailable(ps.player, ps.spell1.id, false)
            call SetPlayerAbilityAvailable(ps.player, ps.spell3.id, false)
            call SetPlayerAbilityAvailable(ps.player, ps.spell4.id, false)
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod

        implement BuffApply
    endstruct

    private struct SpellBuff extends Buff

        private integer lvl
        private Armor a
        private SpellResistance sr

        private static constant integer RAWCODE = 'D821'
        private static constant integer DISPEL_TYPE = BUFF_NONE
        private static constant integer STACK_TYPE = BUFF_STACK_NONE

        method onRemove takes nothing returns nothing
            local PlayerStat ps = PlayerStat.get(GetOwningPlayer(this.target))
            call SetPlayerAbilityAvailable(ps.player, ps.spell1.id, true)
            call SetPlayerAbilityAvailable(ps.player, ps.spell3.id, true)
            call SetPlayerAbilityAvailable(ps.player, ps.spell4.id, true)
            call this.sr.destroy()
            call this.a.destroy()
        endmethod

        method onApply takes nothing returns nothing
            local PlayerStat ps = PlayerStat.get(GetOwningPlayer(this.target))
            set this.lvl = GetUnitAbilityLevel(this.target, SPELL_ID)
            set this.a = Armor.create(this.target, ArmorBonus(this.lvl))
            set this.sr = SpellResistance.create(this.target, SpellResistBonus(this.lvl))
            call SetPlayerAbilityAvailable(ps.player, ps.spell1.id, false)
            call SetPlayerAbilityAvailable(ps.player, ps.spell3.id, false)
            call SetPlayerAbilityAvailable(ps.player, ps.spell4.id, false)
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod

        implement BuffApply
    endstruct

    struct Testudo extends array
        implement Alloc

        private unit caster
        private integer lvl
        private Buff b

        private static Table tb

        private method destroy takes nothing returns nothing
            call thistype.tb.remove(GetHandleId(this.caster))
            call SetUnitAnimation(this.caster, "stand")
            call this.b.remove()
            set this.caster = null
            call this.deallocate()
        endmethod

        private static method expire takes nothing returns nothing
            local thistype this = ReleaseTimer(GetExpiredTimer())
            if this.lvl == 11 then
                set this.b = SpellBuffUlt.add(this.caster, this.caster)
            else
                set this.b = SpellBuff.add(this.caster, this.caster)
            endif
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            local unit u = GetTriggerUnit()
            local integer id = GetHandleId(u)
            if GetUnitTypeId(u) == 'UCav' then
                set this = thistype.allocate()
                set this.caster = u
                set this.lvl = GetUnitAbilityLevel(u, SPELL_ID)
                set thistype.tb[id] = this
                call SetUnitAnimation(this.caster, "death")
                call TimerStart(NewTimerEx(this), DELAY, false, function thistype.expire)
                call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " activates thistype")
            elseif GetUnitTypeId(u) == UNIT_ID and thistype.tb.has(id) then
                call thistype(thistype.tb[id]).destroy()
                call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " deactivates thistype")
            endif
            set u = null
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            set thistype.tb = Table.create()
            call PreloadUnit(UNIT_ID)
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call Root.registerTransform(SPELL_ID, 1.0)
            call Movespeed.registerTransform(SPELL_ID, 1.0)
            call SpellBuff.initialize()
            call SpellBuffUlt.initialize()
            call SystemTest.end()
        endmethod

    endstruct

endscope