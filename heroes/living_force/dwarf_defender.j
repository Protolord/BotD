globals
    Hero dwarfDefender
    //DwarfDefender Spells
    Spell thunderClap
    Spell stormBolt
    Spell treasury
    Spell ancestralPower
endglobals

module DwarfDefenderSpells
    set thunderClap = Spell.create('AH31')
    set thunderClap.info = "Thunder Clap|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Radius|r: |cff3399ff350|n|r|cfff4a460Slow|r: |cff3399ff60%|n|r|cfff4a460Duration|r: |cff3399ff(0.1 x %Lost HP + 1) seconds|n|r|cfff4a460Max Duration|r: |cff3399ff(1 x level + 1) seconds|n|r|cfff4a460Cooldown|r: |cff3399ff10 seconds|r|n|nSlams the ground to temporarily slow down movement speed of all affected enemies. Slow duration is based on the target's hitpoints."

    set stormBolt = Spell.create('AH32')
    set stormBolt.info = "Storm Bolt|n|cfff4a460Target|r: |cff3399ffEnemy unit|n|r|cfff4a460Range|r: |cff3399ff700|n|r|cfff4a460Damage|r: |cff3399ff(60 x level)|n|r|cfff4a460Cooldown|r: |cff3399ff20 seconds|r|n|nDwarf Defender throws a magical hammer to deal magic damage to an enemy unit."

    set treasury = Spell.create('AH33')
    set treasury.info = "Treasury"

    set ancestralPower = Spell.create('AH34')
    set ancestralPower.info = "Ancestral Power|n|cfff4a460Target|r: |cff3399ffPoint|n|r|cfff4a460Range|r: |cff3399ff750|n|r|cfff4a460Stomp Damage|r: |cff3399ff(5% x level) Max HP|n|r|cfff4a460Cooldown|r: |cff3399ff120 seconds|r|n|nDwarf Defender sends a wave of stomps towards the target point. Each stomp deals damage equal to a certain percentrage of target hitpoints. Stomps will appear in the range of 150 of each other beginning from the position of Dwarf Defender every 0.25 seconds."
endmodule

module DwarfDefenderConfig
    set dwarfDefender = Hero.create('H003')
    set dwarfDefender.faction = LIVING_FORCE
    set dwarfDefender.name = "Dwarf Defender"
    set dwarfDefender.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_DwarfDefender.blp"
    set dwarfDefender.scaleAdd = 0.1
    set dwarfDefender.modelPath = "Models\\Units\\DwarfDefender.mdx"
    set dwarfDefender.info = "<NOTHING YET>"
    set dwarfDefender.attribute = "19 +3.0    7 +4.3   12 +1.5"
    set dwarfDefender.primary = STR
    
    //Configure Spells
    set dwarfDefender.spell11 = thunderClap
    set dwarfDefender.spell21 = stormBolt
    set dwarfDefender.spell31 = treasury
    set dwarfDefender.spell41 = ancestralPower
    call dwarfDefender.end()
endmodule

module DwarfDefenderButton
    call HeroButton.create(dwarfDefender)
endmodule