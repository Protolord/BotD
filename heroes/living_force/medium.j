globals
    Hero medium
    //Medium Spells
    Spell blindVision
    Spell deadlyLink
    Spell spiritualSwap
    Spell mediumComparison
endglobals

module MediumSpells
    set blindVision = Spell.create('AHG1')
    set blindVision.info = "Blind Vision"

    set deadlyLink = Spell.create('AHG2')
    set deadlyLink.info = "Deadly Link"

    set spiritualSwap = Spell.create('AHG3')
    set spiritualSwap.info = "Spiritual Swap"

    set mediumComparison = Spell.create('AHG4')
    set mediumComparison.info = "Medium Comparison"
endmodule

module MediumConfig
    set medium = Hero.create('H00G')
    set medium.faction = LIVING_FORCE
    set medium.name = "Medium"
    set medium.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_Medium.blp"
    set medium.modelPath = "Models\\Units\\Medium.mdl"
    set medium.info = "<NOTHING YET>"
    set medium.attribute = "20 +1.0   20 +1.5   20 +3.5"
    set medium.primary = INT

    //Configure Spells
    set medium.spell11 = blindVision
    set medium.spell21 = deadlyLink
    set medium.spell31 = spiritualSwap
    set medium.spell41 = mediumComparison
    call medium.end()
endmodule

module MediumButton
    call HeroButton.create(medium)
endmodule