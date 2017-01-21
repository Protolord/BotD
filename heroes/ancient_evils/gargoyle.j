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
    set crack.info = "Crack"
    
    set earthShatter = Spell.create('A612')
    set earthShatter.info = "Earth Shatter"
    
    set stoneGaze = Spell.create('A613')
    set stoneGaze.info = "Stone Gaze"
    
    set terror = Spell.create('A614')
    set terror.info = "Terror"
    
    set upliftPurpose = Spell.create('A621')
    set upliftPurpose.info = "Uplift Purpose"
    
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
    set powderisingStrength.info = "Powderising Strength"
    
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