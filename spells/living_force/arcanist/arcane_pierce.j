scope ArcanePierce

    globals
        private constant integer SPELL_ID = 'AHE4'
        private constant string MODEL = "Models\\Effects\\ArcanePierce.mdx"
        private constant string SFX = "Models\\Effects\\ArcanePierceEffects.mdx"
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
        private constant string BEAM_MODEL = "Models\\Effects\\ArcanePierceBeam.mdx"
        private constant real BEAM_OFFSET = 350.0
        private constant real BEAM_ANGLE = 20*bj_DEGTORAD
    endglobals

    //In Percent
    private function Threshold takes integer level returns real
        return 10.0*level
    endfunction

    private function DamageDealt takes integer level returns real
        return 500.0*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction

    struct ArcanePierce extends array

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
            local real hp = GetWidgetLife(this.target)
            local real hpPercent = 100*hp/GetUnitState(target, UNIT_STATE_MAX_LIFE)
            local real x1 = GetUnitX(this.caster)
            local real y1 = GetUnitY(this.caster)
            local real x2 = GetUnitX(this.target)
            local real y2 = GetUnitY(this.target)
            local Effect e = Effect.create(SFX, x2, y2, 50, Atan2(y1 - y2, x1 - x2)*bj_RADTODEG)
            set e.duration = 0.25
            if SpellBlock.has(this.target) then
                call this.m.show(false)
            elseif TargetFilter(this.target, this.owner) then
                if hpPercent <= Threshold(this.lvl) then
                    call FloatingTextSplat(Element.string(DAMAGE_ELEMENT_ARCANE) + I2S(R2I(hp)) + "|r", this.target).setVisible(GetLocalPlayer() == GetOwningPlayer(this.caster))
                    call Damage.kill(this.caster, this.target)
                else
                    call Damage.element.apply(this.caster, this.target, DamageDealt(this.lvl), ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_ARCANE)
                endif
            endif
            call this.destroy()
        endmethod

        private static method destroyOnHit takes nothing returns nothing
            call Missile.getHit().destroy()
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype(Missile.create())
            local Missile m
            local real x1
            local real y1
            local real x2
            local real y2
            local real a
            local real z
            local real aLimit
            set this.caster = GetTriggerUnit()
            set this.owner = GetTriggerPlayer()
            set this.target = GetSpellTargetUnit()
            set x1 = GetUnitX(this.caster)
            set y1 = GetUnitY(this.caster)
            set x2 = GetUnitX(this.target)
            set y2 = GetUnitY(this.target)
            set a = Atan2(y2 - y1, x2 - x1)
            set x2 = x1 + 250*Cos(a)
            set y2 = y1 + 250*Sin(a)
            set z = GetPointZ(x2, y2)
            set this.lvl = GetUnitAbilityLevel(this.caster, SPELL_ID)
            set this.m = Missile(this)
            set this.m.sourceUnit = this.caster
            call this.m.targetXYZ(x2, y2, z)
            set this.m.scale = 2.5
            set this.m.model = MODEL
            set this.m.speed = 2000
            call this.m.registerOnHit(function thistype.onHit)
            call this.m.launch()
            //Beam missiles
            set a = a + bj_PI
            set aLimit = a + BEAM_ANGLE
            set a = a - 2*BEAM_ANGLE
            set z = z + 50.0
            set x2 = GetUnitX(this.target)
            set y2 = GetUnitY(this.target)
            loop
                exitwhen a > aLimit
                set m = Missile.create()
                call m.sourceXYZ(x2 + BEAM_OFFSET*Cos(a + BEAM_ANGLE), y2 + BEAM_OFFSET*Sin(a + BEAM_ANGLE), z)
                set m.targetUnit = this.target
                set m.model = BEAM_MODEL
                set m.speed = 1750.0
                call m.registerOnHit(function thistype.destroyOnHit)
                call m.launch()
                set a = a + BEAM_ANGLE
            endloop
            call SystemMsg.create(GetUnitName(this.caster) + " cast thistype")
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SystemTest.end()
        endmethod

    endstruct

endscope