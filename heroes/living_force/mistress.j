globals
    Hero mistress
    //Mistress Spells
    Spell evasion
    Spell banish
    Spell zeal
    Spell criticalStrike
endglobals

module MistressSpells
    set evasion = Spell.create('AHC1')
    set evasion.passive = true
    set evasion.info = "Evasion|n|cfff4a460Target|r: |cff3399ffPassive / Self|r|cfff4a460|nChance|r: |cff3399ff(5% x level)|n|r|nProvides Mistress with a chance to avoid attacks."

    set banish = Spell.create('AHC2')
    set banish.info = "Banish|n|cfff4a460Target|r: |cff3399ffEnemy hero|n|r|cfff4a460Range|r: |cff3399ff800|n|r|cfff4a460Slow|r: |cff3399ff50%|n|r|cfff4a460Duration|r: |cff3399ff(0.5 x level) seconds|n|r|cfff4a460Cooldown|r: |cff3399ff20 seconds|r|n|nTurns the target hero ethereal slowing it and renders it unable to attack or be attacked. Banished units can still cast spells and magic damage inflicted upon them is amplified to 400%."

    set zeal = Spell.create('AHC3')
    set zeal.info = "Zeal|n|cfff4a460Target|r: |cff3399ffEnemy unit|n|r|cfff4a460Range|r: |cff3399ffMelee|n|r|cfff4a460Number of Attacks|r: |cff3399ff(1 x level)|n|r|cfff4a460Cooldown|r: |cff3399ff20 seconds|r|n|nMistress attacks with such passion that a number of swift attacks can be dealt within a blink of an eye. Attacks trigger all effects."

    set criticalStrike = Spell.create('AHC4')
    set criticalStrike.passive = true
    set criticalStrike.info = "Critical Strike|n|cfff4a460Target|r: |cff3399ffPassive / Enemy Unit|n|r|cfff4a460Range|r: |cff3399ffMelee|n|r|cfff4a460Chance|r: |cff3399ff35%|n|r|cfff4a460Damage Multiplier|r: |cff3399ff(1.25 x level)|r|n|nMistress has a chance to deal extra damage to the attacked enemy unit."
endmodule

module MistressConfig
    set mistress = Hero.create('H00C')
    set mistress.faction = LIVING_FORCE
    set mistress.name = "Mistress"
    set mistress.scaleAdd = 0.1
    set mistress.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_Mistress.blp"
    set mistress.modelPath = "Models\\Units\\Mistress.mdl"
    set mistress.info = "<NOTHING YET>"
    set mistress.attribute = "20 +2.5   20 +3.0   20 +1.5"
    set mistress.primary = AGI

    //Configure Spells
    set mistress.spell11 = evasion
    set mistress.spell21 = banish
    set mistress.spell31 = zeal
    set mistress.spell41 = criticalStrike
    call mistress.end()
endmodule

module MistressButton
    call HeroButton.create(mistress)
endmodule