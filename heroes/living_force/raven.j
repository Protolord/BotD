globals
    Hero raven
    //Raven Spells
    Spell spiritLink
    Spell shadowStrike
    Spell ultraVision
    Spell deadlyStrike
endglobals

module RavenSpells
    set spiritLink = Spell.create('AHF1')
    set spiritLink.info = "Spirit Link|n|cfff4a460Target|r: |cff3399ffFriendly Hero|n|r|cfff4a460Range|r: |cff3399ff700|n|r|cfff4a460Linked Units|r: |cff3399ff(2 + 0.5 x level)|n|r|cfff4a460Duration|r: |cff3399ff15 seconds|n|r|cfff4a460Cooldown|r: |cff3399ff20 seconds|r|n|nLinks units in a chain that will evenly distribute damage taken with other spirit linked units."

    set shadowStrike = Spell.create('AHF2')
    set shadowStrike.info = "Shadow Strike|n|cfff4a460Target|r: |cff3399ffEnemy unit|n|r|cfff4a460Range|r: |cff3399ff800|n|r|cfff4a460Duration|r: |cff3399ff(0.5 second x level)|n|r|cfff4a460Damage|r: |cff3399ff(80 x level)|n|r|cfff4a460Slow|r: |cff3399ff40%|n|r|cfff4a460Cooldown|r: |cff3399ff20 seconds|r|n|nRaven hurls a poisoned dagger to deal poison damage and temporarily slows down movement speed."

    set ultraVision = Spell.create('AHF3')
    set ultraVision.passive = true
    set ultraVision.info = "Ultra Vision|n|cfff4a460Target|r: |cff3399ffPassive|n|r|cfff4a460Sight|r: |cff3399ff(100 x level)|n|r|nPassively extends Raven's vision at night and ignores terrain obstacles."

    set deadlyStrike = Spell.create('AHF4')
    set deadlyStrike.passive = true
    set deadlyStrike.info = "Deadly Strike|n|cfff4a460Target|r: |cff3399ffEnemy unit|n|r|cfff4a460Chance|r: |cff3399ff(0.5% x level)|n|r|cfff4a460Range|r: |cff3399ffMelee|r|n|nPassive ability providing Raven with a slight chance to kill any enemy unit instantly."
endmodule

module RavenConfig
    set raven = Hero.create('H00F')
    set raven.faction = LIVING_FORCE
    set raven.name = "Raven"
    set raven.scaleAdd = 0.15
    set raven.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_Raven.blp"
    set raven.modelPath = "Models\\Units\\Raven.mdl"
    set raven.info = "<NOTHING YET>"
    set raven.attribute = "20 +2.2   20 +3.3   20 +2.0"
    set raven.primary = AGI

    //Configure Spells
    set raven.spell11 = spiritLink
    set raven.spell21 = shadowStrike
    set raven.spell31 = ultraVision
    set raven.spell41 = deadlyStrike
    call raven.end()
endmodule

module RavenButton
    call HeroButton.create(raven)
endmodule