globals
    Hero pathfinder
    //Pathfinder Spells
    Spell adrenaline
    Spell maim
    Spell lasso
    Spell tracking
endglobals

module PathfinderSpells
    set adrenaline = Spell.create('AHN1')
    set adrenaline.passive = true
    set adrenaline.info = "Adrenaline|n|cfff4a460Target|r: |cff3399ffPassive|r|cfff4a460|nRange|r: |cff3399ff(100 x ability level)|n|r|cfff4a460Bonus|r: |cff3399ff(5% x ability level)|n|r|nWhenever Pathfinder spots a visible Ancient in range her movement speed is passively increased."

    set maim = Spell.create('AHN2')
    set maim.info = "Maim"

    set lasso = Spell.create('AHN3')
    set lasso.info = "Lasso"

    set tracking = Spell.create('AHN4')
    set tracking.info = "Tracking"
endmodule

module PathfinderConfig
    set pathfinder = Hero.create('H00N')
    set pathfinder.faction = LIVING_FORCE
    set pathfinder.name = "Pathfinder"
    set pathfinder.scaleAdd = -0.2
    set pathfinder.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_Pathfinder.blp"
    set pathfinder.modelPath = "Models\\Units\\Pathfinder.mdl"
    set pathfinder.info = "<NOTHING YET>"
    set pathfinder.attribute = "20 +2.0   20 +3.7   20 +1.6"
    set pathfinder.primary = AGI

    //Configure Spells
    set pathfinder.spell11 = adrenaline
    set pathfinder.spell21 = maim
    set pathfinder.spell31 = lasso
    set pathfinder.spell41 = tracking
    call pathfinder.end()
endmodule

module PathfinderButton
    call HeroButton.create(pathfinder)
endmodule