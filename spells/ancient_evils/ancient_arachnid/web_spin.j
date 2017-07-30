scope WebSpin

    globals
        private constant integer SPELL_ID = 'A432'
        private constant integer SPELL_BUFF = 'B432'
        private constant integer SPELL_DEBUFF = 'D432'
        private constant string WEB_MODEL = "Models\\Effects\\WebSpin.mdx"
    endglobals

    private function Radius takes integer level returns real
        return 0.0*level + 350.0
    endfunction

    private function SightRadius takes integer level returns real
        if level == 11 then
            return GLOBAL_SIGHT
        endif
        return 350.0
    endfunction

    private function Slow takes integer level returns real
        return 0.0*level + 0.9
    endfunction

    private function Duration takes integer level returns real
        if level == 11 then
            return 60.0
        endif
        return 2.0*level + 10.0
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction

    private struct Bonus extends Buff

        readonly Movespeed ms

        private static constant integer RAWCODE = 'B432'
        private static constant integer DISPEL_TYPE = BUFF_POSITIVE
        private static constant integer STACK_TYPE = BUFF_STACK_FULL //do not change

        method onRemove takes nothing returns nothing
            call this.ms.destroy()
        endmethod

        method onApply takes nothing returns nothing
            set this.ms = Movespeed.create(this.target, 999.9, 999)
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod

        implement BuffApply
    endstruct

    private struct SpellBuff extends Buff

        readonly Movespeed ms

        private static constant integer RAWCODE = 'D432'
        private static constant integer DISPEL_TYPE = BUFF_NONE
        private static constant integer STACK_TYPE = BUFF_STACK_FULL

        method onRemove takes nothing returns nothing
            call this.ms.destroy()
        endmethod

        method onApply takes nothing returns nothing
            set this.ms = Movespeed.create(this.target, 0, 0)
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod

        implement BuffApply
    endstruct

    struct WebSpin extends array

        private unit caster
        private unit dummy
        private player owner
        private effect sfx
        private group g
        private real radius
        private real duration
        private real x
        private real y
        private real slow
        private fogmodifier fm
        private Bonus bonus
        private TrueSight ts
        private Table tb

        private static thistype global
        private static group enumG

        private method remove takes nothing returns nothing
            local unit u
            loop
                set u = FirstOfGroup(this.g)
                exitwhen u == null
                call GroupRemoveUnit(this.g, u)
                call Buff(this.tb[GetHandleId(u)]).remove()
            endloop
            if this.bonus > 0 then
                call this.bonus.remove()
                set this.bonus = 0
            endif
            call this.tb.destroy()
            call this.ts.destroy()
            call DestroyFogModifier(this.fm)
            call ReleaseGroup(this.g)
            call DummyAddRecycleTimer(this.dummy, 3.0)
            call SetUnitVertexColor(this.dummy, 255, 255, 255, 75)
            call DestroyEffect(this.sfx)
            set this.fm = null
            set this.g = null
            set this.caster = null
            set this.dummy = null
            set this.sfx = null
            call this.destroy()
        endmethod

        private static method picked takes nothing returns nothing
            local unit u = GetEnumUnit()
            if not TargetFilter(u, thistype.global.owner) or not IsUnitInRangeXY(u, thistype.global.x, thistype.global.y, thistype.global.radius) then
                call GroupRemoveUnit(thistype.global.g, u)
                if Buff.has(thistype.global.caster, u, SpellBuff.typeid) then
                    call Buff(thistype.global.tb[GetHandleId(u)]).remove()
                endif
            endif
            set u = null
        endmethod

        implement CTL
            local unit u
            local SpellBuff b
        implement CTLExpire
            set this.duration = this.duration - CTL_TIMEOUT
            if this.duration > 0 then
                call GroupEnumUnitsInRange(thistype.enumG, this.x, this.y, this.radius + MAX_COLLISION_SIZE, null)
                set thistype.global = this
                loop
                    set u = FirstOfGroup(thistype.enumG)
                    exitwhen u == null
                    call GroupRemoveUnit(thistype.enumG, u)
                    if IsUnitInRangeXY(u, this.x, this.y, this.radius) and TargetFilter(u, this.owner) and not IsUnitInGroup(u, this.g) then
                        set b = SpellBuff.add(this.caster, u)
                        call b.ms.change(this.slow, 0)
                        set this.tb[GetHandleId(u)] = b
                        call GroupAddUnit(this.g, u)
                    endif
                endloop
                call ForGroup(this.g, function thistype.picked)
                if this.bonus == 0 then
                    if FirstOfGroup(this.g) != null then
                        set this.bonus = Bonus.add(this.caster, this.caster)
                    endif
                else
                    if FirstOfGroup(this.g) == null then
                        call this.bonus.remove()
                        set this.bonus = 0
                    endif
                endif
            else
                call this.remove()
            endif
        implement CTLEnd

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.create()
            local integer lvl
            set this.caster = GetTriggerUnit()
            set this.g = NewGroup()
            set this.owner = GetTriggerPlayer()
            set lvl = GetUnitAbilityLevel(this.caster, SPELL_ID)
            set this.x = GetUnitX(this.caster)
            set this.y = GetUnitY(this.caster)
            set this.radius = Radius(lvl)
            set this.duration = Duration(lvl)
            set this.slow = -Slow(lvl)
            set this.dummy = GetRecycledDummyAnyAngle(this.x, this.y, 0)
            set this.sfx = AddSpecialEffectTarget(WEB_MODEL, this.dummy, "origin")
            set this.tb = Table.create()
            set this.fm = CreateFogModifierRadius(this.owner, FOG_OF_WAR_VISIBLE, this.x, this.y, RMaxBJ(SightRadius(lvl), 385), true, false)
            set this.ts = TrueSight.create(this.dummy, SightRadius(lvl))
            call FogModifierStart(this.fm)
            call SetUnitScale(this.dummy, this.radius/100.0 + 0.2, 0, 0)
            call SetUnitVertexColor(this.dummy, 255, 255, 255, 125)
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            set thistype.enumG = CreateGroup()
            call SpellBuff.initialize()
            call Bonus.initialize()
            call SystemTest.end()
        endmethod

    endstruct

endscope