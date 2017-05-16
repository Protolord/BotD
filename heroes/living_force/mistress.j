globals
    Hero mistress
    //Mistress Spells
endglobals

module MistressSpells
endmodule

module MistressConfig
    set mistress = Hero.create('H00C')
    set mistress.faction = LIVING_FORCE
    set mistress.name = "Mistress"
    set mistress.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_Mistress.blp"
    set mistress.modelPath = "Models\\Units\\Mistress.mdl"
    set mistress.info = "<NOTHING YET>"
    set mistress.attribute = "20 +1.0   20 +1.5   20 +3.5"
    set mistress.primary = INT

    //Configure Spells
    call mistress.end()
endmodule

module MistressButton
    call HeroButton.create(mistress)
endmodule