scope NatureWrath

    globals
        private constant integer SPELL_ID = 'AHK4'
        private constant string SFX = "Models\\Effects\\NatureWrath.mdx"
    endglobals

    //In percent
    private function BonusPercentDamage takes integer level returns real
        return 1000.0*level
    endfunction

    private function Duration takes integer level returns real
        return 15.0*level
    endfunction

    private struct SpellBuff extends Buff

        private AtkDamagePercent adp

        private static constant integer RAWCODE = 'BHK4'
        private static constant integer DISPEL_TYPE = BUFF_POSITIVE
        private static constant integer STACK_TYPE = BUFF_STACK_NONE

        method onRemove takes nothing returns nothing
            call this.adp.destroy()
        endmethod

        private static method onDamage takes nothing returns nothing
            local thistype this
            if Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.coded then
                set this = Buff.get(Damage.source, Damage.source, thistype.typeid)
                if this > 0 then
                    call this.remove()
                endif
            endif
        endmethod

        method onApply takes nothing returns nothing
            set this.adp = AtkDamagePercent.create(this.target, 0)
        endmethod

        method apply takes real bonus returns nothing
            call this.adp.change(bonus)
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
            call Damage.register(function thistype.onDamage)
        endmethod

        implement BuffApply
    endstruct


    struct NatureWrath extends array

        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local SpellBuff b = SpellBuff.add(caster, caster)
            local integer lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            call DestroyEffect(AddSpecialEffect(SFX, GetUnitX(caster), GetUnitY(caster)))
            call b.apply(0.01*BonusPercentDamage(lvl))
            set b.duration = Duration(lvl)
            call SystemMsg.create(GetUnitName(caster) + " cast thistype")
            set caster = null
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SpellBuff.initialize()
            call SystemTest.end()
        endmethod

    endstruct

endscope