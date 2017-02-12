globals
    Hero demon
    //Demon Spells
    Spell vigilantAndTheVirtuous
    Spell doom
    Spell pitfall
    Spell charge
    Spell taunt
    Spell rainOfFire
    Spell hellishCloud
    Spell infernalChains
    Spell underworldFires
    Spell diabolicSenses
    Spell darkLordVision
    Spell shatteredEarth
    Spell darkLordPowers
    Spell hellfireBlast
    Spell hellguard
    Spell engulfedFires
endglobals

module DemonSpells
    
    set vigilantAndTheVirtuous = Spell.create('A5XX')
    set vigilantAndTheVirtuous.passive = true
    set vigilantAndTheVirtuous.info = "Vigilant And The Virtuous|n|cfff4a460Target|r: |cff3399ffPassive, Enemy|n|r|cfff4a460Range|r: |cff3399ffMelee|r|n|cfff4a460Damage per second|r: |cff3399ff(3 x Hero Level)|r|n|cfff4a460Duration|r: |cff3399ff30 seconds|r|n|nEach attack will leave a mark on it's living target dealing non-lethal damage per second; targets will be left with at least 1 HP."
    
    set doom = Spell.create('A511')
    set doom.info = "Doom|n|cfff4a460Target|r: |cff3399ffEnemy Unit|n|r|cfff4a460Range|r: |cff3399ff600|n|r|cfff4a460Damage per second|r: |cff3399ff50|n|r|cfff4a460Duration|r: |cff3399ff(1 second x level)|n|r|cfff4a460Cooldown|r: |cff3399ff30 seconds|r|n|nMarks a target unit for the manifestation of a Demon. The afflicted unit cannot cast spells and takes magical damage over time."
    
    set pitfall = Spell.create('A512')
    set pitfall.info = "Pitfall|n|cfff4a460Target|r: |cff3399ffSelf (300)|n|r|cfff4a460Damage per second|r: |cff3399ff(30 x level)|n|r|cfff4a460Duration|r: |cff3399ff10 seconds|n|r|cfff4a460Cooldown|r: |cff3399ff20 seconds|r|n|nDemon creates a volcanic pit which deals damage and slows units in the pit."
    
    set charge = Spell.create('A513')
    set charge.info = "Charge|n|cfff4a460Target|r: |cff3399ffEnemy Unit|n|r|cfff4a460Range|r: |cff3399ff800|n|r|cfff4a460Duration|r: |cff3399ff(0.3 seconds x level)|n|r|cfff4a460Damage|r: |cff3399ff(50 x level)|n|r|cfff4a460Cooldown|r: |cff3399ff30 seconds|r|n|nCharges the target unit to deal massive damage and temporarily stun the target. Cannot pass through cliffs and obstacles."
    
    set taunt = Spell.create('A514')
    set taunt.info = "Taunt|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Radius|r: |cff3399ff(100 x level)|n|r|cfff4a460Damage|r: |cff3399ff(35 x level)|n|r|cfff4a460Cooldown|r: |cff3399ff30 seconds|r|n|nDemon howls a scream making at most 20 nearby enemies to attack him. Also deals magical damage in area around him."
    
    set rainOfFire = Spell.create('A521')
    set rainOfFire.info = "Rain Of Fire|n|cfff4a460Target|r: |cff3399ffAoe(300)|n|r|cfff4a460Range|r: |cff3399ff600|n|r|cfff4a460Damage/wave|r: |cff3399ff20 x level|r|n|nDemon summons a Rain of Fire with a maximum of 5 waves at a rate of 1 wave/second. Does not damage buildings and damages allies."
    
    set hellishCloud = Spell.create('A522')
    set hellishCloud.info = "Hellish Cloud|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Damage|r: |cff3399ff(50 x level)|n|r|cfff4a460Duration|r: |cff3399ff(5 + (1 x level)) seconds|n|r|cfff4a460Cooldown|r: |cff3399ff(10 + (1 x level)) seconds|r|n|nDemon becomes temporarily invisible and deals extra area (400) damage on impact."
    
    set infernalChains = Spell.create('A523')
    set infernalChains.passive = true
    set infernalChains.info = "Infernal Chains|n|cfff4a460Target|r: |cff3399ffPassive, Structure|n|r|cfff4a460Chain Length|r:|cff3399ff (1 x level)|n|r|cfff4a460Chance to proc|r:|cff3399ff 1%|n|n|rProvides Demon with a chance to devastate enemy structures dealing 10% of target's Max HP as damage. Further successful procs on the same target deals additional 10% damage up to 100%."
    
    set underworldFires = Spell.create('A524')
    set underworldFires.info = "Underworld Fires|n|cfff4a460Target|r: |cff3399ffSelf (160)|n|r|cfff4a460Damage|r: |cff3399ff(30 x level)|n|r|cfff4a460Mana cost|r: |cff3399ff20 + (4 x level)|r|n|nDemon engulfs with Underworld Fires to deal damage to nearby enemies. Also damages structures."
    
    set diabolicSenses = Spell.create('A531')
    set diabolicSenses.info = "Diabolic Senses|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Number of senses|r: |cff3399ff1 x level|n|r|cfff4a460Cooldown|r: |cff3399ff30 seconds|r|n|nDemon releases his Diabolic Senses which are aiming any living unit nearby dealing 50 damage. Also provide 1000 exploration range and reveal invisible units. Lasts 15 seconds."
    
    set darkLordVision = Spell.create('A532')
    set darkLordVision.info = "Dark Lord Vision|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Reveal threshold|r: |cff3399ff50% + (5% x level)|n|r|cfff4a460Duration|r: |cff3399ff30 seconds|r|n|cfff4a460Cooldown|r: |cff3399ff30 seconds|r|n|nDemon gains a vision of any units that are not healthy."
    
    set shatteredEarth = Spell.create('A533')
    set shatteredEarth.info = "Shattered Earth|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Explosions|r: |cff3399ff1 x level|n|r|cfff4a460Sight|r: |cff3399ff1500 x level|n|r|cfff4a460Duration|r: |cff3399ff30 seconds|n|r|cfff4a460Cooldown|r: |cff3399ff30 seconds|r|n|nDemon slams the ground and makes the earth to split open and create random explosions around the map. Each explosion provide vision and reveals invisible units."
    
    set darkLordPowers = Spell.create('A541')
    set darkLordPowers.info = "Dark Lord Powers|n|cfff4a460Target|r: |cff3399ffSelf (500)|n|r|cfff4a460Healing|r: |cff3399ff450 x level|n|r|cfff4a460Cooldown|r: |cff3399ff30 seconds|r|n|nDemon creates a Fire Nova which heals any nearby allies in a range of 500. Heals 4x more hitpoints on ethereal units."
    
    set hellfireBlast = Spell.create('A542')
    set hellfireBlast.info = "Hellfire Blast|n|cfff4a460Target|r: |cff3399ffSelf (300)|n|r|cfff4a460Heal/explosion|r: |cff3399ff40 x level|n|r|cfff4a460Cooldown|r: |cff3399ff30 seconds|r|n|nDemon uses his demonic powers to create a Hellfire Blast each second. Each of them heals Demon and his nearby allies and damage enemies for the same amount. Lasts 10 seconds. Ethereal units are damaged or healed 4x stronger."
    
    set hellguard = Spell.create('A543')
    set hellguard.info = "Hellguard|n|cfff4a460Target|r: |cff3399ffSelf (100)|n|r|cfff4a460Heal per second|r: |cff3399ff(100 x level)|n|r|cfff4a460Stacking Bonus Heal|r: |cff3399ff10%|n|r|cfff4a460Duration|r: |cff3399ff10 seconds|n|r|cfff4a460Cooldown|r: |cff3399ff30 seconds|r|n|nDemon summons imps which heal a small area around caster. Will grant stacking bonus healing the longer Demon or his ally stay in the area. Heals 4x more hitpoints on ethereal units."
    
    set engulfedFires = Spell.create('A544')
    set engulfedFires.info = "Engulfed Fires|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Duration|r: |cff3399ff5 + (0.5 x level) seconds|n|r|cfff4a460Cooldown|r: |cff3399ff30 seconds|r|n|nDemon engulfs in magical flames which are making him completely immune to any loses or gains of life. Also blocks arenas damage."
    
