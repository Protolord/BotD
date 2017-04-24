globals
    Hero elementalist
    //Elementalist Spells
    Spell mirage
    Spell frostNova
    Spell frostArmor
    Spell fireDevastation
endglobals

module ElementalistSpells
    set mirage = Spell.create('AH41')
    set mirage.info = "Mirage"

    set frostNova = Spell.create('AH42')
    set frostNova.info = "Frost Nova|n|cfff4a460Target|r: |cff3399ffUnit|n|r|cfff4a460Radius|r: |cff3399ff200|n|r|cfff4a460Range|r: |cff3399ff800|n|r|cfff4a460Damage|r: |cff3399ff(60 x ability level)|n|r|cfff4a460Slow|r: |cff3399ff50%|n|r|cfff4a460Duration|r: |cff3399ff(0.5 second x ability level)|n|r|cfff4a460Cooldown|r: |cff3399ff20 seconds|r|n|nElementalist sends a blast of cold energy, deals magic damage to all enemies around target unit and temporarily slows their movement speed."

    set frostArmor = Spell.create('AH43')
    set frostArmor.info = "Frost Armor"

    set fireDevastation = Spell.create('AH44')
    set fireDevastation.info = "Fire Devastation"
endmodule

module ElementalistConfig
    set elementalist = Hero.create('H004')
    set elementalist.faction = LIVING_FORCE
    set elementalist.name = "Elementalist"
    set elementalist.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_Elementalist.blp"
    set elementalist.modelPath = "Units\\Human\\HeroBloodElf\\HeroBloodElf.mdl"
    set elementalist.info = "<NOTHING YET>"
    set elementalist.attribute = "19 +3.0    7 +4.3   12 +1.5"
    set elementalist.primary = STR
    
    //Configure Spells
    set elementalist.spell11 = mirage
    set elementalist.spell21 = frostNova
    set elementalist.spell31 = frostArmor
    set elementalist.spell41 = fireDevastation
    call elementalist.end()
endmodule

module ElementalistButton
    call HeroButton.create(elementalist)
endmodule