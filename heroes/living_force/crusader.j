globals
    Hero crusader
    //Crusader Spells
    Spell destinction
    Spell enlight
    Spell auraOfPrayer
    Spell avander
endglobals

module CrusaderSpells
    set destinction = Spell.create('AH21')
    set destinction.info = "Destinction|n|cfff4a460Target|r: |cff3399ffAlly Units|n|r|cfff4a460Range|r: |cff3399ff300|n|r|cfff4a460Duration|r: |cff3399ff(0.5 x ability level) seconds|n|r|cfff4a460Cooldown|r: |cff3399ff20 seconds|r|n|nDestincts an ally unit and temporarily turns it invulnerable but disables it's ability to attack."

    set enlight = Spell.create('AH22')
    set enlight.info = "Enlight"

    set auraOfPrayer = Spell.create('AH23')
    set auraOfPrayer.passive = true
    set auraOfPrayer.info = "Aura Of Prayer|n|cfff4a460Target|r: |cff3399ffPassive / Self and Allies|r|cfff4a460|nRange|r: |cff3399ff900|n|r|cfff4a460HP/Second|r: |cff3399ff(2 x ability level)|n|r|nAll allies near Crusader gain extra hitpoints regeneration. Bonus regeneration weakens with distance."

    set avander = Spell.create('AH24')
    set avander.info = "Avander"
endmodule

module CrusaderConfig
    set crusader = Hero.create('H002')
    set crusader.faction = LIVING_FORCE
    set crusader.name = "Crusader"
    set crusader.scaleAdd = 0.2
    set crusader.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_Crusader.blp"
    set crusader.modelPath = "Models\\Units\\Crusader.mdl"
    set crusader.info = "<NOTHING YET>"
    set crusader.attribute = "19 +3.0    7 +4.3   12 +1.5"
    set crusader.primary = STR
    
    //Configure Spells
    set crusader.spell11 = destinction
    set crusader.spell21 = enlight
    set crusader.spell31 = auraOfPrayer
    set crusader.spell41 = avander
    call crusader.end()
endmodule

module CrusaderButton
    call HeroButton.create(crusader)
endmodule