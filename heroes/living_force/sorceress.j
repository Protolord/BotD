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
    set feedback.info = "Feedback"

    set sonicBlast = Spell.create('AHI2')
    set sonicBlast.info = "Sonic Blast"

    set strongMind = Spell.create('AHI3')
    set strongMind.info = "Strong Mind"

    set wisdomReflection = Spell.create('AHI4')
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
    set sorceress.attribute = "20 +1.0   20 +1.5   20 +3.5"
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