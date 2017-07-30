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
    set songOfTheSiren.info = "Song Of The Siren|n|cfff4a460Target|r: |cff3399ffArea of Effect|n|r|cfff4a460Radius|r: |cff3399ff(100 + (50 x level))|n|r|cfff4a460Range|r: |cff3399ff900|n|r|cfff4a460Cooldown|r: |cff3399ff15 seconds|r|n|nSiren sings her song of the seas and removes all negative buffs from all ally units in area of spell."

    set aquaStrike = Spell.create('AHH2')
    set aquaStrike.info = "Aqua Strike|n|cfff4a460Target|r: |cff3399ffEnemy Unit|n|r|cfff4a460Range|r: |cff3399ff700|n|r|cfff4a460Damage|r: |cff3399ff(60 x level)|n|r|cfff4a460Cooldown|r: |cff3399ff20 seconds|r|n|nSiren sends a water element to deal magic damage to enemy unit."

    set waterBlow = Spell.create('AHH3')
    set waterBlow.info = "Water Blow"

    set amphibianSign = Spell.create('AHH4')
    set amphibianSign.info = "Amphibian Sign|n|cfff4a460Target|r: |cff3399ffEnemy unit|n|r|cfff4a460Slow|r:|cff3399ff 25%|n|r|cfff4a460Physical Damage|r:|cff3399ff +50%|n|r|cfff4a460Magical Damage|r:|cff3399ff +20%|n|r|cfff4a460Duration|r:|cff3399ff (5 x level) seconds|n|r|cfff4a460Cooldown|r:|cff3399ff 120 seconds|n|r|nSiren enchants the target slowing it and causing it to take extra damage."
endmodule

module SirenConfig
    set siren = Hero.create('H00H')
    set siren.faction = LIVING_FORCE
    set siren.name = "Siren"
    set siren.scaleAdd = -0.2
    set siren.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_Siren.blp"
    set siren.modelPath = "Models\\Units\\Siren.mdl"
    set siren.info = "<NOTHING YET>"
    set siren.attribute = "20 +2.0   20 +2.0   20 +4.0"
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