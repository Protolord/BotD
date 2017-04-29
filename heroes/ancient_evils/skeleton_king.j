globals
    Hero skeletonKing
    //SkeletonKing Spells
    Spell bones
    Spell soulBreak
    Spell reaper
    Spell soulRip
    Spell unholyAura
    Spell ghostForm
    Spell otherSide
    Spell deathPact
    Spell fear
    Spell heartBeat
    Spell soulMark
    Spell loneSoul
    Spell regency
    Spell unholyEnergy
    Spell grimDeal
    Spell soulFeast
endglobals

module SkeletonKingSpells
    
    set bones = Spell.create('A7XX')
    set bones.passive = true
    set bones.info = "Bones|n|cfff4a460Target|r: |cff3399ffPassive, Self|n|r|cfff4a460Max Arrows|r: |cff3399ff25|n|r|cfff4a460Arrow Duration|r: |cff3399ff3 minutes|r|n|nArrow projectiles have 10% chance getting stuck on skeletal body to create temporary spiked carapace. Each arrow deals 10 damage to melee attackers."

    set soulBreak = Spell.create('A711')
    set soulBreak.info = "Soul Break|n|cfff4a460Target|r: |cff3399ffEnemy Unit|n|r|cfff4a460Range|r: |cff3399ff700|n|r|cfff4a460Damage/second|r: |cff3399ff20|n|r|cfff4a460Stun|r: |cff3399ff0.3 second |n|r|cfff4a460Duration|r: |cff3399ff(1 second x level)|n|r|cfff4a460Cooldown|r: |cff3399ff15 seconds|r|n|nSkeleton King sends a wave of unholy energy that breaks enemy soul dealing periodic damage and stun every second."

    set reaper = Spell.create('A712')
    set reaper.passive = true
    set reaper.info = "Reaper|n|cfff4a460Target|r: |cff3399ffPassive, Self|n|r|cfff4a460Bonus Damage|r: |cff3399ff10|r|n|cfff4a460Duration|r: |cff3399ff10 + (2 x level) seconds|r|n|nEach attack on living creature provides Skeleton King bonus damage for a certain period of time. Can provide up to 500 bonus damage."

    set soulRip = Spell.create('A713')
    set soulRip.info = "Soul Rip|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Radius|r: |cff3399ff(100 x level)|n|r|cfff4a460HP Stolen|r: |cff3399ff(100 + 50 x level)|n|r|cfff4a460Cooldown|r: |cff3399ff25 seconds|r|n|nSkeleton King rips souls of all nearby enemies slowly gathering their life force."

    set unholyAura = Spell.create('A714')
    set unholyAura.passive = true
    set unholyAura.info = "Unholy Aura|n|cfff4a460Target|r: |cff3399ffPassive, Enemy|n|r|cfff4a460Radius|r: |cff3399ff1250|n|r|cfff4a460Min Damage|r: |cff3399ff(0.1% x level)|n|r|cfff4a460Max Damage|r: |cff3399ff(0.5% x level)|n|r|nEnemies close to Skeleton King feel their life force being ripped losing a percentage of their max health per second based on how close they are to Skeleton King. Deals maximum damage to all enemies within 250 radius."

    set ghostForm = Spell.create('A721')
    set ghostForm.info = "Ghost Form|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460HP Stolen|r: |cff3399ff(30 x level)|n|r|cfff4a460Duration|r: |cff3399ff15 seconds|n|r|cfff4a460Cooldown|r: |cff3399ff30 seconds|r|n|nSkeleton King becomes invisible and on attack breaking invisibility will steal a portion of enemy hitpoints."
    
    set otherSide = Spell.create('A722')
    set otherSide.passive = true
    set otherSide.info = "Other Side|n|cfff4a460Target|r: |cff3399ffPassive, Self|n|r|cfff4a460Max Bonus|r: |cff3399ff(10% x level)|r|n|nSkeleton King becomes more powerful as his life fades. He receive bonus percentage damage based on the percentage of hitpoints missing."
    
    set deathPact = Spell.create('A723')
    set deathPact.passive = true
    set deathPact.info = "Death Pact|n|cfff4a460Target|r: |cff3399ffPassive, Enemy|n|r|cfff4a460Threshold|r: |cff3399ff(2% x level)|n|r|nSkeleton King can instantly kill any living creature whose hitpoints percentage is below a certain threshold."

    set fear = Spell.create('A724')
    set fear.passive = true
    set fear.info = "Fear|n|cfff4a460Target|r: |cff3399ffPassive, Self|n|r|cfff4a460Damage Penalty|r: |cff3399ff(3% x level)|n|r|cfff4a460Range|r: |cff3399ff500|r|n|nEnemies looking directly at Skeleton King get cursed losing certain portion of their attack damage."

    set heartBeat = Spell.create('A731')
    set heartBeat.passive = true
    set heartBeat.info = "Heartbeat|n|cfff4a460Target|r: |cff3399ffPassive, Self|n|r|cfff4a460Range|r: |cff3399ff(250 x level)|n|r|nSkeleton King can with ease detect nearby alive units. Also reveals invisible units."

    set soulMark = Spell.create('A732')
    set soulMark.info = "Soul Mark|n|cfff4a460Target|r: |cff3399ffEnemy Unit|n|r|cfff4a460Range|r: |cff3399ff250|n|r|cfff4a460Duration|r: |cff3399ff5 minutes|n|r|cfff4a460Cooldown|r: |cff3399ff(330 - 20 x level) seconds|r|n|nSkeleton King unleashes unholy marking on enemy unit and revealing it for 5 minutes. Also reveals invisible units."

    set loneSoul = Spell.create('A733')
    set loneSoul.info = "Lone Soul|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Sight Radius|r: |cff3399ff(100 x level)|n|r|cfff4a460Cooldown|r: |cff3399ff150 seconds|r|n|nSkeleton King releases a lone soul, a permanent, uncontrollable, unattackable scout that continuously explores the map. Also reveals invisible units."
    
    set regency = Spell.create('A741')
    set regency.passive = true
    set regency.info = "Regency|n|cfff4a460Target|r: |cff3399ffPassive, Self|n|r|cfff4a460Max Charges|r: |cff3399ff200|r|n|cfff4a460Charge Duration|r: |cff3399ff(10 x level) seconds|r|n|nEvery time Skeleton King takes damage he gathers charges that will increase any future healing or regeneration he will receive by 1% for a set period of time."

    set unholyEnergy = Spell.create('A742')
    set unholyEnergy.passive = true
    set unholyEnergy.info = "Unholy Energy|n|cfff4a460Target|r: |cff3399ffPassive, Self|n|r|cfff4a460Range|r: |cff3399ff(250 + 50 x ability level)|n|r|cfff4a460Bonus Regeneration|r: |cff3399ff50 per unit|r|n|nSkeleton King receives additional +50 hitpoints regeneration for each living creature nearby. Heals 4x on ethereal units."

    set grimDeal = Spell.create('A743')
    set grimDeal.passive = true
    set grimDeal.info = "Grim Deal|n|cfff4a460Target|r: |cff3399ffPassive, Self|n|r|cfff4a460Chance|r: |cff3399ff(11 + 2 x level) %|r|n|nKilling blow has a set chance to instead fully heal Skeleton King."

    set soulFeast = Spell.create('A744')
    set soulFeast.passive = true
    set soulFeast.info = "Soul Feast|n|cfff4a460Target|r: |cff3399ffPassive, Self|n|r|cfff4a460Healing|r: |cff3399ff(5 + 1 x level) %|r|n|nEvery kill releases healing energy that heals Skeleton King for a set max hitpoints percentage. Heals 4x on ethereal units."

