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
    set slow.info = "Slow"

    set haste = Spell.create('AH93')
    set haste.info = "Haste"

    set fistOfHeavens = Spell.create('AH94')
    set fistOfHeavens.info = "Fist Of Heavens"
endmodule

module GuardianConfig
    set guardian = Hero.create('H009')
    set guardian.faction = LIVING_FORCE
    set guardian.name = "Guardian"
    set guardian.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_Guardian.blp"
    set guardian.modelPath = "Models\\Units\\Guardian.mdl"
    set guardian.info = "<NOTHING YET>"
    set guardian.attribute = "20 +3.0   20 +2.0   20 +0.75"
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