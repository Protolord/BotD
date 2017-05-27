globals
    Hero templar
    //Templar Spells
    Spell holyAura
    Spell holySpiral
    Spell sacrifice
    Spell beamingGlare
endglobals

module TemplarSpells
    set holyAura = Spell.create('AHJ1')
    set holyAura.info = "Holy Aura"

    set holySpiral = Spell.create('AHJ2')
    set holySpiral.info = "Holy Spiral"

    set sacrifice = Spell.create('AHJ3')
    set sacrifice.info = "Sacrifice"

    set beamingGlare = Spell.create('AHJ4')
    set beamingGlare.info = "Beaming Glare"
endmodule

module TemplarConfig
    set templar = Hero.create('H00J')
    set templar.faction = LIVING_FORCE
    set templar.name = "Templar"
    set templar.scaleAdd = -0.25
    set templar.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_Templar.blp"
    set templar.modelPath = "Models\\Units\\Templar.mdl"
    set templar.info = "<NOTHING YET>"
    set templar.attribute = "20 +3.0   20 +2.0   20 +0.75"
    set templar.primary = STR

    //Configure Spells
    set templar.spell11 = holyAura
    set templar.spell21 = holySpiral
    set templar.spell31 = sacrifice
    set templar.spell41 = beamingGlare
    call templar.end()
endmodule

module TemplarButton
    call HeroButton.create(templar)
endmodule