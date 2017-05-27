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
    set spiritLink.info = "Spirit Link"

    set shadowStrike = Spell.create('AHF2')
    set shadowStrike.info = "Shadow Strike"

    set ultraVision = Spell.create('AHF3')
    set ultraVision.info = "Ultra Vision"

    set deadlyStrike = Spell.create('AHF4')
    set deadlyStrike.info = "Deadly Strike"
endmodule

module RavenConfig
    set raven = Hero.create('H00F')
    set raven.faction = LIVING_FORCE
    set raven.name = "Raven"
    set raven.scaleAdd = 0.15
    set raven.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_Raven.blp"
    set raven.modelPath = "Models\\Units\\Raven.mdl"
    set raven.info = "<NOTHING YET>"
    set raven.attribute = "20 +2.0   20 +3.0   20 +1.3"
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