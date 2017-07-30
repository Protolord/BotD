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
    set seamansWill.info = "Seaman's Will|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Radius|r: |cff3399ff350|n|r|cfff4a460Damage|r: |cff3399ff(35 x ability level)|n|r|cfff4a460Slow|r: |cff3399ff50%|n|r|cfff4a460Duration|r: |cff3399ff(0.4 x ability level) seconds|n|r|cfff4a460Cooldown|r: |cff3399ff20 seconds|r|n|nViking blows with a Seaman's rage dealing magic damage around him, temporarily slows down their movement speed and makes them to hold position."

    set oceansForce = Spell.create('AHL3')
    set oceansForce.passive = true
    set oceansForce.info = "Ocean's Force|n|cfff4a460Target|r: |cff3399ffPassive|n|r|cfff4a460Radius|r: |cff3399ff200|n|r|cfff4a460Cleave Damage|r: |cff3399ff(25% x ability level)|n|r|nViking attacks with such force that percentrage of his damage is damaging enemies nearby the primary target."

    set ivoryWave = Spell.create('AHL4')
    set ivoryWave.passive = true
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
    set viking.attribute = "20 +2.2   20 +4.0   20 +1.0"
    set viking.primary = AGI

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