endmodule

module SkeletonKingConfig
    set skeletonKing = Hero.create('USke')
    set skeletonKing.faction = ANCIENT_EVILS
    set skeletonKing.name = "Skeleton King"
    set skeletonKing.scaleAdd = -0.10
    set skeletonKing.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_SkeletonKing.blp"
    set skeletonKing.modelPath = "Models\\Units\\SkeletonKing.mdx"
    set skeletonKing.info = "<NOTHING YET>"
    set skeletonKing.attribute = "19 +3.6    7 +3.2   12 +1.4"
    set skeletonKing.primary = STR
    
    //Configure Spells
    set skeletonKing.innateSpell = bones
    set skeletonKing.spell11 = soulBreak
    set skeletonKing.spell12 = reaper
    set skeletonKing.spell13 = soulRip
    set skeletonKing.spell14 = unholyAura
    set skeletonKing.spell21 = ghostForm
    set skeletonKing.spell22 = otherSide
    set skeletonKing.spell23 = deathPact
    set skeletonKing.spell24 = fear
    set skeletonKing.spell31 = heartBeat
    set skeletonKing.spell32 = soulMark
    set skeletonKing.spell33 = loneSoul
    set skeletonKing.spell41 = regency
    set skeletonKing.spell42 = unholyEnergy
    set skeletonKing.spell43 = grimDeal
    set skeletonKing.spell44 = soulFeast
    call skeletonKing.end()
endmodule

module SkeletonKingButton
    call HeroButton.create(skeletonKing)
endmodule