globals
    Hero demon
    //Demon Spells
    Spell vigilantAndVirtuous
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
    
    set vigilantAndVirtuous = Spell.create('A5XX')
    set vigilantAndVirtuous.passive = true
    set vigilantAndVirtuous.info = "Vigilant And Virtuous"
    
    set doom = Spell.create('A511')
    set doom.info = "Doom"
    
    set pitfall = Spell.create('A512')
    set pitfall.info = "Pitfall"
    
    set charge = Spell.create('A513')
    set charge.info = "Charge"
    
    set taunt = Spell.create('A514')
    set taunt.info = "Taunt"
    
    set rainOfFire = Spell.create('A521')
    set rainOfFire.info = "Rain Of Fire"
    
    set hellishCloud = Spell.create('A522')
    set hellishCloud.info = "Hellish Cloud"
    
    set infernalChains = Spell.create('A523')
    set infernalChains.info = "Infernal Chains"
    
    set underworldFires = Spell.create('A524')
    set underworldFires.info = "Underworld Fires"
    
    set diabolicSenses = Spell.create('A531')
    set diabolicSenses.info = "Diabolic Senses"
    
    set darkLordVision = Spell.create('A532')
    set darkLordVision.info = "Dark Lord Vision"
    
    set shatteredEarth = Spell.create('A533')
    set shatteredEarth.info = "Shattered Earth"
    
    set darkLordPowers = Spell.create('A541')
    set darkLordPowers.info = "Dark Lord Powers"
    
    set hellfireBlast = Spell.create('A542')
    set hellfireBlast.info = "Hellfire Blast"
    
    set hellguard = Spell.create('A543')
    set hellguard.info = "Hellguard"
    
    set engulfedFires = Spell.create('A544')
    set engulfedFires.info = "Engulfed Fires"
    
endmodule

module DemonConfig
    set demon = Hero.create('UDem')
    set demon.faction = ANCIENT_EVILS
    set demon.name = "Demon"
    set demon.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_Demon.blp"
    set demon.scaleAdd = 0.15
    set demon.modelPath = "Models\\Units\\Demon.mdx"
    set demon.info = "DEMONS COME STRAIGHT FROM THE HELLGATE. THEY ARE DIRECTLY RELATED TO FLAMES AND HELLISH CREATURES WHICH THEY COMMAND |nIN COMBAT. DEMON HIMSELF PROVES TO BE EXCELLENT AT RAZING SOLID DEFENCES AND DEVASTATING CLUSTERS OF ENEMIES. WITH HIS |nSTRENGTH BASE DEMONS ARE CAPABLE OF TAKING MASSIVE AMOUNT OF DAMAGE AND PROTECT WEAKER MEMBERS OF THE TEAM."
    set demon.attribute = "19 +3.0    7 +4.3   12 +1.5"
    set demon.primary = STR
    
    //Configure Spells
    set demon.innateSpell = vigilantAndVirtuous
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
    set demon.spell34 = Spell.BLANK
    set demon.spell41 = darkLordPowers
    set demon.spell42 = hellfireBlast
    set demon.spell43 = hellguard
    set demon.spell44 = engulfedFires
    call demon.end()
endmodule

module DemonButton
    call HeroButton.create(demon)
endmodule