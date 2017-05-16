library SelectionMain /*

*/ requires /*
  Selection Objects
    */ Spell /*
    */ Hero /*
  Displays
    */ SpellDisplay /*
    */ HeroDisplay /*
    */ StaticDisplay /*
  Buttons
    */ SpellButton /*
    */ HeroButton /*
    */ ConfirmButton /*
    */ RandomButton /*

*/
    //Hero Selection System Configuration
    globals
        //Display coordinates
        constant real CENTER_X = -1750
        constant real CENTER_Y = -3250
        constant real MODEL_X = CENTER_X - 700
        constant real MODEL_Y = CENTER_Y + 75
        constant real ICON_X = CENTER_X - 870
        constant real ICON_Y = CENTER_Y + 440
        constant real NAME_X = ICON_X + 70
        constant real NAME_Y = ICON_Y
        constant real ATTR_X = MODEL_X - 170
        constant real ATTR_Y = MODEL_Y - 130
        constant real INFO_X = MODEL_X + 195
        constant real INFO_Y = MODEL_Y - 160
        constant real INNATE_SPELL_X = ICON_X + 10
        constant real INNATE_SPELL_Y = CENTER_Y - 115
        constant real HERO_BUTTON_ORIGIN_X = CENTER_X - 485
        constant real HERO_BUTTON_ORIGIN_Y = CENTER_Y - 210
        constant real HERO_BUTTON_LIMIT = CENTER_X + 600
        constant real HERO_BUTTON_SPACING = 80
        constant real SPELL_BUTTON_ORIGIN_X = CENTER_X - 500
        constant real SPELL_BUTTON_ORIGIN_Y = CENTER_Y + 385
        constant real SPELL_BUTTON_SPACING = 70
        constant real SPELL_GROUP_BUTTON_SPACING = 80
        constant real SPELL1_X = MODEL_X + 100
        constant real SPELL1_Y = MODEL_Y + 275
        constant real SPELL2_X = MODEL_X + 100
        constant real SPELL2_Y = MODEL_Y + 200
        constant real SPELL3_X = MODEL_X + 100
        constant real SPELL3_Y = MODEL_Y + 125
        constant real SPELL4_X = MODEL_X + 100
        constant real SPELL4_Y = MODEL_Y + 50
        constant real CONFIRM_X = CENTER_X + 850
        constant real CONFIRM_Y = CENTER_Y - 390
        constant real RANDOM_BTN_X = CENTER_X + 850
        constant real RANDOM_BTN_Y = CENTER_Y - 250
        constant real ATTR_UI_X = ATTR_X + 40
        constant real ATTR_UI_Y = ATTR_Y + 75
        constant string TRACK_PATH_SMALL = "Doodads\\Terrain\\InvisiblePlatformSmall\\InvisiblePlatformSmall.mdl"
        constant string LINE = "LASR"
        constant string BLACK_IMAGE = "UI\\BlackImage.blp"
        constant integer BLACK_ALPHA = 210
    //---------------------------------------------------------
        real array spellBtnX
        real array spellBtnY
    endglobals

    struct SelectionMain extends array

        private static method onInit takes nothing returns nothing
            local trigger t = CreateTrigger()
            call ExecuteFunc(Spell.initialize.name)
            call ExecuteFunc(Hero.initialize.name)
            call TriggerRegisterTimerEvent(t, 0.01, false)
            call TriggerAddCondition(t, function ConfirmButton.init)
            call TriggerAddCondition(t, function RandomButton.init)
            call TriggerAddCondition(t, function SpellButton.init)
            call TriggerAddCondition(t, function SpellDisplay.init)
            call TriggerAddCondition(t, function HeroButton.init)
            call TriggerAddCondition(t, function HeroDisplay.init)
            call TriggerAddCondition(t, function StaticDisplay.init)
            call SetCameraPosition(CENTER_X, CENTER_Y)
        endmethod

    endstruct

endlibrary