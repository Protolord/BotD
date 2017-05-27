globals
    Hero viking
    //Viking Spells
    Spell roundShield
    Spell seamansWill
    Spell oceansForce
    Spell ivoryWave
endglobals

module VikingSpells
    set roundShield = Spell.create('AHL1')
    set roundShield.info = "Round Shield"

    set seamansWill = Spell.create('AHL2')
    set seamansWill.info = "Seaman's Will"

    set oceansForce = Spell.create('AHL3')
    set oceansForce.info = "Ocean's Force"

    set ivoryWave = Spell.create('AHL4')
    set ivoryWave.info = "Ivory Wave"
endmodule

module VikingConfig
    set viking = Hero.create('H00L')
    set viking.faction = LIVING_FORCE
    set viking.name = "Viking"
    set viking.scaleAdd = -0.15
    set viking.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_Viking.blp"
    set viking.modelPath = "Models\\Units\\Viking.mdl"
    set viking.info = "<NOTHING YET>"
    set viking.attribute = "20 +3.0   20 +2.0   20 +0.75"
    set viking.primary = STR

    //Configure Spells
    set viking.spell11 = roundShield
    set viking.spell21 = seamansWill
    set viking.spell31 = oceansForce
    set viking.spell41 = ivoryWave
    call viking.end()
endmodule

module VikingButton
    call HeroButton.create(viking)
endmodule