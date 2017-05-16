globals
    Hero hunter
    //Hunter Spells
endglobals

module HunterSpells
endmodule

module HunterConfig
    set hunter = Hero.create('H008')
    set hunter.faction = LIVING_FORCE
    set hunter.name = "Hunter"
    set hunter.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_Hunter.blp"
    set hunter.modelPath = "Models\\Units\\Hunter.mdl"
    set hunter.info = "<NOTHING YET>"
    set hunter.attribute = "20 +1.0   20 +1.5   20 +3.5"
    set hunter.primary = INT

    //Configure Spells
    call hunter.end()
endmodule

module HunterButton
    call HeroButton.create(hunter)
endmodule