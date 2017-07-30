globals
    Hero nomad
    //Nomad Spells
    Spell cursedContact
    Spell sandstorm
    Spell blocking
    Spell wrathOfTheDesert
endglobals

module NomadSpells
    set cursedContact = Spell.create('AHD1')
    set cursedContact.passive = true
    set cursedContact.info = "Cursed Contact|n|cfff4a460Target|r: |cff3399ffPassive / Self|n|r|cfff4a460Chance|r: |cff3399ff20%|n|r|cfff4a460Damage|r: |cff3399ff(2% Max HP x level)|n|r|nProvides Nomad with a chance that his attacker will take magic damage equal to a fraction of Nomad's maximum hitpoints."

    set sandstorm = Spell.create('AHD2')
    set sandstorm.info = "Sandstorm|n|cfff4a460Target|r: |cff3399ffArea of Effect (150)|n|r|cfff4a460Range|r: |cff3399ff400|n|r|cfff4a460Damage|r: |cff3399ff(20 x level)|n|r|cfff4a460Slow|r: |cff3399ff50%|n|r|cfff4a460Duration|r: |cff3399ff(0.5 second x level)|n|r|cfff4a460Cooldown|r: |cff3399ff20 seconds|n|n|rNomad creates an artificial sandstorm which deals periodic magic damage, silences and slows enemy units inside the sandstorm."

    set blocking = Spell.create('AHD3')
    set blocking.info = "Blocking|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Speed Reduction|r: |cff3399ff(100% - (10% x level))|n|r|cfff4a460Cooldown|r: |cff3399ff10 seconds|n|r|nNomad sharpen his senses to block every melee enemy attacks but causes Nomad to move and attack slower."

    set wrathOfTheDesert = Spell.create('AHD4')
    set wrathOfTheDesert.info = "Wrath Of The Desert|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Duration|r: |cff3399ff(5 x level) seconds|n|r|cfff4a460Cooldown|r: |cff3399ff2 minutes|r|n|nNomad turns into a deadly form of Desert Predator. Gains 522 movement speed, maximum attack speed, no collision and attacks will deal magic damage."
endmodule

module NomadConfig
    set nomad = Hero.create('H00D')
    set nomad.faction = LIVING_FORCE
    set nomad.name = "Nomad"
    set nomad.scaleAdd = -0.35
    set nomad.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_Nomad.blp"
    set nomad.modelPath = "Models\\Units\\Nomad.mdl"
    set nomad.info = "<NOTHING YET>"
    set nomad.attribute = "20 +3.3   20 +2.4   20 +1.1"
    set nomad.primary = STR

    //Configure Spells
    set nomad.spell11 = cursedContact
    set nomad.spell21 = sandstorm
    set nomad.spell31 = blocking
    set nomad.spell41 = wrathOfTheDesert
    call nomad.end()
endmodule

module NomadButton
    call HeroButton.create(nomad)
endmodule