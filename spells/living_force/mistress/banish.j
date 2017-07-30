scope Banish

    globals
        private constant integer SPELL_ID = 'AHC2'
        private constant string MODEL = "Models\\Effects\\BanishMissile.mdx"
    endglobals

    private function MoveSlow takes integer level returns real
        return 0.5 + 0.0*level
    endfunction

    //In percent
    private function SpellAmplify takes integer level returns real
        return 40.0*level
    endfunction

    private function Speed takes integer level returns real
        return 1500.0 + 0.0*level
    endfunction

    private function Duration takes integer level returns real
        if level == 11 then
            return 10.0
        endif
        return 0.5*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction

    private struct SpellBuff extends Buff

        private Ethereal et
        private Movespeed ms
        private SpellResistance sr

        private static constant integer RAWCODE = 'DHC2'
        private static constant integer DISPEL_TYPE = BUFF_NEGATIVE
        private static constant integer STACK_TYPE = BUFF_STACK_PARTIAL

        method onRemove takes nothing returns nothing
            call this.sr.destroy()
            call this.ms.destroy()
            call this.et.destroy()
        endmethod

        method onApply takes nothing returns nothing
            set this.ms = Movespeed.create(this.target, 0, 0)
            set this.et = Ethereal.create(this.target)
            set this.sr = SpellResistance.create(this.target, 0)
        endmethod

        method reapply takes integer level returns nothing
            call this.ms.change(-MoveSlow(level), 0)
            call this.sr.change(-0.01*SpellAmplify(level))
            set this.duration = Duration(level)
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod

        implement BuffApply
    endstruct

    struct Banish extends array

        private unit caster
        private unit target
        private integer lvl
        private player owner
        private Missile m

        private method destroy takes nothing returns nothing
            call this.m.destroy()
            set this.caster = null
            set this.target = null
            set this.owner = null
        endmethod

        private static method onHit takes nothing returns nothing
            local thistype this = Missile.getHit()
            local SpellBuff b
            if SpellBlock.has(this.target) then
                call this.m.show(false)
            elseif TargetFilter(this.target, this.owner) then
                set b = SpellBuff.add(this.caster, this.target)
                call b.reapply(this.lvl)
            endif
            call this.destroy()
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype(Missile.create())
            set this.caster = GetTriggerUnit()
            set this.owner = GetTriggerPlayer()
            set this.target = GetSpellTargetUnit()
            set this.lvl = GetUnitAbilityLevel(this.caster, SPELL_ID)
            set this.m = Missile(this)
            set this.m.sourceUnit = this.caster
            set this.m.targetUnit = this.target
            set this.m.model = MODEL
            set this.m.scale = 0.5
            set this.m.speed = Speed(this.lvl)
            call this.m.registerOnHit(function thistype.onHit)
            call this.m.launch()
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