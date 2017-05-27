scope Sanctuary

    globals
        private constant integer SPELL_ID = 'AH73'
        private constant string MODEL = "Models\\Effects\\SanctuaryMissile.mdx"
        private constant string MODEL2 = "Abilities\\Weapons\\AvengerMissile\\AvengerMissile.mdl"
        private constant string SFX_SOURCE = "Models\\Effects\\SanctuaryMissile.mdx"
        private constant string SFX_TARGET = "Models\\Effects\\Sanctuary.mdx"
        private constant real OFFSET = 100.0
        private constant real IMAGE_TRANSITION = 0.75
    endglobals

    private function Speed takes integer level returns real
        return 1250.0 + 0.0*level
    endfunction

    struct Sanctuary extends array

        private unit caster
        private unit target
        private integer lvl
        private effect sfx
        private Missile m

        private static Table tb

        private method destroy takes nothing returns nothing
            call ShowDummy(this.m.u, false)
            call this.m.destroy()
            call DestroyEffect(this.sfx)
            set this.sfx = null
            set this.caster = null
            set this.target = null
        endmethod

        private static method onHit takes nothing returns nothing
            call IssueImmediateOrderById(thistype(Missile.getHit()).caster, ORDER_stop)
        endmethod

        private static method onStop takes nothing returns nothing
            local integer id = GetHandleId(GetTriggerUnit())
            local thistype this
            local unit imagery
            local VertexColor vc
            local real facing
            local real x
            local real y
            local real tx
            local real ty
            if thistype.tb.has(id) then
                set this = thistype.tb[id]
                call thistype.tb.remove(id)
                set facing = GetUnitFacing(this.caster)*bj_DEGTORAD
                set x = this.m.x + OFFSET*Cos(facing)
                set y = this.m.y + OFFSET*Sin(facing)
                set tx = GetUnitX(this.target)
                set ty = GetUnitY(this.target)
                call DestroyEffect(AddSpecialEffect(SFX_SOURCE, tx, ty))
                call DestroyEffect(AddSpecialEffect(SFX_TARGET, x, y))
                call SetUnitPosition(this.target, x, y)
                set imagery = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), GetUnitTypeId(this.target), tx, ty, GetUnitFacing(this.target))
                call UnitAddAbility(imagery, 'Aloc')
                call SetUnitColor(imagery, GetPlayerColor(GetOwningPlayer(this.target)))
                call RemoveUnitTimed(imagery, IMAGE_TRANSITION)
                call PauseUnit(imagery, true)
                set vc = VertexColor.create(imagery, 255, 255, 255, -255)
                set vc.duration = IMAGE_TRANSITION
                set vc.speed = 255/IMAGE_TRANSITION
                call this.destroy()
            endif
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype(Missile.create())
            set this.caster = GetTriggerUnit()
            set this.target = GetSpellTargetUnit()
            set this.lvl = GetUnitAbilityLevel(this.caster, SPELL_ID)
            set this.m = Missile(this)
            set this.m.sourceUnit = this.target
            set this.m.targetUnit = this.caster
            set this.m.model = MODEL
            set this.m.speed = Speed(this.lvl)
            call this.m.registerOnHit(function thistype.onHit)
            call this.m.launch()
            set this.sfx = AddSpecialEffectTarget(MODEL2, this.m.u, "origin")
            set thistype.tb[GetHandleId(this.caster)] = this
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            set thistype.tb = Table.create()
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call RegisterSpellEndcastEvent(SPELL_ID, function thistype.onStop)
            call SystemTest.end()
        endmethod

    endstruct
endscope