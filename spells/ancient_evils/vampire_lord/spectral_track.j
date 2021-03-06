scope SpectralTrack

    globals
        private constant integer SPELL_ID = 'A133'
    endglobals

    private function Duration takes integer level returns real
        if level == 11 then
            return 10.0
        endif
        return 20.0 + 0.0*level
    endfunction

    private function Radius takes integer level returns real
        if level == 11 then
            return GLOBAL_SIGHT
        endif
        return 250.0*level
    endfunction

    private struct SpellBuff extends Buff

        private integer ctr
        readonly TrueSight ts
        readonly FlySight sight

        private static constant integer RAWCODE = 'B133'
        private static constant integer DISPEL_TYPE = BUFF_POSITIVE
        private static constant integer STACK_TYPE = BUFF_STACK_NONE

        method onRemove takes nothing returns nothing
            call this.ts.destroy()
            call this.sight.destroy()
        endmethod

        method onApply takes nothing returns nothing
            set this.sight = FlySight.create(this.target, 0)
            set this.ts = TrueSight.create(this.target, 0)
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod

        implement BuffApply
    endstruct

    struct SpectralTrack extends array

        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local integer level = GetUnitAbilityLevel(caster, SPELL_ID)
            local real radius = Radius(level)
            local SpellBuff b = SpellBuff.add(caster, caster)
            set b.duration = Duration(level)
            set b.ts.radius = radius
            set b.sight.radius = radius
            set caster = null
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SpellBuff.initialize()
            call SystemTest.end()
        endmethod

    endstruct

endscope