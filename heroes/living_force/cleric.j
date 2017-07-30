globals
    Hero cleric
    //Cleric Spells
    Spell holyArmor
    Spell heavensPass
    Spell angelicSeal
    Spell purification
endglobals

module ClericSpells
    set holyArmor = Spell.create('AHO1')
    set holyArmor.info = "Holy Armor"

    set heavensPass = Spell.create('AHO2')
    set heavensPass.info = "Heaven's Pass"

    set angelicSeal = Spell.create('AHO3')
    set angelicSeal.info = "Angelic Seal"

    set purification = Spell.create('AHO4')
    set purification.info = "Purification"
endmodule

module ClericConfig
    set cleric = Hero.create('H00H')
    set cleric.faction = LIVING_FORCE
    set cleric.name = "Cleric"
    set cleric.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_Cleric.blp"
    set cleric.modelPath = "Models\\Units\\Cleric.mdl"
    set cleric.info = "<NOTHING YET>"
    set cleric.attribute = "20 +2.0   20 +1.5   20 +4.0"
    set cleric.primary = INT

    //Configure Spells
    set cleric.spell11 = holyArmor
    set cleric.spell21 = heavensPass
    set cleric.spell31 = angelicSeal
    set cleric.spell41 = purification
    call cleric.end()
endmodule

module ClericButton
    call HeroButton.create(cleric)
endmodule