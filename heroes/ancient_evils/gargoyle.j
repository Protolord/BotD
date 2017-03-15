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
    Spell evilAlternation
    Spell rebuild
endglobals

module GargoyleSpells
    set deadlyRepulse = Spell.create('A6XX')
    set deadlyRepulse.info = "Deadly Repulse|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Attack Range|r: |cff3399ff400|n|r|cfff4a460Cooldown|r: |cff3399ff60 seconds|r|n|nGargoyle summons permanently invisible ward on his location. Ward can strike both units and structures dealing 160 hero damage."
    
    set crack = Spell.create('A611')
    set crack.info = "Crack|n|cfff4a460Target|r: |cff3399ffArea of Effect (300)|n|r|cfff4a460Range|r: |cff3399ff800|n|r|cfff4a460Duration|r: |cff3399ff(0.2 second x level)|n|r|cfff4a460Cooldown|r: |cff3399ff20 seconds|r|n|nGargoyle cracks the ground and temporarily stuns all nearby opponents."
    
    set earthShatter = Spell.create('A612')
    set earthShatter.info = "Earth Shatter|n|cfff4a460Target|r: |cff3399ffSelf (400)|n|r|cfff4a460Damage|r: |cff3399ff(50 x level)|n|r|cfff4a460Duration|r: |cff3399ff(0.2 second x level)|n|r|cfff4a460Cooldown|r: |cff3399ff25 seconds|r|n|nGargoyle stomps the earth creating a devastating magical blast around him, damaging and slowing nearby enemy units by 50%."
    
    set stoneGaze = Spell.create('A613')
    set stoneGaze.info = "Stone Gaze|n|cfff4a460Target|r: |cff3399ffEnemy Unit|n|r|cfff4a460Range|r: |cff3399ff600|n|r|cfff4a460Damage|r: |cff3399ff(40 x level)|n|r|cfff4a460Duration|r: |cff3399ff(0.4 second x level)|n|r|cfff4a460Cooldown|r:|cff3399ff 15 seconds|r|n|nSends a wave of unknown energy to deal magic damage and temporarily turn a living unit into a stone disabling movement but increasing it's armor and rendering it immune to magic."
    
    set terror = Spell.create('A614')
    set terror.info = "Terror|n|cfff4a460Target|r: |cff3399ffSelf (400)|n|r|cfff4a460Damage|r: |cff3399ff(35 x level)|n|r|cfff4a460Cooldown|r: |cff3399ff15 seconds|r|n|nGargoyle creates a horrifying scream which damages nearby enemy units and makes them to run away 250 range away."
    
    set upliftPurpose = Spell.create('A621')
    set upliftPurpose.info = "Uplift Purpose|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Hitpoints Sacrificed|r: |cff3399ff(1% x level)|n|r|cfff4a460Duration|r: |cff3399ff10 seconds|n|r|cfff4a460Cooldown|r: |cff3399ff30 seconds|r|n|nGargoyle sacrifices some amount of his maximum life as a damage for his next attack. This can kill Gargoyle if used unwise."
    
    set fissure = Spell.create('A622')
    set fissure.info = "Fissure|n|cfff4a460Target|r: |cff3399ffPoint|n|r|cfff4a460Damage|r: |cff3399ff(40 x level)|n|r|cfff4a460Range|r: |cff3399ff800|n|r|cfff4a460Cooldown|r: |cff3399ff30 seconds|r|n|nGargoyle slams the ground and sends a fissure which deals damage to all opponents in it's path."
    
    set rockHard = Spell.create('A623')
    set rockHard.passive = true
    set rockHard.info = "Rock Hard|n|cfff4a460Target|r: |cff3399ffPassive|n|r|cfff4a460Reduction|r: |cff3399ff(1 damage + (0.5 x level))|r|n|nGargoyle rock hard skin can reduce damage from incoming ranged attacks."
    
    set camouflage = Spell.create('A624')
    set camouflage.info = "Camouflage|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Stun Duration|r: |cff3399ff(0.3 second x level)|n|r|cfff4a460Duration|r: |cff3399ff10 seconds|n|r|cfff4a460Cooldown|r: |cff3399ff20 seconds|r|n|nGargoyle becomes temporarily invisible, moves 10% slower and will temporarily stun it's first target."
    
    set stoneVision = Spell.create('A631')
    set stoneVision.info = "Stone Vision|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Duration|r: |cff3399ff15 seconds|n|r|cfff4a460Cooldown|r: |cff3399ff30 seconds|r|n|nGargoyle gains a vision of a nearby structures. Does not reveal invisible units."
    
    set rockToss = Spell.create('A632')
    set rockToss.info = "Rock Toss|n|cfff4a460Target|r: |cff3399ffPoint|n|r|cfff4a460Sight Radius|r: |cff3399ff(500 x level)|n|r|cfff4a460Sight Duration|r: |cff3399ff15 seconds|n|r|cfff4a460Cooldown|r: |cff3399ff30 seconds|r|n|nGargoyle tosses a massive rock which on impact with the ground will temporarily stun opponents in a range of 500 for 1 second. Also reveals invisible units."
    
    set stonyPath = Spell.create('A633')
    set stonyPath.info = "Stony Path|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Line of sight|r: |cff3399ff(100 x level)|n|r|cfff4a460Cooldown|r: |cff3399ff60 seconds|r|n|nGargoyle marks his current location with a stones making this place permanently explored. Also reveals invisible units."
    
    set powderisingStrength = Spell.create('A641')
    set powderisingStrength.passive = true
    set powderisingStrength.info = "Powderising Strength|n|cfff4a460Target|r: |cff3399ffPassive|n|r|cfff4a460Life restored|r: |cff3399ff(15% + (4% x level))|r|n|nGargoyle is able to regain his life from attacking structures."
    
    set stoneForm = Spell.create('A642')
    set stoneForm.info = "Stone Form|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Healing|r: |cff3399ff(100 per second x level)|n|r|cfff4a460Cooldown|r: |cff3399ff60 seconds|r|n|nGargoyle turns into his stone form and gaining a massive regeneration. It takes 3 seconds to turn into stone form. Gargoyle is immobile and loses his ability to attack during stone form. Stone Form is interruptible. Heals 4x more hitpoints on ethereal Gargoyle."
    
    set evilAlternation = Spell.create('A643')
    set evilAlternation.info = "Evil Alternation|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Damage healed|r: |cff3399ff(75% of damage taken + (5% x level))|r|n|nGargoyle activates spiritual shield which gains damage Gargoyle is taking and upon deactivation restores some of it's power to heal Gargoyle. Drains 25 mana per second."
    
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
    set gargoyle.attribute = "19 +3.0    7 +4.5   12 +1.4"
    set gargoyle.primary = AGI
    
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
    set gargoyle.spell43 = evilAlternation
    set gargoyle.spell44 = rebuild
    call gargoyle.end()
endmodule

module GargoyleButton
    call HeroButton.create(gargoyle)
endmodule