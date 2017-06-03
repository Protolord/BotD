scope FrogTransformation

    globals
        private constant integer SPELL_ID = 'AH71'
        private constant integer UNIT_ID = 'HT07'
        private constant string SFX = "Abilities\\Spells\\Human\\Polymorph\\PolyMorphDoneGround.mdl"
    endglobals

    private function MoveBonus takes integer level returns real
        return 0.5 + 0.0*level
    endfunction

    private function Chance takes integer level returns real
        return 0.9 + 0.0*level
    endfunction

    private function Duration takes integer level returns real
        return 1.0*level
    endfunction

    private struct SpellBuff extends Buff

        private Movespeed ms
        private SpellBlock sb

        private static constant integer RAWCODE = 'BH71'
        private static constant integer DISPEL_TYPE = BUFF_NONE
        private static constant integer STACK_TYPE = BUFF_STACK_FULL

        method onRemove takes nothing returns nothing
            call this.ms.destroy()
            call this.sb.destroy()
        endmethod

        private static method onBlock takes nothing returns nothing
            local SpellBlock sb = SpellBlock.get()
            local texttag text = CreateTextTag()
            call SetTextTagPos(text, GetUnitX(sb.u), GetUnitY(sb.u), GetUnitFlyHeight(sb.u) + 50)
            call SetTextTagText(text, "|cffff0000Miss!|r", 0.0225)
            call SetTextTagVelocity(text, 0, 0.03)
            call SetTextTagPermanent(text, false)
            call SetTextTagFadepoint(text, 1)
            call SetTextTagLifespan(text, 3)
            set text = null
        endmethod

        method onApply takes nothing returns nothing
            local integer lvl = GetUnitAbilityLevel(this.target, SPELL_ID)
            set this.ms = Movespeed.create(this.target, MoveBonus(lvl), 0)
            set this.sb = SpellBlock.create(this.target, Chance(lvl), 0)
            call this.sb.registerProc(function thistype.onBlock)
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod

        implement BuffApply
    endstruct

    struct FrogTransformation extends array

        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local integer lvl
            local SpellBuff b
            call DestroyEffect(AddSpecialEffect(SFX, GetUnitX(caster), GetUnitY(caster)))
            if GetUnitTypeId(caster) != UNIT_ID then
                set lvl = GetUnitAbilityLevel(caster, SPELL_ID)
                set b = SpellBuff.add(caster, caster)
                set b.duration = Duration(lvl)
                call SystemMsg.create(GetUnitName(caster) + " cast thistype")
            endif
            set caster = null
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call Root.registerTransform(SPELL_ID, 0.0)
            call Movespeed.registerTransform(SPELL_ID, 0.0)
            call PreloadUnit(UNIT_ID)
            call SpellBuff.initialize()
            call SystemTest.end()
        endmethod

    endstruct

endscope