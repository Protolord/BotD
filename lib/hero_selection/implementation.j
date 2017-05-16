//! textmacro SELECTION_SYSTEM_SPELL_IMPLEMENTATION
    implement VampireLordSpells
    implement WerewolfSpells
    implement WraithSpells
    implement AncientArachnidSpells
    implement DemonSpells
    implement GargoyleSpells
    implement SkeletonKingSpells
    implement CaveTrollSpells
    implement StormShamanSpells
    implement CrusaderSpells
    implement DwarfDefenderSpells
    implement ElementalistSpells
    implement FirelordSpells
    implement GnomeTechnicianSpells
    implement WitchSpells
    implement HunterSpells
    implement GuardianSpells
    implement InquisitorSpells
    implement KnightSpells
    implement MistressSpells
//! endtextmacro

//! textmacro SELECTION_SYSTEM_HERO_IMPLEMENTATION
    implement VampireLordConfig
    implement WerewolfConfig
    implement WraithConfig
    implement AncientArachnidConfig
    implement DemonConfig
    implement GargoyleConfig
    implement SkeletonKingConfig
    implement CaveTrollConfig
    implement StormShamanConfig
    implement CrusaderConfig
    implement DwarfDefenderConfig
    implement ElementalistConfig
    implement FirelordConfig
    implement GnomeTechnicianConfig
    implement WitchConfig
    implement HunterConfig
    implement GuardianConfig
    implement InquisitorConfig
    implement KnightConfig
    implement MistressConfig
//! endtextmacro

//! textmacro SELECTION_SYSTEM_HERO_BUTTON_IMPLEMENTATION
    set HeroButton.buttonX = HERO_BUTTON_ORIGIN_X
    set HeroButton.buttonY = HERO_BUTTON_ORIGIN_Y
    implement StormShamanButton
    implement CrusaderButton
    implement DwarfDefenderButton
    implement ElementalistButton
    implement FirelordButton
    implement GnomeTechnicianButton
    implement WitchButton
    implement HunterButton
    implement GuardianButton
    implement InquisitorButton
    implement KnightButton
    implement MistressButton
    set HeroButton.buttonX = HERO_BUTTON_ORIGIN_X
    set HeroButton.buttonY = HERO_BUTTON_ORIGIN_Y - 180
    implement VampireLordButton
    implement WerewolfButton
    implement WraithButton
    implement AncientArachnidButton
    implement DemonButton
    implement GargoyleButton
    implement SkeletonKingButton
    implement CaveTrollButton
//! endtextmacro
