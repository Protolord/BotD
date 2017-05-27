scope Pyro

    globals
        private constant integer SPELL_ID = 'AH51'
        private constant integer UNIT_ID = 'HT05'
        private constant string SFX = "Abilities\\Spells\\Other\\Doom\\DoomDeath.mdl"
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
    endglobals

    globals
        //Burn Debuff
        private constant real ATK_PERCENT_REDUCE = 0.3
    endglobals

    private function BaseDamage takes integer level returns real
        return 50.0 + 0.0*level
    endfunction

    private function ExtraDamage takes integer level returns real
        return 60.0 + 0.0*level
    endfunction

    private function Duration takes integer level returns real
        return 10.0 + 0.0*level
    endfunction

    private function BurnDuration takes integer level returns real
        return 3.0 + 0.0*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and CombatStat.isMelee(u) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction

    struct Burn extends Buff

        private AtkDamagePercent adp

        private static constant integer RAWCODE = 'DH50'
        private static constant integer DISPEL_TYPE = BUFF_NEGATIVE
        private static constant integer STACK_TYPE = BUFF_STACK_NONE

        method onRemove takes nothing returns nothing
            call this.adp.destroy()
        endmethod

        method onApply takes nothing returns nothing
            set this.adp = AtkDamagePercent.create(this.target, -ATK_PERCENT_REDUCE)
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod

        implement BuffApply
    endstruct

    struct Pyro extends array
        implement Alloc

        private unit caster
        private integer lvl

        private static Table tb

        static method has takes unit u returns boolean
            return GetUnitTypeId(u) == UNIT_ID
        endmethod

        private method destroy takes nothing returns nothing
            call thistype.tb.remove(GetHandleId(this.caster))
            set this.caster = null
            call this.deallocate()
        endmethod

        private static method onDamage takes nothing returns nothing
            local thistype this = thistype.tb[GetHandleId(Damage.target)]
            local Burn b
            if this > 0 and thistype.has(Damage.target) and Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.coded and TargetFilter(Damage.source, GetOwningPlayer(Damage.target)) then
                set b = Buff.get(null, Damage.source, Burn.typeid)
                if b > 0 then
                    call Damage.element.apply(Damage.target, Damage.source, BaseDamage(this.lvl) + ExtraDamage(this.lvl)*b.duration, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_FIRE)
                    set b.duration = b.duration + BurnDuration(this.lvl)
                else
                    call Damage.element.apply(Damage.target, Damage.source, BaseDamage(this.lvl), ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_FIRE)
                    set b = Burn.add(Damage.target, Damage.source)
                    set b.duration = BurnDuration(this.lvl)
                endif
            endif
        endmethod

        private static method removeAnimation takes nothing returns nothing
            local thistype this = ReleaseTimer(GetExpiredTimer())
            call AddUnitAnimationProperties(this.caster, "alternate", false)
            set this.caster = null
        endmethod

        private static method expires takes nothing returns nothing
            call thistype(ReleaseTimer(GetExpiredTimer())).destroy()
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this
            local unit u = GetTriggerUnit()
            if not Pyro.has(u) then
                set this = thistype.allocate()
                set this.caster = u
                set this.lvl = GetUnitAbilityLevel(this.caster, SPELL_ID)
                set thistype.tb[GetHandleId(this.caster)] = this
                call TimerStart(NewTimerEx(this), 0.0, false, function thistype.removeAnimation)
                call TimerStart(NewTimerEx(this), Duration(this.lvl), false, function thistype.expires)
                call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
            endif
            call DestroyEffect(AddSpecialEffect(SFX, GetUnitX(u), GetUnitY(u)))
            set u = null
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call Damage.register(function thistype.onDamage)
            set thistype.tb = Table.create()
            call Burn.initialize()
            call PreloadUnit(UNIT_ID)
            call SystemTest.end()
        endmethod

    endstruct
endscope