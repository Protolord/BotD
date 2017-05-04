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
    set mirage.info = "Mirage|n|cfff4a460Target|r: |cff3399ffAlly Hero|n|r|cfff4a460Range|r: |cff3399ff800|n|r|cfff4a460Duration|r: |cff3399ff((0.6 x level) + 4) seconds|n|r|cfff4a460Cooldown|r: |cff3399ff20 seconds|r|n|nCreates a Mirage on the target hero making it immune to physical damage for a short period of time."

    set frostNova = Spell.create('AH42')
    set frostNova.info = "Frost Nova|n|cfff4a460Target|r: |cff3399ffUnit|n|r|cfff4a460Radius|r: |cff3399ff200|n|r|cfff4a460Range|r: |cff3399ff800|n|r|cfff4a460Damage|r: |cff3399ff(60 x level)|n|r|cfff4a460Slow|r: |cff3399ff50%|n|r|cfff4a460Duration|r: |cff3399ff(0.5 second x level)|n|r|cfff4a460Cooldown|r: |cff3399ff20 seconds|r|n|nElementalist sends a blast of cold energy, deals magic damage to all enemies around target unit and temporarily slows their movement speed."

    set frostArmor = Spell.create('AH43')
    set frostArmor.info = "Frost Armor|n|cfff4a460Target|r: |cff3399ffAllied unit|n|r|cfff4a460Range|r: |cff3399ff800|n|r|cfff4a460Slow|r: |cff3399ff50%|n|r|cfff4a460Slow Duration|r: |cff3399ff(0.5 second x level)|n|r|cfff4a460Duration|r: |cff3399ff20 seconds|r|cfff4a460|nCooldown|r: |cff3399ff1 second|r|n|nElementalist creates a Frost Armor on targeted ally which makes all melee attackers to have their movement and attack speed reduced for a short period of time."

    set fireDevastation = Spell.create('AH44')
    set fireDevastation.info = "Fire Devastation|n|cfff4a460Target|r: |cff3399ffEnemy Unit|n|r|cfff4a460Manacost|r: |cff3399ffEntire Mana Pool|n|r|cfff4a460Range|r: |cff3399ff800|n|r|cfff4a460Damage|r: |cff3399ff(25% x level) of Max Mana|n|r|cfff4a460Cooldown|r: |cff3399ff90 seconds|r|n|nElementalist can use his entire mana capacity to deal magic damage equal to a certain percentrage of his mana."
endmodule

module ElementalistConfig
    set elementalist = Hero.create('H004')
    set elementalist.faction = LIVING_FORCE
    set elementalist.name = "Elementalist"
    set elementalist.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_Elementalist.blp"
    set elementalist.modelPath = "Units\\Human\\HeroBloodElf\\HeroBloodElf.mdl"
    set elementalist.info = "<NOTHING YET>"
    set elementalist.attribute = "20 +1.0   20 +1.5   20 +3.5"
    set elementalist.primary = INT

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