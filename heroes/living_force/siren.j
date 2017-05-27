globals
    Hero siren
    //Siren Spells
    Spell songOfTheSiren
    Spell aquaStrike
    Spell waterBlow
    Spell amphibianSign
endglobals

module SirenSpells
    set songOfTheSiren = Spell.create('AHH1')
    set songOfTheSiren.info = "Song Of The Siren"

    set aquaStrike = Spell.create('AHH2')
    set aquaStrike.info = "Aqua Strike"

    set waterBlow = Spell.create('AHH3')
    set waterBlow.info = "Water Blow"

    set amphibianSign = Spell.create('AHH4')
    set amphibianSign.info = "Amphibian Sign"
endmodule

module SirenConfig
    set siren = Hero.create('H00H')
    set siren.faction = LIVING_FORCE
    set siren.name = "Siren"
    set siren.scaleAdd = -0.2
    set siren.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_Siren.blp"
    set siren.modelPath = "Models\\Units\\Siren.mdl"
    set siren.info = "<NOTHING YET>"
    set siren.attribute = "20 +1.0   20 +1.5   20 +3.5"
    set siren.primary = INT

    //Configure Spells
    set siren.spell11 = songOfTheSiren
    set siren.spell21 = aquaStrike
    set siren.spell31 = waterBlow
    set siren.spell41 = amphibianSign
    call siren.end()
endmodule

module SirenButton
    call HeroButton.create(siren)
endmodule