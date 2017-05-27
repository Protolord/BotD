globals
    Hero witch
    //Witch Spells
    Spell frogTransformation
    Spell envenomedDart
    Spell sanctuary
    Spell spiritualWall
endglobals

module WitchSpells
    set frogTransformation = Spell.create('AH71')
    set frogTransformation.info = "Frog Transformation|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Speed Bonus|r: |cff3399ff50%|n|r|cfff4a460Chance to Evade|r: |cff3399ff90%|n|r|cfff4a460Duration|r: |cff3399ff(1 x level) seconds|n|r|cfff4a460Cooldown|r: |cff3399ff20 seconds|r|n|nWitch transforms herself into a frog gaining movement speed bonus, a chance to evade most targeted spells and allows her to pass through any obstacles."

    set envenomedDart = Spell.create('AH72')
    set envenomedDart.info = "Envenomed Dart|n|cfff4a460Target|r: |cff3399ffEnemy unit|n|r|cfff4a460Range|r: |cff3399ff300|n|r|cfff4a460Slow|r: |cff3399ff75%|n|r|cfff4a460Duration|r: |cff3399ff(0.75 second x level)|n|r|cfff4a460Cooldown|r: |cff3399ff20 seconds|r|n|nWitch hurls an Envenomed Dart to temporarily slow down target's movement speed."

    set sanctuary = Spell.create('AH73')
    set sanctuary.info = "Sanctuary|n|cfff4a460Target|r: |cff3399ffAllied hero|n|r|cfff4a460Range|r: |cff3399ff(750 x level)|n|r|cfff4a460Cooldown|r: |cff3399ff20 seconds|r|n|nWitch channels the allied target hero's spirit pulling it into her. When the spirit reaches her, the physical body of the target hero is instantly teleported to her location. Target is teleported to the current spirit location when Witch gets interrupted."

    set spiritualWall = Spell.create('AH74')
    set spiritualWall.info = "Spiritual Wall|n|cfff4a460Target|r: |cff3399ffSelf, Channel|n|r|cfff4a460Radius|r: |cff3399ff400|n|r|cfff4a460Slow|r: |cff3399ff90%|n|r|cfff4a460Duration|r: |cff3399ff(10 x level) seconds|n|r|cfff4a460Cooldown|r: |cff3399ff60 seconds|r|n|nWitch conjures a spiritual wall around her slowing enemy units inside the walls. Spiritual Wall is lost when Witch gets interrupted."
endmodule

module WitchConfig
    set witch = Hero.create('H007')
    set witch.faction = LIVING_FORCE
    set witch.name = "Witch"
    set witch.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_Witch.blp"
    set witch.modelPath = "Models\\Units\\Witch.mdl"
    set witch.info = "<NOTHING YET>"
    set witch.attribute = "20 +1.0   20 +1.5   20 +3.5"
    set witch.primary = INT

    //Configure Spells
    set witch.spell11 = frogTransformation
    set witch.spell21 = envenomedDart
    set witch.spell31 = sanctuary
    set witch.spell41 = spiritualWall
    call witch.end()
endmodule

module WitchButton
    call HeroButton.create(witch)
endmodule