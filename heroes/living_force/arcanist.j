globals
    Hero arcanist
    //Arcanist Spells
    Spell vortexShield
    Spell etherealForce
    Spell energyField
    Spell arcanePierce
endglobals

module ArcanistSpells
    set vortexShield = Spell.create('AHE1')
    set vortexShield.info = "Vortex Shield"

    set etherealForce = Spell.create('AHE2')
    set etherealForce.info = "Ethereal Force"

    set energyField = Spell.create('AHE3')
    set energyField.info = "Energy Field"

    set arcanePierce = Spell.create('AHE4')
    set arcanePierce.info = "Arcane Pierce"
endmodule

module ArcanistConfig
    set arcanist = Hero.create('H00E')
    set arcanist.faction = LIVING_FORCE
    set arcanist.name = "Arcanist"
    set arcanist.scaleAdd = 0.15
    set arcanist.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_Arcanist.blp"
    set arcanist.modelPath = "Models\\Units\\Arcanist.mdl"
    set arcanist.info = "<NOTHING YET>"
    set arcanist.attribute = "20 +3.0   20 +2.0   20 +0.75"
    set arcanist.primary = STR

    //Configure Spells
    set arcanist.spell11 = vortexShield
    set arcanist.spell21 = etherealForce
    set arcanist.spell31 = energyField
    set arcanist.spell41 = arcanePierce
    call arcanist.end()
endmodule

module ArcanistButton
    call HeroButton.create(arcanist)
endmodule