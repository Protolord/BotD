globals
    Hero vampireLord
    //Vampire Lord Spells
    Spell reincarnation
    Spell immortalForce
    Spell corruptingStomp
    Spell soulCorruption
    Spell deathCoil
    Spell shadowrun
    Spell spiritualWalk
    Spell shadowsOfCorruption
    Spell unrestrainedDistress
    Spell eyeOfDarkness
    Spell viciousExplorers
    Spell spectralTrack
    Spell veinsOfBlood
    Spell bloodlines
    Spell bloodExtremity
    Spell unstoppableHunger
endglobals

module VampireLordSpells

    set reincarnation = Spell.create('A1XX')
    set reincarnation.passive = true
    set reincarnation.info = "Reincarnation|n|cfff4a460Target|r: |cff3399ffPassive, Self|n|r|cfff4a460Cooldown|r: |cff3399ff6 minutes|n|r|nVampire can regain his life. When killed will come back to life with full life and same mana amount he died with."
    
    set immortalForce = Spell.create('A111')
    set immortalForce.info = "Immortal Force|n|cfff4a460Target|r: |cff3399ffEnemy Unit|n|r|cfff4a460Range|r: |cff3399ff150|n|r|cfff4a460Duration|r: |cff3399ff(0.5 x level) seconds|n|r|cfff4a460Cooldown|r: |cff3399ff15 seconds|r|n|nSends a wave of evil energy to temporarily stun enemy unit."
    
    set corruptingStomp = Spell.create('A112')
    set corruptingStomp.info = "Corrupting Stomp|n|cfff4a460Target|r: |cff3399ffSelf (250)|n|r|cfff4a460Duration|r:|cff3399ff (0.35 x level) seconds|n|r|cfff4a460Damage|r:|cff3399ff (20 x level)|n|r|cfff4a460Cooldown|r: |cff3399ff15 seconds|r|n|nStomps the ground to deal magic damage and temporarily stun enemies."
    
    set soulCorruption = Spell.create('A113')
    set soulCorruption.info = "Soul Corruption|n|cfff4a460Target|r: |cff3399ffEnemy Unit|n|r|cfff4a460Range|r: |cff3399ff600|n|r|cfff4a460Duration|r: |cff3399ff(0.25 x level) seconds|n|r|cfff4a460Damage|r: |cff3399ff(35 x level)|n|r|cfff4a460Cooldown|r: |cff3399ff15 seconds|r|n|nSends a wave of dark energy to corrupt enemy soul dealing magic damage and stunning it for a short period of time."
    
    set deathCoil = Spell.create('A114')
    set deathCoil.info = "Death Coil|n|cfff4a460Target|r: |cff3399ffEnemy Unit|n|r|cfff4a460Range|r: |cff3399ff800|n|r|cfff4a460Damage|r: |cff3399ff(50 x level)|n|r|cfff4a460Cooldown|r: |cff3399ff15 seconds|r|n|nSends a wave of dark energy to corrupt enemy soul and deal magic damage."
    
    set shadowrun = Spell.create('A121')
    set shadowrun.info = "Shadowrun|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Duration|r: |cff3399ff(5 x level) seconds|n|r|cfff4a460Effect|r: |cff3399ff(+5% MS x level)|n|r|cfff4a460Cooldown|r: |cff3399ff(5 x level) + 5) seconds|r|n|nAllows Vampire to become invisible and move faster."
    
    set spiritualWalk = Spell.create('A122')
    set spiritualWalk.info = "Spiritual Walk|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Duration|r: |cff3399ff(5 x level) seconds|n|r|cfff4a460Movement Speed|r: |cff3399ff(2% x level)|n|r|cfff4a460Mana Stolen|r: |cff3399ff15% + (2% x level)|n|r|cfff4a460Cooldown|r: |cff3399ff(2.5 x level) seconds|r|n|nAllows Vampire to become invisible and on first attack breaking invisibility to steal a percentrage of target's mana."
    
    set shadowsOfCorruption = Spell.create('A123')
    set shadowsOfCorruption.info = "Shadows Of Corruption|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Duration|r: |cff3399ff(5 x level) seconds|n|r|cfff4a460Movement Speed|r: |cff3399ff(2% x level)|n|r|cfff4a460Slow Duration|r: |cff3399ff5 + (0.5 x level) seconds|n|r|cfff4a460Cooldown|r: |cff3399ff(2.5 x level) seconds|r|n|nAllows Vampire to become invisible, move faster and on first attack temporarily slow enemy unit by 50%"
    
    set unrestrainedDistress = Spell.create('A124')
    set unrestrainedDistress.info = "Unrestrained Distress|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Duration|r: |cff3399ff(5 x level) seconds|n|r|cfff4a460Movement Speed|r: |cff3399ff(2% x level)|n|r|cfff4a460Sleep Duration|r: |cff3399ff5 + (1 x level) seconds|n|r|cfff4a460Cooldown|r: |cff3399ff(2.5 x level) seconds|r|n|nAllows Vampire to become invisible and on first attack breaking invisibility to put an enemy unit to sleep dealing 75 dps."
    
    set eyeOfDarkness = Spell.create('A131')
    set eyeOfDarkness.info = "Eye Of Darkness|n|cfff4a460Target|r: |cff3399ffPoint (250 x level)|n|r|cfff4a460Duration|r: |cff3399ff9 seconds|n|r|cfff4a460Cooldown|r: |cff3399ff20 seconds|r|n|nProvides a temporary vision over an area of effect which also reveals invisible units."
    
    set viciousExplorers = Spell.create('A132')
    set viciousExplorers.info = "Vicious Explorers|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Sight|r: |cff3399ff(100 x level)|n|r|cfff4a460Bats Summoned|r: |cff3399ff(1 x level)|n|r|cfff4a460Duration|r: |cff3399ff30 seconds|n|r|cfff4a460Cooldown|r: |cff3399ff20 seconds|r|n|nSummons a number of untargetable bats which will explore a random place on the map. Reveals invisible units."
    
    set spectralTrack = Spell.create('A133')
    set spectralTrack.info = "Spectral Track|n|cfff4a460Target|r: |cff3399ffSelf (250 x level)|n|r|cfff4a460Duration|r:|cff3399ff 20 seconds|n|r|cfff4a460Cooldown|r: |cff3399ff20 seconds|r|n|nProvides a temporary vision around yourself which also reveals invisible units."
    
    set veinsOfBlood = Spell.create('A141')
    set veinsOfBlood.info = "Veins Of Blood|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Duration|r: |cff3399ff(1 x level) seconds|n|r|cfff4a460Amount Healed|r: |cff3399ff600 per second|n|r|cfff4a460Cooldown|r: |cff3399ff30 seconds|r|n|nCalls a wave of dark energy which heals you for a set amount of time. Heals 4x more hitpoints on ethereal units."
    
    set bloodlines = Spell.create('A142')
    set bloodlines.info = "Bloodlines|n|cfff4a460Target|r: |cff3399ffSelf (800)|n|r|cfff4a460Amount Healed|r: |cff3399ff(500 x level)|n|r|cfff4a460Cooldown|r: |cff3399ff30 seconds|r|n|nCalls a wave of dark energy which heals nearby allies. Heals 4x more hitpoints on ethereal units."
    
    set bloodExtremity = Spell.create('A143')
    set bloodExtremity.info = "Blood Extremity|n|cfff4a460Target|r: |cff3399ffFriendly Unit|n|r|cfff4a460Range|r: |cff3399ff2500|n|r|cfff4a460Amount Healed|r: |cff3399ff(700 x level)|n|r|cfff4a460Cooldown|r: |cff3399ff30 seconds|r|n|nCalls a wave of dark energy which heals targeted ally. Heals 4x more hitpoints on ethereal units."
    
    set unstoppableHunger = Spell.create('A144')
    set unstoppableHunger.passive = true
    set unstoppableHunger.info = "Unstoppable Hunger|n|cfff4a460Target|r: |cff3399ffPassive, Self|n|r|cfff4a460Heal|r: |cff3399ff(2.5 x level) x Dmg taken |r|n|nPassive healing providing Vampire with 3% chance to heal himself any time takes physical damage."
