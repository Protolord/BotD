globals
    Hero sorceress
    //Sorceress Spells
    Spell feedback
    Spell sonicBlast
    Spell strongMind
    Spell wisdomReflection
endglobals

module SorceressSpells
    set feedback = Spell.create('AHI1')
    set feedback.passive = true
    set feedback.info = "Feedback|n|cfff4a460Target|r: |cff3399ffPassive / Enemy unit|n|r|cfff4a460Range|r: |cff3399ffMelee|n|r|cfff4a460Mana Burned|r: |cff3399ff(3 x level)|r|n|nSorceress burns an opponent's mana each attack. Deals 300% of the mana burned as damage to the target."

    set sonicBlast = Spell.create('AHI2')
    set sonicBlast.info = "Sonic Blast"

    set strongMind = Spell.create('AHI3')
    set strongMind.info = "Strong Mind|n|cfff4a460Target|r: |cff3399ffEnemy unit|n|r|cfff4a460Range|r: |cff3399ff600|n|r|cfff4a460Intelligence Steal|r: |cff3399ff(1 x level)|n|r|cfff4a460Duration|r: |cff3399ff60 seconds|n|r|cfff4a460Cooldown|r: |cff3399ff20 seconds|r|n|nSorceress temporarily steals intelligence from the target."

    set wisdomReflection = Spell.create('AHI4')
    set wisdomReflection.passive = true
    set wisdomReflection.info = "Wisdom Reflection"
endmodule

module SorceressConfig
    set sorceress = Hero.create('H00I')
    set sorceress.faction = LIVING_FORCE
    set sorceress.name = "Sorceress"
    set sorceress.scaleAdd = 0.10
    set sorceress.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_Sorceress.blp"
    set sorceress.modelPath = "Models\\Units\\Sorceress.mdl"
    set sorceress.info = "<NOTHING YET>"
    set sorceress.attribute = "20 +1.0   20 +3.0   20 +4.0"
    set sorceress.primary = INT

    //Configure Spells
    set sorceress.spell11 = feedback
    set sorceress.spell21 = sonicBlast
    set sorceress.spell31 = strongMind
    set sorceress.spell41 = wisdomReflection
    call sorceress.end()
endmodule

module SorceressButton
    call HeroButton.create(sorceress)
endmodule