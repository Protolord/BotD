library HeroDisplay/*

*/ requires /*
    */ Spell /*
    */ Hero /*
    */ SpellButton /*
    */ Border /*
    */ SystemConsole /*
    */ TextSplat2 /*

*/

    struct HeroDisplay extends array
        //Instance is per player
        
        public textsplat name
        public textsplat info
        public textsplat attribute
        public texttag innateSpellText
        public fogmodifier fog
        public fogmodifier heroVision
        public Border primary
        
        public thistype next
        public thistype prev
        
        public static timer t = CreateTimer()
        public static rect r
        public static rect modelRect
        public static constant integer LIST_HEAD = 100
        
        method destroy takes nothing returns nothing
            local Hero h = PlayerStat(this).hero
            call SystemTest.start("Destroying " + GetPlayerName(Player(this)) + "'s HeroDisplay: ")
            if Player(this) == GetLocalPlayer() then
                call ShowDummy(h.unitModel, false)
                call SetImageRenderAlways(h.icon, false)
                call SetImageRenderAlways(h.spellIcon, false)
            endif
            call DestroyFogModifier(this.fog)
            call DestroyFogModifier(this.heroVision)
            call DestroyTextTag(this.innateSpellText)
            set this.innateSpellText = null
            call this.name.destroy()
            call this.info.destroy()
            call this.attribute.destroy()
            call this.primary.destroy()
            call SystemTest.end()
            set this.prev.next = .next
            set this.next.prev = .prev
            //If this is the last HeroDisplay
            if thistype(LIST_HEAD).next == LIST_HEAD then
                call PauseTimer(thistype.t)
                call SystemTest.start("Destroying the StaticDisplay: ")
                call StaticDisplay.remove()
                call SystemTest.end()
                call SystemTest.start("Destroying all HeroButtons: ")
                call HeroButton.destroyAll()
                call SystemTest.end()
                call SystemTest.start("Destroying all SpellButtons: ")
                call SpellButton.destroyAll()
                call SystemTest.end()
            endif
        endmethod

        public static method pickAll takes nothing returns nothing
            local thistype this = thistype(LIST_HEAD).next
            loop
                exitwhen this == LIST_HEAD
                if GetLocalPlayer() == Player(this) then
                    call SetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK, -90, 0)
                    call SetCameraField(CAMERA_FIELD_ROTATION, 90, 0)
                    call SetCameraField(CAMERA_FIELD_TARGET_DISTANCE, 1700, 0)
                endif
                set this = this.next
            endloop
        endmethod
        
        public static method endAll takes nothing returns nothing
            call thistype(GetPlayerId(GetEnumPlayer())).destroy()
        endmethod
        
        static method remove takes nothing returns nothing
            //Pick all players with endAll as callback
            call ForForce(Players.users, function thistype.endAll)
        endmethod
        
        static method change takes player p, Hero h returns nothing
            local thistype this = GetPlayerId(p)
            local boolean b = GetLocalPlayer() == p
            local Hero prevHero = PlayerStat(this).hero
            //Show Hero Model
            if b then
                if prevHero != 0 then
                    call ShowDummy(prevHero.unitModel, false)
                    call SetImageRenderAlways(prevHero.icon, false)
                    call SetImageRenderAlways(prevHero.spellIcon, false)
                endif
                call ShowDummy(h.unitModel, true)
                call SetImageRenderAlways(h.icon, true)
                call SetImageRenderAlways(h.spellIcon, true)
            endif
            call SetTextTagText(this.innateSpellText, h.innateSpell.info1, 0.02)
            call SetTextTagPos(this.innateSpellText, ICON_X - 20, ATTR_Y - 130 - h.innateSpell.yOffset1, 0)
            call this.info.setText(h.info, 5.10, TEXTSPLAT_TEXT_ALIGN_LEFT)
            call this.attribute.setText(h.attribute, 6.1, TEXTSPLAT_TEXT_ALIGN_LEFT)
            call this.name.setText(h.name, 10, TEXTSPLAT_TEXT_ALIGN_LEFT)
            call this.primary.move(ATTR_UI_X + 100*(h.primary - 1) - 2.5, ATTR_UI_Y - 1)
            set PlayerStat(this).hero = h
            call ConfirmButton.show(p, false)
        endmethod
        
        static method create takes player p returns thistype
            local thistype this = GetPlayerId(p)
            local boolean b = p == GetLocalPlayer()
            set this.info = textsplat.create(TREBUCHET_MS)
            set this.attribute = textsplat.create(TREBUCHET_MS)
            set this.primary = Border.create(0, 61, 0, 61)
            set this.name = textsplat.create(TREBUCHET_MS)
            set this.innateSpellText = CreateTextTag()
            call this.info.setPosition(INFO_X, INFO_Y, 1)
            call this.attribute.setPosition(ATTR_X + 5, ATTR_Y + 20, 1)
            call this.name.setPosition(NAME_X, NAME_Y, 1)
            call this.info.setVisible(b)
            call this.attribute.setVisible(b)
            call this.primary.show(b)
            call this.name.setVisible(b)
            call SetTextTagVisibility(this.innateSpellText, b)
            set this.next = LIST_HEAD
            set this.prev = thistype(LIST_HEAD).prev
            set this.next.prev = this
            set this.prev.next = this
            if this.prev == LIST_HEAD then
                call TimerStart(thistype.t, TIMEOUT, true, function thistype.pickAll)
            endif
            return this
        endmethod
        
        public static method perPlayer takes nothing returns nothing
            local player p = GetEnumPlayer()
            local thistype this = thistype.create(p)
            set this.heroVision = CreateFogModifierRect(p, FOG_OF_WAR_VISIBLE, thistype.modelRect, true, false)
            call FogModifierStart(this.heroVision)
            set this.fog = CreateFogModifierRect(p, FOG_OF_WAR_MASKED, WorldBounds.world, true, false)
            call FogModifierStart(this.fog)
            call this.change(p, defaultHero)
            call SpellDisplay.reset(p, defaultHero)
        endmethod
        
        static method init takes nothing returns boolean
            call SystemTest.start("Creating HeroDisplay: ")
            call SetMapFlag(MAP_FOG_HIDE_TERRAIN, true)
            set thistype.r = Rect(CENTER_X - 1100, CENTER_Y - 800, CENTER_X + 1100, CENTER_Y + 800)
            set thistype.modelRect = Rect(MODEL_X - 60, MODEL_Y - 60, MODEL_X + 60, MODEL_Y + 60)
            call ForForce(Players.users, function thistype.perPlayer)
            call RemoveRect(thistype.r)
            call SystemTest.end()
            return false
        endmethod
        
        public static method onInit takes nothing returns nothing
            set thistype(LIST_HEAD).next = LIST_HEAD
            set thistype(LIST_HEAD).prev = LIST_HEAD
        endmethod
        
    endstruct

endlibrary