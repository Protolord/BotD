globals
    Hero witch
    //Witch Spells
    Spell frogTransformation
    Spell envenomedDart
    Spell sanctuary
    Spell spiritualWall
endglobals

module WitchSpells
    set frogTransformation = Spell.create('AH71')
    set frogTransformation.info = "Frog Transformation"

    set envenomedDart = Spell.create('AH72')
    set envenomedDart.info = "Envenomed Dart"

    set sanctuary = Spell.create('AH73')
    set sanctuary.info = "Sanctuary"

    set spiritualWall = Spell.create('AH74')
    set spiritualWall.info = "Spiritual Wall"
endmodule

module WitchConfig
    set witch = Hero.create('H007')
    set witch.faction = LIVING_FORCE
    set witch.name = "Witch"
    set witch.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_Witch.blp"
    set witch.modelPath = "Models\\Units\\Witch.mdl"
    set witch.info = "<NOTHING YET>"
    set witch.attribute = "20 +1.0   20 +1.5   20 +3.5"
    set witch.primary = INT

    //Configure Spells
    set witch.spell11 = frogTransformation
    set witch.spell21 = envenomedDart
    set witch.spell31 = sanctuary
    set witch.spell41 = spiritualWall
    call witch.end()
endmodule

module WitchButton
    call HeroButton.create(witch)
endmodule