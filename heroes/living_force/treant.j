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
    set livingArmor.info = "Living Armor|n|cfff4a460Target|r: |cff3399ffFriendly Hero|n|r|cfff4a460Range|r: |cff3399ff1000|n|r|cfff4a460Physical Damage Reduction|r: |cff3399ff90%|n|r|cfff4a460Reduced Instances|r: |cff3399ff(1 x level) attacks|n|r|cfff4a460Duration|r: |cff3399ff30 seconds|r|n|nCreates a living armor on a friendly hero or structure allowing it to reduce the damage taken from a number of attacks."

    set forestSentinel = Spell.create('AHK2')
    set forestSentinel.info = "Forest Sentinel"

    set overgrowth = Spell.create('AHK3')
    set overgrowth.passive = true
    set overgrowth.info = "Overgrowth|n|cfff4a460Target|r: |cff3399ffPassive|n|r|cfff4a460Chance|r: |cff3399ff(3% + (3% x level))|n|r|cfff4a460Duration|r: |cff3399ff2 seconds|n|r|nWhen attacked, Treant has a chance to entangle attacking enemy unit."

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
    set treant.attribute = "20 +2.8   20 +3.3   20 +1.7"
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