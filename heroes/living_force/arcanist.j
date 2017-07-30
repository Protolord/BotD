globals
    Hero arcanist
    //Arcanist Spells
    Spell vortexShield
    Spell etherealForce
    Spell energyField
    Spell arcanePierce
endglobals

module ArcanistSpells
    set vortexShield = Spell.create('AHE1')
    set vortexShield.info = "Vortex Shield|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Charges|r: |cff3399ff(1 x level)|n|r|cfff4a460Cooldown|r: |cff3399ff1 minute|r|n|nCreates a vortex of arcane energy around Arcanist with a number of charges that blocks incoming physical damage. Shield lasts until it is destroyed and can be extended with more charges. Number of charges cannot exceed original number of charges."

    set etherealForce = Spell.create('AHE2')
    set etherealForce.info = "Ethereal Force|n|cfff4a460Target|r: |cff3399ffEnemy unit|n|r|cfff4a460Range|r: |cff3399ff600|n|r|cfff4a460Duration|r: |cff3399ff(0.5 second x level)|n|r|cfff4a460Damage|r: |cff3399ff(50 x level)|n|r|cfff4a460Slow|r: |cff3399ff50%|n|r|cfff4a460Cooldown|r: |cff3399ff20 seconds|r|n|nArcanist releases an ethereal energy dealing magic damage and temporairly slowing enemy unit movement speed."

    set energyField = Spell.create('AHE3')
    set energyField.info = "Energy Field|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Radius|r: |cff3399ff1000|n|r|cfff4a460Manacost per second|r: |cff3399ff(20  x level)|n|r|cfff4a460Damage per second|r: |cff3399ff(40  x level)|n|r|nArcanist can activate powerful Force Field and deal magic damage to all enemy units in range."

    set arcanePierce = Spell.create('AHE4')
    set arcanePierce.info = "Arcane Pierce|n|cfff4a460Target|r: |cff3399ffAncient|n|r|cfff4a460Range|r: |cff3399ffMelee|n|r|cfff4a460Hitpoints Threshold|r: |cff3399ff(10% x level)|n|r|cfff4a460Damage|r: |cff3399ff(500 x level)|n|r|cfff4a460Cooldown|r: |cff3399ff90 seconds|r|n|nInstantly kills target unit if its hitpoints is below the kill threshold or deals damage otherwise."
endmodule

module ArcanistConfig
    set arcanist = Hero.create('H00E')
    set arcanist.faction = LIVING_FORCE
    set arcanist.name = "Arcanist"
    set arcanist.scaleAdd = 0.35
    set arcanist.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_Arcanist.blp"
    set arcanist.modelPath = "Models\\Units\\Arcanist.mdl"
    set arcanist.info = "<NOTHING YET>"
    set arcanist.attribute = "20 +2.0   20 +3.0   20 +2.0"
    set arcanist.primary = AGI

    //Configure Spells
    set arcanist.spell11 = vortexShield
    set arcanist.spell21 = etherealForce
    set arcanist.spell31 = energyField
    set arcanist.spell41 = arcanePierce
    call arcanist.end()
endmodule

module ArcanistButton
    call HeroButton.create(arcanist)
endmodule