scope Cocoon

    globals
        private constant integer SPELL_ID = 'A414'
        private constant integer UNIT_ID = 'uCoc'
        private constant integer TRANSFORM_ID = 'T414'
    endglobals

    private function UnitHP takes integer level returns real
        if level == 11 then
            return 30.0
        endif
        return 1.0*level + 5.0
    endfunction

    private struct SpellBuff extends Buff

        readonly Atkspeed as
        private Root r

        private static constant integer RAWCODE = 'D414'
        private static constant integer DISPEL_TYPE = BUFF_NEGATIVE
        private static constant integer STACK_TYPE = BUFF_STACK_FULL //do not change

        method onRemove takes nothing returns nothing
            call this.as.destroy()
            call this.r.destroy()
        endmethod

        method onApply takes nothing returns nothing
            set this.as = Atkspeed.create(this.target, 0)
            set this.r = Root.create(this.target)
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod

        implement BuffApply
    endstruct

    struct Cocoon extends array

        private unit cocoon
        private unit target
        private real height
        private texttag tt
        private SpellBuff b

        private static Table tb

        private method remove takes nothing returns nothing
            local integer id = GetHandleId(this.target)
            set thistype.tb[id] = thistype.tb[id] - 1
            call this.b.remove()
            call DestroyTextTag(this.tt)
            if UnitAlive(this.cocoon) then
                call KillUnit(this.cocoon)
            endif
            set this.cocoon = null
            set this.target = null
            set this.tt = null
            call this.destroy()
        endmethod

        implement CTL
            local real x
            local real y
        implement CTLExpire
            if UnitAlive(this.cocoon) and UnitAlive(this.target) then
                set x = GetUnitX(this.target)
                set y = GetUnitY(this.target)
                call SetUnitPosition(this.cocoon, x, y)
                call SetTextTagText(this.tt, "|cff99ff22Attacks Left: " + I2S(R2I(GetWidgetLife(this.cocoon))) + "|r", 0.020)
                call SetTextTagPos(this.tt, x - 50, y, this.height)
                call this.b.as.change(-1 + GetWidgetLife(this.target)/GetUnitState(this.target, UNIT_STATE_MAX_LIFE))
            else
                call this.remove()
            endif
        implement CTLEnd

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.create()
            local unit caster = GetTriggerUnit()
            local integer lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            local real hp = UnitHP(lvl)
            local player owner = GetTriggerPlayer()
            local integer id
            local real x
            local real y
            set this.target = GetSpellTargetUnit()
            set id = GetHandleId(this.target)
            set this.b = SpellBuff.add(caster, this.target)
            set this.tt = CreateTextTag()
            set this.cocoon = CreateUnit(owner, 'dumi', GetUnitX(this.target), GetUnitY(this.target), GetRandomReal(0, 360))
            call Unselectable(this.cocoon, TRANSFORM_ID)
            call SetUnitMaxState(this.cocoon, UNIT_STATE_MAX_LIFE, hp)
            call SetWidgetLife(this.cocoon, hp)
            call IssueTargetOrderById(this.target, ORDER_attack, this.cocoon)
            call SetUnitVertexColor(this.cocoon, 255, 255, 255, 150)
            set this.height = 50*thistype.tb[id] + 250
            set thistype.tb[id] = thistype.tb[id] + 1
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype on " + GetUnitName(GetSpellTargetUnit()))
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            set thistype.tb = Table.create()
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call PreloadUnit(UNIT_ID)
            call SpellBuff.initialize()
            call SystemTest.end()
        endmethod

    endstruct

endscope