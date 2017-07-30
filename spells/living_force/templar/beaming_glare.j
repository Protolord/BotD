scope BeamingGlare

    globals
        private constant integer SPELL_ID   = 'AHJ4'
        private constant real TIMEOUT = 0.1
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
        private constant string LIGHTNING_CODE = "BMGL"
        private constant string SFX_BUFF = "Models\\Effects\\BeamingGlareBuff.mdx"
    endglobals

    private function Duration takes integer level returns real
        return 7.0 + 4.0*level
    endfunction

    private function Range takes integer level returns real
        return 500.0 + 0.0*level
    endfunction

    private function InitialDamage takes integer level returns real
        return 50.0 + 0.0*level
    endfunction

    private struct SpellBuff extends Buff
        implement List

        private real dmg
        private real range
        private timer t
        private effect sfx
        private Lightning l

        private static constant integer RAWCODE = 'DHJ4'
        private static constant integer DISPEL_TYPE = BUFF_NEGATIVE
        private static constant integer STACK_TYPE = BUFF_STACK_FULL

        method onRemove takes nothing returns nothing
            call this.pop()
            call ReleaseTimer(this.t)
            call DestroyEffect(this.sfx)
            set this.l.duration = 0.5
            set this.t = null
            set this.sfx = null
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this = thistype(0).next
            loop
                exitwhen this == 0
                if not IsUnitInRange(this.source, this.target, this.range) then
                    call this.remove()
                endif
                set this = this.next
            endloop
        endmethod

        private static method onInterval takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            call Damage.element.apply(this.source, this.target, this.dmg, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_LIGHT)
            set this.dmg = 2*this.dmg
        endmethod

        method onApply takes nothing returns nothing
            local integer lvl = GetUnitAbilityLevel(this.source, SPELL_ID)
            set this.t = NewTimerEx(this)
            set this.dmg = InitialDamage(lvl)
            set this.range = Range(lvl)
            set this.duration =  Duration(lvl)
            set this.l = Lightning.createUnits(LIGHTNING_CODE, this.source, this.target)
            call this.l.startColor(1.0, 1.0, 1.0, 1.0)
            call this.l.endColor(1.0, 1.0, 1.0, 0.1)
            set this.sfx = AddSpecialEffectTarget(SFX_BUFF, this.source, "origin")
            call TimerStart(this.t, 1.0, true, function thistype.onInterval)
            call this.push(TIMEOUT)
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod

        implement BuffApply
    endstruct

    struct BeamingGlare extends array

        private static method onCast takes nothing returns nothing
            call SpellBuff.add(GetTriggerUnit(), GetSpellTargetUnit())
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