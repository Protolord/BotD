globals
    Hero gargoyle
    //Gargoyle Spells
    Spell deadlyRepulse
    Spell crack
    Spell earthShatter
    Spell stoneGaze
    Spell terror
    Spell upliftPurpose
    Spell fissure
    Spell rockHard
    Spell camouflage
    Spell stoneVision
    Spell rockToss
    Spell stonyPath
    Spell powderisingStrength
    Spell stoneForm
    Spell evilAlteration
    Spell rebuild
endglobals

module GargoyleSpells
    set deadlyRepulse = Spell.create('A6XX')
    set deadlyRepulse.info = "Deadly Repulse"
    
    set crack = Spell.create('A611')
    set crack.info = "Crack|n|cfff4a460Target|r: |cff3399ffArea of Effect (300)|n|r|cfff4a460Range|r: |cff3399ff800|n|r|cfff4a460Duration|r: |cff3399ff(0.2 second x ability level)|n|r|cfff4a460Cooldown|r: |cff3399ff20 seconds|r|n|nGargoyle cracks the ground and temporarily stuns all nearby opponents."
    
    set earthShatter = Spell.create('A612')
    set earthShatter.info = "Earth Shatter"
    
    set stoneGaze = Spell.create('A613')
    set stoneGaze.info = "Stone Gaze|n|cfff4a460Target|r: |cff3399ffEnemy Unit|n|r|cfff4a460Range|r: |cff3399ff600|n|r|cfff4a460Damage|r: |cff3399ff(40 x ability level)|n|r|cfff4a460Duration|r: |cff3399ff(0.4 second x ability level)|n|r|cfff4a460Cooldown|r:|cff3399ff 15 seconds|r|n|nSends a wave of unknown energy to deal magic damage and temporarily turn a living unit into a stone disabling movement but increasing it's armor and rendering it immune to magic."
    
    set terror = Spell.create('A614')
    set terror.info = "Terror"
    
    set upliftPurpose = Spell.create('A621')
    set upliftPurpose.info = "Uplift Purpose|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Hitpoints Sacrificed|r: |cff3399ff(1% x ability level)|n|r|cfff4a460Duration|r: |cff3399ff10 seconds|n|r|cfff4a460Cooldown|r: |cff3399ff30 seconds|r|n|nGargoyle sacrifices some amount of his maximum life as a damage for his next attack. This ability can kill Gargoyle if used unwise."
    
    set fissure = Spell.create('A622')
    set fissure.info = "Fissure"
    
    set rockHard = Spell.create('A623')
    set rockHard.info = "Rock Hard"
    
    set camouflage = Spell.create('A624')
    set camouflage.info = "Camouflage"
    
    set stoneVision = Spell.create('A631')
    set stoneVision.info = "Stone Vision"
    
    set rockToss = Spell.create('A632')
    set rockToss.info = "Rock Toss"
    
    set stonyPath = Spell.create('A633')
    set stonyPath.info = "Stony Path"
    
    set powderisingStrength = Spell.create('A641')
    set powderisingStrength.passive = true
    set powderisingStrength.info = "Powderising Strength|n|cfff4a460Target|r: |cff3399ffPassive|n|r|cfff4a460Life restored|r: |cff3399ff(15% + (4% x ability level))|r|n|nGargoyle is able to regain his life from attacking structures."
    
    set stoneForm = Spell.create('A642')
    set stoneForm.info = "Stone Form"
    
    set evilAlteration = Spell.create('A643')
    set evilAlteration.info = "Evil Alteration"
    
    set rebuild = Spell.create('A644')
    set rebuild.info = "Rebuild"
endmodule

module GargoyleConfig
    set gargoyle = Hero.create('UGar')
    set gargoyle.faction = ANCIENT_EVILS
    set gargoyle.name = "Gargoyle"
    set gargoyle.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_Gargoyle.blp"
    set gargoyle.scaleAdd = -0.15
    set gargoyle.modelPath = "Models\\Units\\Gargoyle.mdx"
    set gargoyle.info = "GARGOYLES ARE DIRECTLY RELATED TO STONE. THIS GIVES THEM OPPORTUNITY TO MINIMIZE DAMAGE AND TURN EVEN STRONGEST DEFENCES |nINTO ASHES. GARGOYLE MAINLY EXCELS AT DESTROYING ENEMIES FORTIFICATIONS AND HARASSING ENEMIES FROM DISTANCE WHILE ALLIES |nARE FOCUSING ON LIVING PREY."
    set gargoyle.attribute = "19 +3.0    7 +4.3   12 +1.5"
    set gargoyle.primary = STR
    
    //Configure Spells
    set gargoyle.innateSpell = deadlyRepulse
    set gargoyle.spell11 = crack
    set gargoyle.spell12 = earthShatter
    set gargoyle.spell13 = stoneGaze
    set gargoyle.spell14 = terror
    set gargoyle.spell21 = upliftPurpose
    set gargoyle.spell22 = fissure
    set gargoyle.spell23 = rockHard
    set gargoyle.spell24 = camouflage
    set gargoyle.spell31 = stoneVision
    set gargoyle.spell32 = rockToss
    set gargoyle.spell33 = stonyPath
    set gargoyle.spell41 = powderisingStrength
    set gargoyle.spell42 = stoneForm
    set gargoyle.spell43 = evilAlteration
    set gargoyle.spell44 = rebuild
    call gargoyle.end()
endmodule

module GargoyleButton
    call HeroButton.create(gargoyle)
endmodule