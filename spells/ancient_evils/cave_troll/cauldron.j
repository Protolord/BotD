scope Cauldron

    globals
        private constant integer SPELL_ID = 'A833'
        private constant string MODEL = "Models\\Effects\\Cauldron.mdx"
        private constant string BUFF_SFX = "Models\\Effects\\CauldronTarget.mdx"
        private constant real TIMEOUT = 0.05
        private constant integer TRUE_SIGHT_ABILITY = 'ATSS'
        private constant real RADIUS = 200.0
    endglobals

    private function Radius takes integer level returns real
        if level == 11 then
            return 2000.0
        endif
        return 1000.0
    endfunction

    private function Duration takes integer level returns real
        if level == 11 then
            return 340.0
        endif
        return 240 + 10.0*level
    endfunction

    private function DebuffDuration takes integer level returns real
        if level == 11 then
            return 60.0
        endif
        return 3.0*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction

    private struct SpellBuff extends Buff
        implement List

        private unit dummy

        private static constant integer RAWCODE = 'D833'
        private static constant integer DISPEL_TYPE = BUFF_NEGATIVE
        private static constant integer STACK_TYPE = BUFF_STACK_PARTIAL

        method onRemove takes nothing returns nothing
            call this.pop()
            call UnitClearBonus(this.dummy, BONUS_SIGHT_RANGE)
            call UnitRemoveAbility(this.dummy, TRUE_SIGHT_ABILITY)
            call RecycleDummy(this.dummy)
            set this.dummy = null
        endmethod

        static method onPeriod takes nothing returns nothing
            local thistype this = thistype(0).next
            loop
                exitwhen this == 0
                call SetUnitX(this.dummy, GetUnitX(this.target))
                call SetUnitY(this.dummy, GetUnitY(this.target))
                set this = this.next
            endloop
        endmethod

        method onApply takes nothing returns nothing
            set this.dummy = GetRecycledDummyAnyAngle(GetUnitX(this.target), GetUnitY(this.target), 0)
            call SetUnitOwner(this.dummy, GetOwningPlayer(this.source), false)
            call PauseUnit(this.dummy, false)
            call UnitSetBonus(this.dummy, BONUS_SIGHT_RANGE, R2I(RADIUS))
            call UnitAddAbility(this.dummy, TRUE_SIGHT_ABILITY)
            call this.push(0.05)
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod

        implement BuffApply
    endstruct

    struct Cauldron extends array
        implement Alloc
        implement List

        private unit caster
        private player owner
        private unit cauldron
        private effect sfx
        private effect sfx2
        private real x
        private real y
        private real radius
        private real duration
        private real debuffDuration

        private static group g

        private method destroy takes nothing returns nothing
            call this.pop()
            call DestroyEffect(this.sfx)
            call DestroyEffect(this.sfx2)
            call DummyAddRecycleTimer(this.cauldron, 5.0)
            set this.sfx = null
            set this.sfx2 = null
            set this.cauldron = null
            set this.caster = null
            set this.owner = null
            call this.deallocate()
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this = thistype(0).next
            local SpellBuff b
            local unit u
            loop
                exitwhen this == 0
                if this.duration > 0 then
                    call GroupEnumUnitsInRange(thistype.g, this.x, this.y, this.radius + MAX_COLLISION_SIZE, null)
                    loop
                        set u = FirstOfGroup(thistype.g)
                        exitwhen u == null
                        call GroupRemoveUnit(thistype.g, u)
                        if IsUnitInRangeXY(u, this.x, this.y, this.radius) and TargetFilter(u, this.owner) then
                            set b = SpellBuff.add(this.caster, u)
                            set b.duration = this.debuffDuration
                        endif
                    endloop
                else
                    call this.destroy()
                endif
                set this.duration = this.duration - TIMEOUT
                set this = this.next
            endloop
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            local integer lvl
            set this.caster = GetTriggerUnit()
            set lvl = GetUnitAbilityLevel(this.caster, SPELL_ID)
            set this.owner = GetTriggerPlayer()
            set this.x = GetSpellTargetX()
            set this.y = GetSpellTargetY()
            set this.cauldron = GetRecycledDummyAnyAngle(this.x, this.y, 0)
            call SetUnitOwner(this.cauldron, this.owner, false)
            set this.sfx = AddSpecialEffectTarget(MODEL, this.cauldron, "origin")
            set this.sfx2 = AddSpecialEffectTarget(BUFF_SFX, this.cauldron, "origin")
            set this.radius = Radius(lvl)
            set this.duration = Duration(lvl)
            set this.debuffDuration = DebuffDuration(lvl)
            call this.push(TIMEOUT)
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call SpellBuff.initialize()
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            set thistype.g = CreateGroup()
            call SystemTest.end()
        endmethod

    endstruct

endscope