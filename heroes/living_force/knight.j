globals
    Hero knight
    //Knight Spells
endglobals

module KnightSpells
endmodule

module KnightConfig
    set knight = Hero.create('H00B')
    set knight.faction = LIVING_FORCE
    set knight.name = "Knight"
    set knight.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_Knight.blp"
    set knight.modelPath = "Models\\Units\\Knight.mdl"
    set knight.info = "<NOTHING YET>"
    set knight.attribute = "20 +1.0   20 +1.5   20 +3.5"
    set knight.primary = INT

    //Configure Spells
    call knight.end()
endmodule

module KnightButton
    call HeroButton.create(knight)
endmodule