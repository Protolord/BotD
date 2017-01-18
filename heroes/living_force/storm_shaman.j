globals
    Hero stormShaman
    //StormShaman Spells
endglobals

module StormShamanSpells
    
endmodule

module StormShamanConfig
    set stormShaman = Hero.create('HSto')
    set stormShaman.faction = LIVING_FORCE
    set stormShaman.name = "Storm Shaman"
    set stormShaman.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_VampireLord.blp"
    set stormShaman.scaleAdd = 0.25
    set stormShaman.modelPath = "Units\\Creeps\\OrcWarlock\\OrcWarlock.mdl"
    set stormShaman.info = "<NOTHING YET>"
    set stormShaman.attribute = "19 +3.0    7 +4.3   12 +1.5"
    set stormShaman.primary = STR
    
    //Configure Spells
    set stormShaman.innateSpell = 0
    set stormShaman.spell11 = 0
    set stormShaman.spell21 = 0
    set stormShaman.spell31 = 0
    set stormShaman.spell41 = 0
    call stormShaman.end()
endmodule

module StormShamanButton
    call HeroButton.create(stormShaman)
endmodule