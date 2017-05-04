globals
    Hero stormShaman
    //StormShaman Spells
    Spell tornado
    Spell chainLightning
    Spell staticCharge
    Spell storm
endglobals

module StormShamanSpells
    set tornado = Spell.create('AH11')
    set tornado.info = "Tornado|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Evasion|r: |cff3399ff95%|n|r|cfff4a460Duration|r: |cff3399ff(1 second x level)|n|r|cfff4a460Cooldown|r: |cff3399ff20 seconds|r|n|nStorm Shaman creates an artificial Tornado to hide in it and temporarily grant himself evasion."

    set chainLightning = Spell.create('AH12')
    set chainLightning.info = "Chain Lightning|n|cfff4a460Target|r: |cff3399ffEnemy Unit|n|r|cfff4a460Range|r: |cff3399ff700|n|r|cfff4a460Bounce Range|r: |cff3399ff500|n|r|cfff4a460Number of Bounces|r: |cff3399ff2|n|r|cfff4a460Damage|r: |cff3399ff(70 x level)|n|r|cfff4a460Cooldown|r: |cff3399ff20 seconds|r|n|nStorm Shaman creates a lightning bolt to deal magic damage to main target and two units around it."

    set staticCharge = Spell.create('AH13')
    set staticCharge.info = "Static Charge|n|cfff4a460Target|r: |cff3399ffPassive|n|r|cfff4a460Damage|r: |cff3399ff(20% + 5% x level) Max HP|n|r|nAny time Storm Shaman is a target of a direct enemy spell he releases a Static Charge that deals decent amount of damage to the caster based on Storm Shaman's Max HP. Cannot deal damage greater than Storm Shaman's current HP."

    set storm = Spell.create('AH14')
    set storm.info = "Storm|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Radius|r: |cff3399ff900|n|r|cfff4a460Damage/Second|r: |cff3399ff1000|n|r|cfff4a460Self Slow|r: |cff3399ff25%|n|r|cfff4a460Duration|r: |cff3399ff(10 x level) seconds|n|r|cfff4a460Cooldown|r: |cff3399ff120 seconds|r|n|nStorm Shaman summons a powerful storm which deals magic damage to all enemies in range of 900 per second but causes Storm Shaman to move slower."
endmodule

module StormShamanConfig
    set stormShaman = Hero.create('H001')
    set stormShaman.faction = LIVING_FORCE
    set stormShaman.name = "Storm Shaman"
    set stormShaman.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_StormShaman.blp"
    set stormShaman.modelPath = "Models\\Units\\StormShaman.mdl"
    set stormShaman.info = "<NOTHING YET>"
    set stormShaman.attribute = "20 +1.0   20 +1.5   20 +3.5"
    set stormShaman.primary = INT

    //Configure Spells
    set stormShaman.spell11 = tornado
    set stormShaman.spell21 = chainLightning
    set stormShaman.spell31 = staticCharge
    set stormShaman.spell41 = storm
    call stormShaman.end()
endmodule

module StormShamanButton
    call HeroButton.create(stormShaman)
endmodule