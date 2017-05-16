globals
    Hero inquisitor
    //Inquisitor Spells
endglobals

module InquisitorSpells
endmodule

module InquisitorConfig
    set inquisitor = Hero.create('H00A')
    set inquisitor.faction = LIVING_FORCE
    set inquisitor.name = "Inquisitor"
    set inquisitor.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_Inquisitor.blp"
    set inquisitor.modelPath = "Models\\Units\\Inquisitor.mdl"
    set inquisitor.info = "<NOTHING YET>"
    set inquisitor.attribute = "20 +1.0   20 +1.5   20 +3.5"
    set inquisitor.primary = INT

    //Configure Spells
    call inquisitor.end()
endmodule

module InquisitorButton
    call HeroButton.create(inquisitor)
endmodule