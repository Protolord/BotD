scope UltraVision

    globals
        private constant integer SPELL_ID = 'AHF3'
        private constant integer SPELL_BUFF = 'BHF3'
        private constant integer BUFF_ID = 'bHF3'
    endglobals

    private function Radius takes integer level returns real
        return 100.0*level
    endfunction

    struct UltraVision extends array
        implement Alloc

        private FlySight reveal
        private thistype next
        private unit u
        private player owner
        private integer lvl

        private static Table tb

        private static method day takes nothing returns boolean
            local thistype this = thistype(0).next
            loop
                exitwhen this == 0
                if this.reveal > 0 then
                    call this.reveal.destroy()
                    set this.reveal = 0
                endif
                call UnitRemoveAbility(this.u, SPELL_BUFF)
                call UnitRemoveAbility(this.u, BUFF_ID)
                set this = this.next
            endloop
            return false
        endmethod

        private static method night takes nothing returns boolean
            local thistype this = thistype(0).next
            loop
                exitwhen this == 0
                if this.reveal == 0 then
                    set this.reveal = FlySight.create(this.u, Radius(this.lvl))
                endif
                call UnitAddAbility(this.u, SPELL_BUFF)
                call UnitMakeAbilityPermanent(this.u, true, SPELL_BUFF)
                set this = this.next
            endloop
            return false
        endmethod

        private static method start takes unit u, integer level returns nothing
            local integer id = GetHandleId(u)
            local thistype this
            if not thistype.tb.has(id) then
                set this = thistype.allocate()
                set this.next = thistype(0).next
                set thistype(0).next = this
                set this.u = u
                set this.owner = GetOwningPlayer(u)
                set thistype.tb[id] = this
            else
                set this = thistype.tb[id]
            endif
            set this.lvl = level
            if DayNight.get() == TIME_NIGHT then
                if this.reveal == 0 then
                    set this.reveal = FlySight.create(u, Radius(this.lvl))
                else
                    set this.reveal.radius = Radius(this.lvl)
                endif
                call UnitAddAbility(u, SPELL_BUFF)
                call UnitMakeAbilityPermanent(u, true, SPELL_BUFF)
            endif
        endmethod

        private static method learn takes nothing returns nothing
            if GetLearnedSkill() == SPELL_ID then
                call thistype.start(GetTriggerUnit(), GetUnitAbilityLevel(GetTriggerUnit(), SPELL_ID))
            endif
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call DayNight.registerDay(function thistype.day)
            call DayNight.registerNight(function thistype.night)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_SKILL, function thistype.learn)
            set thistype.tb = Table.create()
            call SystemTest.end()
        endmethod

    endstruct

endscope