library SpellDisplay/*

*/ requires /*
    */ Spell /*
    */ Hero /*
    */ Border /*
    */ SystemConsole /*

*/
    struct SpellDisplay extends array
        //Instance is per player

        //! textmacro SELECTION_SYSTEM_SPELL_DISPLAYS takes NUM
            public image spell$NUM$
            public image spell$NUM$1
            public image spell$NUM$2
            public image spell$NUM$3
            public image spell$NUM$4
            public texttag text1$NUM$
            public texttag text2$NUM$
            public Border selected$NUM$
        //! endtextmacro
        
        //! runtextmacro SELECTION_SYSTEM_SPELL_DISPLAYS("1")
        //! runtextmacro SELECTION_SYSTEM_SPELL_DISPLAYS("2")
        //! runtextmacro SELECTION_SYSTEM_SPELL_DISPLAYS("3")
        //! runtextmacro SELECTION_SYSTEM_SPELL_DISPLAYS("4")

        //! textmacro SELECTION_SYSTEM_CHANGE_SELECTABLE_SPELLS takes NUM
            call ReleaseImage(this.spell$NUM$1)
            set this.spell$NUM$1 = NewImage(h.spell$NUM$1.iconPath, 64, 64, spellBtnX[$NUM$*4 + 1], spellBtnY[$NUM$*4 + 1], 1, 1)
            call SetImageRenderAlways(this.spell$NUM$1, h.spell$NUM$1 != Spell.BLANK and b)
            call ReleaseImage(this.spell$NUM$2)
            set this.spell$NUM$2 = NewImage(h.spell$NUM$2.iconPath, 64, 64, spellBtnX[$NUM$*4 + 2], spellBtnY[$NUM$*4 + 2], 1, 1)
            call SetImageRenderAlways(this.spell$NUM$2, h.spell$NUM$2 != Spell.BLANK and b)
            call ReleaseImage(this.spell$NUM$3)
            set this.spell$NUM$3 = NewImage(h.spell$NUM$3.iconPath, 64, 64, spellBtnX[$NUM$*4 + 3], spellBtnY[$NUM$*4 + 3], 1, 1)
            call SetImageRenderAlways(this.spell$NUM$3, h.spell$NUM$3 != Spell.BLANK and b)
            call ReleaseImage(this.spell$NUM$4)
            set this.spell$NUM$4 = NewImage(h.spell$NUM$4.iconPath, 64, 64, spellBtnX[$NUM$*4 + 4], spellBtnY[$NUM$*4 + 4], 1, 1)
            call SetImageRenderAlways(this.spell$NUM$4, h.spell$NUM$4 != Spell.BLANK and b)
            call this.selected$NUM$.show(false)
        //! endtextmacro
        
        //! textmacro SELECTION_SYSTEM_CHANGE_SPELL takes SPELL, NUM
            call ReleaseImage(this.spell$NUM$)
            set this.spell$NUM$ = NewImage($SPELL$.iconPath, 64, 64, SPELL$NUM$_X, SPELL$NUM$_Y, 1, 1)
            call SetImageRenderAlways(this.spell$NUM$, b)
            call SetTextTagText(this.text1$NUM$, $SPELL$.info1, 0.02)
            call SetTextTagPos(this.text1$NUM$, spellBtnX[$NUM$*4 + 1] - 20, spellBtnY[$NUM$*4 + 1] - 80 - $SPELL$.yOffset1, 0)
            call SetTextTagText(this.text2$NUM$, $SPELL$.info2, 0.02)
            call SetTextTagPos(this.text2$NUM$, spellBtnX[$NUM$*4 + 1] - 20, spellBtnY[$NUM$*4 + 1] - 80 - $SPELL$.yOffset2, 0)
            set PlayerStat(this).spell$NUM$ = $SPELL$
        //! endtextmacro
        
        //! textmacro SELECTION_SYSTEM_DESTROY_ICONS takes NUM
            call ReleaseImage(this.spell$NUM$1)
            call ReleaseImage(this.spell$NUM$2)
            call ReleaseImage(this.spell$NUM$3)
            call ReleaseImage(this.spell$NUM$4)
            set this.spell$NUM$1 = null
            set this.spell$NUM$2 = null
            set this.spell$NUM$3 = null
            set this.spell$NUM$4 = null
        //! endtextmacro
        
        method destroy takes nothing returns nothing
            call SystemTest.start("Destroying " + GetPlayerName(Player(this)) + "'s SpellDisplay: ")
            //! runtextmacro SELECTION_SYSTEM_DESTROY_ICONS("")
            //! runtextmacro SELECTION_SYSTEM_DESTROY_ICONS("1")
            //! runtextmacro SELECTION_SYSTEM_DESTROY_ICONS("2")
            //! runtextmacro SELECTION_SYSTEM_DESTROY_ICONS("3")
            //! runtextmacro SELECTION_SYSTEM_DESTROY_ICONS("4")
            call this.selected1.destroy()
            call this.selected2.destroy()
            call this.selected3.destroy()
            call this.selected4.destroy()
            call DestroyTextTag(this.text11)
            call DestroyTextTag(this.text12)
            call DestroyTextTag(this.text13)
            call DestroyTextTag(this.text14)
            call DestroyTextTag(this.text21)
            call DestroyTextTag(this.text22)
            call DestroyTextTag(this.text23)
            call DestroyTextTag(this.text24)
            call SystemTest.end()
        endmethod
        
        //Used when a new hero is selected
        static method reset takes player p, Hero h returns nothing
            local thistype this = GetPlayerId(p)
            local boolean b = p == GetLocalPlayer()
            //Change the selectable spells
            //! runtextmacro SELECTION_SYSTEM_CHANGE_SELECTABLE_SPELLS("1")
            //! runtextmacro SELECTION_SYSTEM_CHANGE_SELECTABLE_SPELLS("2")
            //! runtextmacro SELECTION_SYSTEM_CHANGE_SELECTABLE_SPELLS("3")
            //! runtextmacro SELECTION_SYSTEM_CHANGE_SELECTABLE_SPELLS("4")
            //! runtextmacro SELECTION_SYSTEM_CHANGE_SPELL("Spell.BLANK", "1")
            //! runtextmacro SELECTION_SYSTEM_CHANGE_SPELL("Spell.BLANK", "2")
            //! runtextmacro SELECTION_SYSTEM_CHANGE_SPELL("Spell.BLANK", "3")
            //! runtextmacro SELECTION_SYSTEM_CHANGE_SPELL("Spell.BLANK", "4")
        endmethod
        
        //Changes the description and displayed selected spell
        static method change takes player p, integer spellNum, integer order returns nothing
            local thistype this = GetPlayerId(p)
            local boolean b = p == GetLocalPlayer()
            local Spell s = PlayerStat(this).hero.getSpell(spellNum, order)
            if s != Spell.BLANK then
                if spellNum == 1 then
                    //! runtextmacro SELECTION_SYSTEM_CHANGE_SPELL("s", "1")
                    call this.selected1.show(b)
                    call this.selected1.move(spellBtnX[spellNum*4 + order], spellBtnY[spellNum*4 + order])
                elseif spellNum == 2 then
                    //! runtextmacro SELECTION_SYSTEM_CHANGE_SPELL("s", "2")
                    call this.selected2.show(b)
                    call this.selected2.move(spellBtnX[spellNum*4 + order], spellBtnY[spellNum*4 + order])
                elseif spellNum == 3 then
                    //! runtextmacro SELECTION_SYSTEM_CHANGE_SPELL("s", "3")
                    call this.selected3.show(b)
                    call this.selected3.move(spellBtnX[spellNum*4 + order], spellBtnY[spellNum*4 + order])
                elseif spellNum == 4 then
                    //! runtextmacro SELECTION_SYSTEM_CHANGE_SPELL("s", "4")
                    call this.selected4.show(b)
                    call this.selected4.move(spellBtnX[spellNum*4 + order], spellBtnY[spellNum*4 + order])
                endif
            endif
        endmethod
        
        //! textmacro SELECTION_SYSTEM_SPELL_INIT takes NUM
            set this.spell$NUM$ = NewImage(BLACK_IMAGE, 0, 0, 0, 0, 0, 1)
            set this.spell$NUM$1 = NewImage(BLACK_IMAGE, 0, 0, 0, 0, 0, 1)
            set this.spell$NUM$2 = NewImage(BLACK_IMAGE, 0, 0, 0, 0, 0, 1)
            set this.spell$NUM$3 = NewImage(BLACK_IMAGE, 0, 0, 0, 0, 0, 1)
            set this.spell$NUM$4 = NewImage(BLACK_IMAGE, 0, 0, 0, 0, 0, 1)
            set this.text1$NUM$ = CreateTextTag()
            call SetTextTagVisibility(this.text1$NUM$, b)
            set this.text2$NUM$ = CreateTextTag()
            call SetTextTagVisibility(this.text2$NUM$, b)
            set this.selected$NUM$ = Border.create(35, -35, 35, -35)
            call this.selected$NUM$.show(false)
        //! endtextmacro
        
        public static method create takes player p returns thistype
            local thistype this = GetPlayerId(p)
            local boolean b = p == GetLocalPlayer()
            //! runtextmacro SELECTION_SYSTEM_SPELL_INIT("1")
            //! runtextmacro SELECTION_SYSTEM_SPELL_INIT("2")
            //! runtextmacro SELECTION_SYSTEM_SPELL_INIT("3")
            //! runtextmacro SELECTION_SYSTEM_SPELL_INIT("4")
            return this
        endmethod
        
        public static method perPlayer takes nothing returns nothing
            call thistype.create(GetEnumPlayer())
        endmethod
        
        static method init takes nothing returns boolean
            call SystemTest.start("Creating SpellDisplay: ")
            call ForForce(Players.users, function thistype.perPlayer)
            call SystemTest.end()
            return false
        endmethod
        
    endstruct

endlibrary