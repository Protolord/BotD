library Hero requires DummyRecycler, Table

    globals
        Hero defaultHero
        Hero LIVING_FORCE
        Hero ANCIENT_EVILS
        constant integer STR = 1
        constant integer AGI = 2
        constant integer INT = 3
    endglobals

    struct Hero extends array
        implement Alloc

        readonly integer unitId
        readonly string name         //The name displayed
        readonly unit unitModel
        readonly real scaleAdd
        readonly effect model
        readonly string attribute    //The attributes displayed
        readonly integer primary
        readonly string info
        private string priv_modelPath
        private Spell priv_innateSpell
        private string priv_iconPath
        private thistype priv_faction

        readonly image icon
        readonly image spellIcon

        private Table tb

        readonly thistype next
        readonly thistype prev

        //! textmacro SELECTION_SYSTEM_HERO_CLEAN_SPELLS takes NUM
            call this.tb.remove(4*$NUM$ + 1)
            call this.tb.remove(4*$NUM$ + 2)
            call this.tb.remove(4*$NUM$ + 3)
            call this.tb.remove(4*$NUM$ + 4)
        //! endtextmacro

        method clean takes nothing returns nothing
            set this.info = ""
            set this.attribute = ""
            //! runtextmacro SELECTION_SYSTEM_HERO_CLEAN_SPELLS("1")
            //! runtextmacro SELECTION_SYSTEM_HERO_CLEAN_SPELLS("2")
            //! runtextmacro SELECTION_SYSTEM_HERO_CLEAN_SPELLS("3")
            //! runtextmacro SELECTION_SYSTEM_HERO_CLEAN_SPELLS("4")
            call this.tb.destroy()
            call DummyAddRecycleTimer(this.unitModel, 8.0)
            call DestroyEffect(this.model)
            call ReleaseImage(this.icon)
            //call ReleaseImage(this.spellIcon)
            set this.unitModel = null
            set this.model = null
            set this.icon = null
            set this.spellIcon = null
        endmethod

        static method cleanAll takes nothing returns nothing
            local thistype this = thistype(0).next
            loop
                exitwhen this == 0
                call this.clean()
                set this = this.next
            endloop
        endmethod

        //! textmacro SELECTION_SYSTEM_HERO_SPELLS takes NUM
            readonly Spell spell$NUM$1
            readonly Spell spell$NUM$2
            readonly Spell spell$NUM$3
            readonly Spell spell$NUM$4
        //! endtextmacro

        //! runtextmacro SELECTION_SYSTEM_HERO_SPELLS("1")
        //! runtextmacro SELECTION_SYSTEM_HERO_SPELLS("2")
        //! runtextmacro SELECTION_SYSTEM_HERO_SPELLS("3")
        //! runtextmacro SELECTION_SYSTEM_HERO_SPELLS("4")

        //! textmacro SELECTION_SYSTEM_HERO_SET_SPELLS takes NUM
            set this.tb[4*$NUM$ + 1] = this.spell$NUM$1
            set this.tb[4*$NUM$ + 2] = this.spell$NUM$2
            set this.tb[4*$NUM$ + 3] = this.spell$NUM$3
            set this.tb[4*$NUM$ + 4] = this.spell$NUM$4
        //! endtextmacro

        method getSpell takes integer spellNum, integer order returns Spell
            return this.tb[4*spellNum + order]
        endmethod

        private method end takes nothing returns nothing
            //! runtextmacro SELECTION_SYSTEM_HERO_SET_SPELLS("1")
            //! runtextmacro SELECTION_SYSTEM_HERO_SET_SPELLS("2")
            //! runtextmacro SELECTION_SYSTEM_HERO_SET_SPELLS("3")
            //! runtextmacro SELECTION_SYSTEM_HERO_SET_SPELLS("4")
        endmethod

        method operator modelPath takes nothing returns string
            return this.priv_modelPath
        endmethod

        method operator modelPath= takes string s returns nothing
            set this.priv_modelPath = s
            set this.unitModel = GetRecycledDummy(MODEL_X, MODEL_Y, 100, 270)
            set this.model = AddSpecialEffectTarget(s, this.unitModel, "origin")
            call SetUnitScale(this.unitModel, this.scaleAdd + 1.5, 0, 0)
            call SetUnitAnimationByIndex(this.unitModel, 165)
            call ShowUnit(this.unitModel, false)
        endmethod

        method operator innateSpell takes nothing returns Spell
            return this.priv_innateSpell
        endmethod

        method operator innateSpell= takes Spell s returns nothing
            set this.spellIcon = NewImage(s.iconPath, 60, 60, INNATE_SPELL_X, INNATE_SPELL_Y, 0, 1)
            set this.priv_innateSpell = s
        endmethod

        method operator iconPath takes nothing returns string
            return this.priv_iconPath
        endmethod

        method operator faction= takes thistype f returns nothing
            set this.priv_faction = f
            set this.next = f
            set this.prev = f.prev
            set this.next.prev = this
            set this.prev.next = this
        endmethod

        method operator faction takes nothing returns thistype
            return this.priv_faction
        endmethod

        method operator iconPath= takes string s returns nothing
            set this.priv_iconPath = s
            set this.icon = NewImage(s, 70, 70, ICON_X, ICON_Y, 1, 1)
        endmethod

        static method create takes integer id returns thistype
            local thistype this = thistype.allocate()
            local race r = GetUnitIdRace(id)
            set this.unitId = id
            set this.tb = Table.create()
            return this
        endmethod

        static method factionHead takes nothing returns integer
            local thistype this = thistype.allocate()
            set this.next = this
            set this.prev = this
            return this
        endmethod

        static method initialize takes nothing returns nothing
            call SystemTest.start("Initializing thistype" + "es:")
            set LIVING_FORCE = thistype.factionHead()
            set ANCIENT_EVILS = thistype.factionHead()
            //! runtextmacro SELECTION_SYSTEM_HERO_IMPLEMENTATION()
            set defaultHero = vampireLord
            if IsPlayerInForce(GetLocalPlayer(), Players.ancientEvils) then
                set defaultHero = stormShaman
            endif
            call SystemTest.end()
        endmethod

    endstruct


endlibrary