endmodule

module VampireLordConfig
    set vampireLord = Hero.create('UVaL')
    set vampireLord.faction = ANCIENT_EVILS
    set vampireLord.name = "Vampire Lord"
    set vampireLord.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_VampireLord.blp"
    set vampireLord.scaleAdd = 0.15
    set vampireLord.modelPath = "Models\\Units\\VampireLord.mdx"
    set vampireLord.info = "VAMPIRE LORDS ARE THE MASTERS OF SHADOWS AND DEALING MASSIVE DAMAGE TO ENEMY DEFENCES WHEN IT IS ABSOLUTELY UNEXPECTED. |nWHILE ABLE TO RAPIDLY REGENERATE THEIR LIFEFORCE THEY BECOME ULTIMATE KILLING TOOL IN THE SCOURGE ARMY. CUNNING |nSLAUGHTER FOR LIVING AND FORTIFIED ENEMIES."
    set vampireLord.attribute = "19 +2.9    7 +4.6   12 +1.6"
    set vampireLord.primary = AGI
    //Configure Spells
    set vampireLord.innateSpell = reincarnation
    set vampireLord.spell11 = immortalForce
    set vampireLord.spell12 = corruptingStomp
    set vampireLord.spell13 = soulCorruption
    set vampireLord.spell14 = deathCoil
    set vampireLord.spell21 = shadowrun
    set vampireLord.spell22 = spiritualWalk
    set vampireLord.spell23 = shadowsOfCorruption
    set vampireLord.spell24 = unrestrainedDistress
    set vampireLord.spell31 = eyeOfDarkness
    set vampireLord.spell32 = viciousExplorers
    set vampireLord.spell33 = spectralTrack
    set vampireLord.spell41 = veinsOfBlood
    set vampireLord.spell42 = bloodlines
    set vampireLord.spell43 = bloodExtremity
    set vampireLord.spell44 = unstoppableHunger
    call vampireLord.end()
endmodule

module VampireLordButton
    call HeroButton.create(vampireLord)
endmodule