endmodule

module DemonConfig
    set demon = Hero.create('UDem')
    set demon.faction = ANCIENT_EVILS
    set demon.name = "Demon"
    set demon.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_Demon.blp"
    set demon.scaleAdd = 0.15
    set demon.modelPath = "Models\\Units\\Demon.mdx"
    set demon.info = "DEMONS COME STRAIGHT FROM THE HELLGATE. THEY ARE DIRECTLY RELATED TO FLAMES AND HELLISH CREATURES WHICH THEY COMMAND |nIN COMBAT. DEMON HIMSELF PROVES TO BE EXCELLENT AT RAZING SOLID DEFENCES AND DEVASTATING CLUSTERS OF ENEMIES. WITH HIS |nSTRENGTH BASE DEMONS ARE CAPABLE OF TAKING MASSIVE AMOUNT OF DAMAGE AND PROTECT WEAKER MEMBERS OF THE TEAM."
    set demon.attribute = "19 +3.9    7 +3.1   12 +1.3"
    set demon.primary = STR
    
    //Configure Spells
    set demon.innateSpell = vigilantAndTheVirtuous
    set demon.spell11 = doom
    set demon.spell12 = pitfall
    set demon.spell13 = charge
    set demon.spell14 = taunt
    set demon.spell21 = rainOfFire
    set demon.spell22 = hellishCloud
    set demon.spell23 = infernalChains
    set demon.spell24 = underworldFires
    set demon.spell31 = diabolicSenses
    set demon.spell32 = darkLordVision
    set demon.spell33 = shatteredEarth
    set demon.spell41 = darkLordPowers
    set demon.spell42 = hellfireBlast
    set demon.spell43 = hellguard
    set demon.spell44 = engulfedFires
    call demon.end()
endmodule

module DemonButton
    call HeroButton.create(demon)
endmodule