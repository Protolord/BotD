globals
    Hero guardian
    //Guardian Spells
    Spell lightningShield
    Spell slow
    Spell haste
    Spell fistOfHeavens
endglobals

module GuardianSpells
    set lightningShield = Spell.create('AH91')
    set lightningShield.info = "Lightning Shield"

    set slow = Spell.create('AH92')
    set slow.info = "Slow|n|cfff4a460Target|r: |cff3399ffEnemy unit|n|r|cfff4a460Range|r: |cff3399ff700|n|r|cfff4a460Duration|r: |cff3399ff(0.5 second x level)|n|r|cfff4a460Cooldown|r: |cff3399ff15 seconds|r|n|nTemporarily slows down movement speed by 50%."

    set haste = Spell.create('AH93')
    set haste.info = "Haste"

    set fistOfHeavens = Spell.create('AH94')
    set fistOfHeavens.info = "Fist Of Heavens|n|cfff4a460Target|r: |cff3399ffEnemy unit|r|n|cfff4a460Range|r: |cff3399ff700|r|n|cfff4a460Damage|r: |cff3399ff(12.5% x level)|r|n|cfff4a460Cooldown|r: |cff3399ff90 seconds|n|n|rGuardian will send a Thunderbolt from Heaven which on impact will deal magic damage equal to a certain percentrage of target's maximum hitpoints. Causes mini-stun."
endmodule

module GuardianConfig
    set guardian = Hero.create('H009')
    set guardian.faction = LIVING_FORCE
    set guardian.name = "Guardian"
    set guardian.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_Guardian.blp"
    set guardian.modelPath = "Models\\Units\\Guardian.mdl"
    set guardian.info = "<NOTHING YET>"
    set guardian.attribute = "20 +2.6   20 +2.3   20 +2.1"
    set guardian.primary = STR

    //Configure Spells
    set guardian.spell11 = lightningShield
    set guardian.spell21 = slow
    set guardian.spell31 = haste
    set guardian.spell41 = fistOfHeavens
    call guardian.end()
endmodule

module GuardianButton
    call HeroButton.create(guardian)
endmodule