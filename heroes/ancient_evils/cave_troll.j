globals
    Hero caveTroll
    //CaveTroll Spells
endglobals

module CaveTrollSpells
    
endmodule

module CaveTrollConfig
    set caveTroll = Hero.create('UCav')
    set caveTroll.faction = ANCIENT_EVILS
    set caveTroll.name = "Cave Troll"
    set caveTroll.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_CaveTroll.blp"
    set caveTroll.scaleAdd = -0.45
    set caveTroll.modelPath = "Models\\Units\\CaveTroll.mdx"
    set caveTroll.info = "<NOTHING YET>"
    set caveTroll.attribute = "19 +4.5    7 +2.5   12 +1.2"
    set caveTroll.primary = STR
    
    //Configure Spells
    set caveTroll.innateSpell = 0
    set caveTroll.spell11 = 0
    set caveTroll.spell12 = 0
    set caveTroll.spell13 = 0
    set caveTroll.spell14 = 0
    set caveTroll.spell21 = 0
    set caveTroll.spell22 = 0
    set caveTroll.spell23 = 0
    set caveTroll.spell24 = 0
    set caveTroll.spell31 = 0
    set caveTroll.spell32 = 0
    set caveTroll.spell33 = 0
    set caveTroll.spell34 = 0
    set caveTroll.spell41 = 0
    set caveTroll.spell42 = 0
    set caveTroll.spell43 = 0
    set caveTroll.spell44 = 0
    call caveTroll.end()
endmodule

module CaveTrollButton
    call HeroButton.create(caveTroll)
endmodule