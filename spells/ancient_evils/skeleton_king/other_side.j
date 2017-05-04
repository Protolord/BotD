scope OtherSide

    globals
        private constant integer SPELL_ID = 'A722'
        private constant integer BUFF_ID = 'B722'
        private constant real TIMEOUT = 0.2
        private constant string SFX1 = "Models\\Effects\\OtherSide1.mdx"
        private constant string SFX2 = "Models\\Effects\\OtherSide2.mdx"
        private constant string SFX3 = "Models\\Effects\\OtherSide3.mdx"
    endglobals

    private function MaxDamage takes integer level returns real
        if level == 11 then
            return 200.0
        endif
        return 10.0*level
    endfunction

    //HP missing to Damage ratio
    private function Ratio takes integer level returns real
        if level == 11 then
            return 2.0
        endif
        return 1.0
    endfunction

    struct OtherSide extends array
        implement Alloc

        private unit u
        private AtkDamage ad
        private real hpMissing
        private real max
        private real ratio
        private effect sfx1
        private effect sfx2
        private effect sfx3

        private static Table tb
        private static group g

        private static method onPeriod takes nothing returns nothing
            local thistype this = thistype.top
            local integer dmg
            loop
                exitwhen this == 0
                if UnitAlive(this.u) then
                     //Do stuffs
                    set dmg = R2I(CombatStat.getDamage(this.u))
                    set this.hpMissing = (1.0 - GetWidgetLife(this.u)/GetUnitState(this.u, UNIT_STATE_MAX_LIFE))
                    call this.ad.change(R2I(RMinBJ(this.ratio*this.hpMissing*dmg, this.max*dmg/100)))
                    //SFX
                    if this.hpMissing > 0.25 and this.sfx1 == null then
                        set this.sfx1 = AddSpecialEffectTarget(SFX1, this.u, "chest")
                    endif
                    if this.hpMissing > 0.5 and this.sfx2 == null then
                        set this.sfx2 = AddSpecialEffectTarget(SFX2, this.u, "chest")
                    endif
                    if this.hpMissing > 0.75 and this.sfx3 == null then
                        set this.sfx3 = AddSpecialEffectTarget(SFX3, this.u, "chest")
                    endif
                    if this.hpMissing < 0.25 and this.sfx1 != null then
                        call DestroyEffect(this.sfx1)
                        set this.sfx1 = null
                    endif
                    if this.hpMissing < 0.5 and this.sfx2 != null then
                        call DestroyEffect(this.sfx2)
                        set this.sfx2 = null
                    endif
                    if this.hpMissing < 0.75 and this.sfx3 != null then
                        call DestroyEffect(this.sfx3)
                        set this.sfx3 = null
                    endif
                endif
                set this = this.next
            endloop
        endmethod

        implement Stack

        private static method ultimates takes nothing returns boolean
            local unit u = GetTriggerUnit()
            local integer id = GetHandleId(u)
            local thistype this
            if thistype.tb.has(id) then
                set this = thistype.tb[id]
                set this.max = MaxDamage(11)
                set this.ratio = Ratio(11)
            endif
            set u = null
            return false
        endmethod

        private static method learn takes nothing returns nothing
            local thistype this
            local unit u
            local integer id
            local integer lvl
            if GetLearnedSkill() == SPELL_ID then
                set u = GetTriggerUnit()
                set id = GetHandleId(u)
                if not thistype.tb.has(id) then
                    set this = thistype.allocate()
                    set this.u = u
                    set this.hpMissing = 0
                    set this.ad = AtkDamage.create(u, 0)
                    set thistype.tb[id] = this
                    call this.push(TIMEOUT)
                    call UnitAddAbility(u, BUFF_ID)
                    call UnitMakeAbilityPermanent(u, true, BUFF_ID)
                else
                    set this = thistype.tb[id]
                endif
                set lvl = GetUnitAbilityLevel(u, SPELL_ID)
                set this.max = MaxDamage(lvl)
                set this.ratio = Ratio(lvl)
                set u = null
            endif
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_SKILL, function thistype.learn)
            call PlayerStat.ultimateEvent(function thistype.ultimates)
            set thistype.tb = Table.create()
            set thistype.g = CreateGroup()
            call SystemTest.end()
        endmethod

    endstruct

endscope