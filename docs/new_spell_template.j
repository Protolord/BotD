//Active Spell
scope <Name>

    globals
        private constant integer SPELL_ID = <SpellId>
    endglobals

    struct <Name> extends array

        private static method onCast takes nothing returns nothing
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SystemTest.end()
        endmethod

    endstruct

endscope

//Passive Spell that needs an allocation upon learning
scope <Name>

    globals
        private constant integer SPELL_ID = <SpellId>
        //private constant integer BUFF_ID = <BuffId> //if needed
    endglobal
    struct <Name> extends array
        implement Alloc

        private static method ultimates takes nothing returns boolean
            local unit u = GetTriggerUnit()
            local integer id = GetHandleId(u)
            local thistype this
            if thistype.tb.has(id) then
                set this = thistype.tb[id]
                //Set attributes that needs to be updated based on level
                //set this.dmg = DamagePerLevel(11)
                //...
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
                    set thistype.tb[id] = this
                    //call TimerStart(NewTimerEx(this), TIMEOUT, true, function thistype.onPeriod) //if needed
                    //call UnitAddAbility(u, BUFF_ID) //if needed
                    //call UnitMakeAbilityPermanent(u, true, BUFF_ID) //if needed
                else
                    set this = thistype.tb[id]
                endif
                set lvl = GetUnitAbilityLevel(u, SPELL_ID)
                //Set attributes that needs to be updated based on level
                //set this.dmg = DamagePerLevel(lvl)
                //...
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