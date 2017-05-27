globals
    Hero treant
    //Treant Spells
    Spell livingArmor
    Spell forestSentinel
    Spell overgrowth
    Spell natureWrath
endglobals

module TreantSpells
    set livingArmor = Spell.create('AHK1')
    set livingArmor.info = "Living Armor"

    set forestSentinel = Spell.create('AHK2')
    set forestSentinel.info = "Forest Sentinel"

    set overgrowth = Spell.create('AHK3')
    set overgrowth.info = "Overgrowth"

    set natureWrath = Spell.create('AHK4')
    set natureWrath.info = "Nature Wrath"
endmodule

module TreantConfig
    set treant = Hero.create('H00K')
    set treant.faction = LIVING_FORCE
    set treant.name = "Treant"
    set treant.scaleAdd = -0.65
    set treant.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_Treant.blp"
    set treant.modelPath = "Models\\Units\\Treant.mdl"
    set treant.info = "<NOTHING YET>"
    set treant.attribute = "20 +2.0   20 +3.0   20 +1.3"
    set treant.primary = AGI

    //Configure Spells
    set treant.spell11 = livingArmor
    set treant.spell21 = forestSentinel
    set treant.spell31 = overgrowth
    set treant.spell41 = natureWrath
    call treant.end()
endmodule

module TreantButton
    call HeroButton.create(treant)
endmodule