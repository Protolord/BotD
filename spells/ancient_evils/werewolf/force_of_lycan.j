scope ForceOfLycan

    globals
        private constant integer SPELL_ID = 'A212'
        private constant string BUFF_SFX = "Models\\Effects\\ForceOfTheLycan.mdx"
        private constant string BUFF_SFX2 = "Abilities\\Spells\\Other\\HowlOfTerror\\HowlTarget.mdl"
        private constant player HOSTILE_PLAYER = Player(PLAYER_NEUTRAL_AGGRESSIVE)
    endglobals

    private function BonusPercentDamage takes integer level returns real
        if level == 11 then
            return 100.0
        endif
        return 50.0
    endfunction

    private function Duration takes integer level returns real
        if level == 11 then
            return 10.0
        endif
        return 0.5*level
    endfunction

    private struct SpellBuff extends Buff

        private player origOwner
        private effect sfx
        private effect sfx2
        private AtkDamagePercent adp

        private static constant integer RAWCODE = 'D212'
        private static constant integer DISPEL_TYPE = BUFF_NEGATIVE
        private static constant integer STACK_TYPE = BUFF_STACK_NONE

        method onRemove takes nothing returns nothing
            call SetUnitOwner(this.target, this.origOwner, true)
            call this.adp.destroy()
            call DestroyEffect(this.sfx)
            call DestroyEffect(this.sfx2)
            set this.sfx = null
            set this.sfx2 = null
            set this.origOwner = null
        endmethod

        method onApply takes nothing returns nothing
            local group g = CreateGroup()
            local unit u
            set this.origOwner = GetOwningPlayer(this.target)
            set this.sfx = AddSpecialEffectTarget(BUFF_SFX, this.target, "origin")
            set this.sfx2 = AddSpecialEffectTarget(BUFF_SFX2, this.target, "chest")
            set this.adp = AtkDamagePercent.create(this.target, BonusPercentDamage(GetUnitAbilityLevel(this.source, SPELL_ID))/100)
            call GroupEnumUnitsInRange(g, GetUnitX(this.target), GetUnitY(this.target), 800, null)
            loop
                set u = FirstOfGroup(g)
                exitwhen u == null
                call GroupRemoveUnit(g, u)
                if u != this.source then
                    exitwhen true
                endif
            endloop
            call SetUnitOwner(this.target, HOSTILE_PLAYER, false)
            call IssueTargetOrderById(this.target, ORDER_attack, u)
            call DestroyGroup(g)
            set u = null
            set g = null
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod

        implement BuffApply
    endstruct

    struct ForceOfLycan extends array

        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local real x = GetUnitX(caster)
            local real y = GetUnitY(caster)
            local integer lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            local SpellBuff b = SpellBuff.add(caster, GetSpellTargetUnit())
            set b.duration = Duration(lvl)
            call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Other\\HowlOfTerror\\HowlCaster.mdl", x, y))
            set caster = null
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype on " + GetUnitName(GetSpellTargetUnit()))
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SpellBuff.initialize()
            call SystemTest.end()
        endmethod

    endstruct

endscope