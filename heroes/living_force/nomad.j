globals
    Hero nomad
    //Nomad Spells
    Spell cursedContract
    Spell sandstorm
    Spell blocking
    Spell wrathOfTheDesert
endglobals

module NomadSpells
    set cursedContract = Spell.create('AHD1')
    set cursedContract.info = "Cursed Contract"

    set sandstorm = Spell.create('AHD2')
    set sandstorm.info = "Sandstorm"

    set blocking = Spell.create('AHD3')
    set blocking.info = "Blocking|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Speed Reduction|r: |cff3399ff(100% - (10% x ability level))|n|r|cfff4a460Cooldown|r: |cff3399ff10 seconds|n|r|nNomad sharpen his senses to block every melee enemy attacks but causes Nomad to move and attack slower."

    set wrathOfTheDesert = Spell.create('AHD4')
    set wrathOfTheDesert.info = "Wrath Of The Desert|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Duration|r: |cff3399ff(5 x ability level) seconds|n|r|cfff4a460Cooldown|r: |cff3399ff2 minutes|r|n|nNomad turns into a deadly form of Desert Predator. Gains ultimate movement and attack speed, magic damage and resistance to Vanquished Builder spells."
endmodule

module NomadConfig
    set nomad = Hero.create('H00D')
    set nomad.faction = LIVING_FORCE
    set nomad.name = "Nomad"
    set nomad.scaleAdd = -0.35
    set nomad.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_Nomad.blp"
    set nomad.modelPath = "Models\\Units\\Nomad.mdl"
    set nomad.info = "<NOTHING YET>"
    set nomad.attribute = "20 +3.0   20 +2.0   20 +0.75"
    set nomad.primary = STR

    //Configure Spells
    set nomad.spell11 = cursedContract
    set nomad.spell21 = sandstorm
    set nomad.spell31 = blocking
    set nomad.spell41 = wrathOfTheDesert
    call nomad.end()
endmodule

module NomadButton
    call HeroButton.create(nomad)
endmodule