library StaticDisplay/*

        Contains all visuals that do not change state.

*/ requires /*
    */ ImageTools /*
    */ SystemConsole /*
*/
    
    
    //Hero and Spell Selection Static Display, same for all players
    struct StaticDisplay extends array
        //Instance is per player

        public static Border heroModel
        public static Border heroSelection
        public static Border innateSpell
        public static Border extraInfo
        public static Border spell1
        public static Border spell2
        public static Border spell3
        public static Border spell4
        public static image background
        public static image str
        public static image agi
        public static image int
        public static image randomPick
        
        static method remove takes nothing returns nothing
            call Hero.cleanAll()
            call ReleaseImage(thistype.str)
            call ReleaseImage(thistype.agi)
            call ReleaseImage(thistype.int)
            call ReleaseImage(thistype.randomPick)
            call DestroyImage(thistype.background)
            call thistype.heroModel.destroy()
            call thistype.heroSelection.destroy()
            call thistype.innateSpell.destroy()
            call thistype.extraInfo.destroy()
            call thistype.spell1.destroy()
            call thistype.spell2.destroy()
            call thistype.spell3.destroy()
            call thistype.spell4.destroy()
            set thistype.str = null
            set thistype.agi = null
            set thistype.int = null
            set thistype.background = null
        endmethod
        
        static method hide takes player p returns nothing
            if GetLocalPlayer() == p then
                call SetImageRenderAlways(thistype.str, false)
                call SetImageRenderAlways(thistype.agi, false)
                call SetImageRenderAlways(thistype.int, false)
                call SetImageRenderAlways(thistype.randomPick, false)
                call SetImageRenderAlways(thistype.background, false)
                call thistype.heroModel.show(false)
                call thistype.heroSelection.show(false)
                call thistype.innateSpell.show(false)
                call thistype.extraInfo.show(false)
                call thistype.spell1.show(false)
                call thistype.spell2.show(false)
                call thistype.spell3.show(false)
                call thistype.spell4.show(false)
                //Reset Cameras
                call SetCameraBounds(WorldBounds.playMinX, WorldBounds.playMinY, WorldBounds.playMinX, WorldBounds.playMaxY, WorldBounds.playMaxX, WorldBounds.playMaxY, WorldBounds.playMaxX, WorldBounds.playMinY)
                call SetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK, -60, 0)
            endif
        endmethod
        
        public static method init takes nothing returns boolean
            local real xLimit = CENTER_X + 895
            local real spellTop = SPELL_BUTTON_ORIGIN_Y - 40
            local real spellBot = SPELL_BUTTON_ORIGIN_Y - 440
            local real spellX = CENTER_X - 535
            call SystemTest.start("Creating the StaticDisplay: ")
            //Left
            set thistype.heroModel = Border.create(NAME_Y + 60, ATTR_Y, MODEL_X + 150, MODEL_X - 220)
            set thistype.innateSpell = Border.create(ATTR_Y - 10, CENTER_Y - 435, MODEL_X + 150, MODEL_X - 220)
            //Center
            set thistype.spell1 = Border.create(spellTop, spellBot, spellX + 350, spellX)
            set thistype.spell2 = Border.create(spellTop, spellBot, spellX + 710, spellX + 360)
            set thistype.spell3 = Border.create(spellTop, spellBot, spellX + 1070, spellX + 720)
            set thistype.spell4 = Border.create(spellTop, spellBot, xLimit, spellX + 1080)
            set thistype.extraInfo = Border.create(spellBot - 10, CENTER_Y - 150, xLimit, spellX)
            set thistype.heroSelection = Border.create(CENTER_Y - 160, CENTER_Y - 435, CENTER_X + 790, spellX)
            set thistype.background = CreateImage("UI\\HeroSelection\\background.tga", 1900, 975, 0, CENTER_X - 960, CENTER_Y - 455, 1, 0, 0, 0, 2)
            call SetImageRenderAlways(thistype.background, true)
            //Display STR, AGI and INT Icon
            set thistype.str = NewImage("UI\\HeroSelection\\Strength.blp", 64, 64, ATTR_UI_X, ATTR_UI_Y, 1, 1)
            set thistype.agi = NewImage("UI\\HeroSelection\\Agility.blp", 64, 64, ATTR_UI_X + 100, ATTR_UI_Y, 1, 1)
            set thistype.int = NewImage("UI\\HeroSelection\\Intelligence.blp", 64, 64, ATTR_UI_X + 200, ATTR_UI_Y, 1, 1)
            set thistype.randomPick = NewImage("UI\\HeroSelection\\Random.blp", 90, 90, RANDOM_BTN_X, RANDOM_BTN_Y, 1, 1)
            call SetImageRenderAlways(thistype.str, true)
            call SetImageRenderAlways(thistype.agi, true)
            call SetImageRenderAlways(thistype.int, true)
            call SetImageRenderAlways(thistype.randomPick, true)
            call SetCameraBounds(CENTER_X, CENTER_Y, CENTER_X, CENTER_Y, CENTER_X, CENTER_Y, CENTER_X, CENTER_Y)
            call SystemTest.end()
            return false
        endmethod
        
    endstruct

endlibrary