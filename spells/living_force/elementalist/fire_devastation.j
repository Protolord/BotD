scope FireDevastation

    globals
        private constant integer SPELL_ID = 'AH44'
        private constant integer DISABLE_SPELL_ID = 'MH44'
        private constant integer ENABLE_SPELL_ID = 'EH44'
        private constant string SFX_EXPLOSION = "Models\\Effects\\FireDevastationExplosion.mdx"
        private constant string SFX_FLAME = "Models\\Effects\\FireDevastationFlame.mdx"
        private constant string SFX_FLAME2 = "Objects\\Spawnmodels\\Human\\SmallFlameSpawn\\SmallFlameSpawn.mdl"
        private constant real TIMEOUT = 0.05
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
    endglobals

    //In Percent
    private function MaxManaAsDamage takes integer level returns real
        return 25.0*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction

    struct FireDevastation extends array
        implement Alloc
        implement List

        private unit u
        private boolean full

        private static Table tb

        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local unit target = GetSpellTargetUnit()
            local integer lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            local real x = GetUnitX(target)
            local real y = GetUnitY(target)
            call Damage.element.apply(caster, target, MaxManaAsDamage(lvl)*GetUnitState(caster, UNIT_STATE_MAX_MANA)/100.0, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_FIRE)
            call SetUnitState(caster, UNIT_STATE_MANA, 0)
            call DestroyEffect(AddSpecialEffect(SFX_EXPLOSION, x, y))
            call DestroyEffect(AddSpecialEffect(SFX_FLAME, x, y))
            call AddSpecialEffectTimer(AddSpecialEffect(SFX_FLAME2, x, y), 3.0)
            set caster = null
            set target = null
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this = thistype(0).next
            local boolean b
            loop
                exitwhen this == 0
                if this.full then
                    if GetUnitState(this.u, UNIT_STATE_MANA) != GetUnitState(this.u, UNIT_STATE_MAX_MANA) then
                        set this.full = false
                        call UnitAddAbility(this.u, DISABLE_SPELL_ID)
                        call UnitRemoveAbility(this.u, DISABLE_SPELL_ID)
                    endif
                else
                    if GetUnitState(this.u, UNIT_STATE_MANA) == GetUnitState(this.u, UNIT_STATE_MAX_MANA) then
                        set this.full = true
                        call UnitAddAbility(this.u, ENABLE_SPELL_ID)
                        call UnitRemoveAbility(this.u, ENABLE_SPELL_ID)
                    endif
                endif
                set this = this.next
            endloop
        endmethod

        private static method learn takes nothing returns nothing
            local thistype this
            local unit u
            local integer id
            if GetLearnedSkill() == SPELL_ID then
                set u = GetTriggerUnit()
                set id = GetHandleId(u)
                if not thistype.tb.has(id) then
                    set this = thistype.allocate()
                    set thistype.tb[id] = this
                    set this.u = u
                    set this.full = GetUnitState(u, UNIT_STATE_MANA) == GetUnitState(u, UNIT_STATE_MAX_MANA)
                    if not this.full then
                        call UnitAddAbility(u, DISABLE_SPELL_ID)
                        call UnitRemoveAbility(u, DISABLE_SPELL_ID)
                    endif
                    call this.push(TIMEOUT)
                endif
            endif
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_SKILL, function thistype.learn)
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            set thistype.tb = Table.create()
            call SystemTest.end()
        endmethod

    endstruct

endscope