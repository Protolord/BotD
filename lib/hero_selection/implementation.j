//! textmacro SELECTION_SYSTEM_SPELL_IMPLEMENTATION
    implement VampireLordSpells
    implement WerewolfSpells
    implement WraithSpells
    implement ArachnidSpells
    implement DemonSpells
    implement GargoyleSpells
    implement SkeletonKingSpells
    implement CaveTrollSpells
    implement StormShamanSpells
//! endtextmacro

//! textmacro SELECTION_SYSTEM_HERO_IMPLEMENTATION
    implement VampireLordConfig
    implement WerewolfConfig
    implement WraithConfig
    implement ArachnidConfig
    implement DemonConfig
    implement GargoyleConfig
    implement SkeletonKingConfig
    implement CaveTrollConfig
    implement StormShamanConfig
//! endtextmacro

//! textmacro SELECTION_SYSTEM_HERO_BUTTON_IMPLEMENTATION
    set HeroButton.buttonX = HERO_BUTTON_ORIGIN_X
    set HeroButton.buttonY = HERO_BUTTON_ORIGIN_Y
    implement StormShamanButton
    set HeroButton.buttonX = HERO_BUTTON_ORIGIN_X
    set HeroButton.buttonY = HERO_BUTTON_ORIGIN_Y - 180
    implement VampireLordButton
    implement WerewolfButton
    implement WraithButton
    implement ArachnidButton
    implement DemonButton
    implement GargoyleButton
    implement SkeletonKingButton
    implement CaveTrollButton
//! endtextmacro
