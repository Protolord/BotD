scope StrongMind

    globals
        private constant integer SPELL_ID = 'AHI3'
        private constant string MODEL = "Models\\Effects\\StrongMindMissile.mdx"
    endglobals

    private function IntelligenceSteal takes integer level returns integer
        return level
    endfunction

    private function Duration takes integer level returns real
        return 60.0 + 0.0*level
    endfunction

    private function Speed takes integer level returns real
        return 1250.0 + 0.0*level
    endfunction

    private struct SpellBuff extends Buff

        private integer intGain
        private static Table tb
        private static Table bd

        private static constant integer RAWCODE = 'BHI3'
        private static constant integer DISPEL_TYPE = BUFF_POSITIVE
        private static constant integer STACK_TYPE = BUFF_STACK_FULL

        method onRemove takes nothing returns nothing
            local integer id = GetHandleId(this.target)
            call SetHeroInt(this.target, GetHeroInt(this.target, false) - this.intGain, true)
            set thistype.tb[id] = thistype.tb[id] - this.intGain
            if thistype.tb[id] == 0 then
                call thistype.tb.remove(id)
                call BuffDisplay(thistype.bd[id]).destroy()
                call thistype.bd.remove(id)
            else
                set BuffDisplay(thistype.bd[id]).value = "|iSTRONG_MIND|i+" + I2S(thistype.tb[id])
            endif
        endmethod

        method apply takes integer intToSteal returns nothing
            local integer id = GetHandleId(this.target)
            set this.intGain = intToSteal
            call SetHeroInt(this.target, GetHeroInt(this.target, false) + intToSteal, true)
            if not thistype.tb.has(id) then
                set thistype.bd[id] = BuffDisplay.create(this.target)
            endif
            set thistype.tb[id] = thistype.tb[id] + intToSteal
            set BuffDisplay(thistype.bd[id]).value = "|iSTRONG_MIND|i+" + I2S(thistype.tb[id])
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
            set thistype.tb = Table.create()
            set thistype.bd = Table.create()
        endmethod

        implement BuffApply
    endstruct

    private struct SpellDeBuff extends Buff

        readonly integer intLoss
        private static Table tb
        private static Table bd

        private static constant integer RAWCODE = 'DHI3'
        private static constant integer DISPEL_TYPE = BUFF_NEGATIVE
        private static constant integer STACK_TYPE = BUFF_STACK_FULL

        method onRemove takes nothing returns nothing
            local integer id = GetHandleId(this.target)
            call SetHeroInt(this.target, GetHeroInt(this.target, false) + this.intLoss, true)
            set thistype.tb[id] = thistype.tb[id] - this.intLoss
            if thistype.tb[id] == 0 then
                call thistype.tb.remove(id)
                call BuffDisplay(thistype.bd[id]).destroy()
                call thistype.bd.remove(id)
            else
                set BuffDisplay(thistype.bd[id]).value = "|iSTRONG_MIND|i-" + I2S(thistype.tb[id])
            endif
        endmethod

        method apply takes integer intToSteal returns nothing
            local integer id = GetHandleId(this.target)
            set this.intLoss = intToSteal
            call SetHeroInt(this.target, GetHeroInt(this.target, false) - this.intLoss, true)
            if not thistype.tb.has(id) then
                set thistype.bd[id] = BuffDisplay.create(this.target)
            endif
            set thistype.tb[id] = thistype.tb[id] + intToSteal
            set BuffDisplay(thistype.bd[id]).value = "|iSTRONG_MIND|i-" + I2S(thistype.tb[id])
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
            set thistype.tb = Table.create()
            set thistype.bd = Table.create()
        endmethod

        implement BuffApply
    endstruct

    struct StrongMind extends array

        private unit caster
        private unit target
        private integer lvl
        private integer intSteal
        private player owner
        private SpellDeBuff db
        private Missile m

        private method destroy takes nothing returns nothing
            call this.m.destroy()
            set this.caster = null
            set this.target = null
            set this.owner = null
        endmethod

        private static method onHit takes nothing returns nothing
            local thistype this = Missile.getHit()
            local SpellBuff b = SpellBuff.add(this.caster, this.caster)
            call b.apply(this.intSteal)
            set b.duration = this.db.duration
            call FloatingTextSplat("+" + I2S(this.intSteal) + "|iATTRIBUTE_INT|i", this.caster).setVisible(IsPlayerAlly(this.owner, GetLocalPlayer()))
            call this.destroy()
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype(Missile.create())
            local integer intToSteal
            set this.caster = GetTriggerUnit()
            set this.target = GetSpellTargetUnit()
            set this.owner = GetTriggerPlayer()
            set this.lvl = GetUnitAbilityLevel(this.caster, SPELL_ID)
            set this.db = SpellDeBuff.add(this.caster, this.target)
            set intToSteal = IntelligenceSteal(this.lvl)
            if GetHeroInt(this.target, true) - intToSteal >= 0 then
                set this.intSteal = intToSteal
            else
                set this.intSteal = GetHeroInt(this.target, true)
            endif
            call this.db.apply(this.intSteal)
            set this.db.duration = Duration(this.lvl)
            set this.m = Missile(this)
            set this.m.sourceUnit = this.target
            set this.m.targetUnit = this.caster
            set this.m.model = MODEL
            set this.m.speed = Speed(this.lvl)
            call this.m.registerOnHit(function thistype.onHit)
            call this.m.launch()
            call FloatingTextSplat("-" + I2S(this.intSteal) + "|iATTRIBUTE_INT|i", this.target).setVisible(IsUnitVisible(this.target, GetLocalPlayer()))
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod


        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SpellBuff.initialize()
            call SpellDeBuff.initialize()
            call SystemTest.end()
        endmethod

    endstruct

endscope