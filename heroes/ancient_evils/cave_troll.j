globals
    Hero caveTroll
    //CaveTroll Spells
    Spell cleave
    Spell heavySwing
    Spell threeSixty
    Spell secondHit
    Spell studdedClub
    Spell testudo
    Spell strongBack
    Spell innerResistance
    Spell bloodlust
    Spell smell
    Spell eyeRay
    Spell cauldron
    Spell totem
    Spell devour
    Spell rage
    Spell auraOfStrength
endglobals

module CaveTrollSpells
    set cleave = Spell.create('A8XX')
    set cleave.passive = true
    set cleave.info = "Cleave|n|cfff4a460Target|r: |cff3399ffPassive, Self|n|r|cfff4a460Min Cleave Damage|r: |cff3399ff20%|n|r|cfff4a460Max Cleave Damage|r: |cff3399ff50%|n|r|cfff4a460Range|r: |cff3399ff200|r|n|nCave Troll attacks with such force, cleaving nearby enemy units in each attack based on their distance."

    set heavySwing = Spell.create('A811')
    set heavySwing.autocast = true
    set heavySwing.info = "Heavy Swing|n|cfff4a460Target|r: |cff3399ffEnemy Unit|n|r|cfff4a460Range|r: |cff3399ffMelee|n|r|cfff4a460Damage Dealt|r: |cff3399ff150%|n|r|cfff4a460Stun Duration|r: |cff3399ff(0.2 x level) seconds|r|n|nCave Troll attacks with all his strength to deliver excruciating blow dealing extra damage and temporarily stunning the target."

    set threeSixty = Spell.create('A812')
    set threeSixty.info = "Three Sixty|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Radius|r: |cff3399ff350|n|r|cfff4a460Damage|r: |cff3399ff(100 x level)|n|r|cfff4a460Cooldown|r: |cff3399ff10 seconds|r|n|nCave Troll swings around damaging all nearby opponents."

    set secondHit = Spell.create('A813')
    set secondHit.passive = true
    set secondHit.info = "Second Hit|n|cfff4a460Target|r: |cff3399ffPassive, Enemy|n|r|cfff4a460Chance|r: |cff3399ff15%|n|r|cfff4a460Damage|r: |cff3399ff(5% x level)|n|r|nWhen attacking, Cave Troll has a chance to attack in another quick succession dealing percentage of his normal attack."

    set studdedClub = Spell.create('A814')
    set studdedClub.passive = true
    set studdedClub.info = "Studded Club|n|cfff4a460Target|r: |cff3399ffPassive, Enemy Units|n|r|cfff4a460Damage/second|r: |cff3399ff15|n|r|cfff4a460Duration|r: |cff3399ff(10 + 2 x level) seconds|n|r|nCave Troll attacks with a studded club that causes additional bleeding to his opponents dealing damage per second for a set period of time."

    set testudo = Spell.create('A821')
    set testudo.info = "Testudo|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Armor Bonus|r: |cff3399ff(30 x level)|n|r|cfff4a460Effect|r: |cff3399ff+50% Spell Resistance|n|r|cfff4a460Delay|r: |cff3399ff1 second|n|r|cfff4a460Cooldown|r: |cff3399ff1 second|r|n|nCave Troll takes cover to gain huge armor bonus and magic resistance. During Testudo Cave Troll loses ability to move and attack."

    set strongBack = Spell.create('A822')
    set strongBack.passive = true
    set strongBack.info = "Strong Back|n|cfff4a460Target|r: |cff3399ffPassive, Self|n|r|cfff4a460Damage Reduction|r: |cff3399ff(3% x level)|n|r|nCave Troll thick skin on the back serves as a great defence mechanism greatly reducing damage taken on his back."

    set innerResistance = Spell.create('A823')
    set innerResistance.passive = true
    set innerResistance.info = "Inner Resistance|n|cfff4a460Target|r: |cff3399ffPassive, Self|n|r|cfff4a460Duration Reduction|r: |cff3399ff(5% x level)|n|r|nCave Troll strong metabolism also helps reduce the duration of negative buffs by certain percentage."

    set bloodlust = Spell.create('A824')
    set bloodlust.passive = true
    set bloodlust.info = "Bloodlust|n|cfff4a460Target|r: |cff3399ffPassive, Self|n|r|cfff4a460Speed Bonus/Hit|r: |cff3399ff(0.5% x level)|n|r|cfff4a460Duration|r: |cff3399ff10 seconds|n|r|nCave Troll rage reaches critical levels and continuously increasing his speed on each attack. Attacking structures only gives 10% of this bonus."

    set smell = Spell.create('A831')
    set smell.passive = true
    set smell.info = "Smell|n|cfff4a460Target|r: |cff3399ffPassive, Enemy Units|n|r|cfff4a460Duration|r: |cff3399ff(3 x level) seconds|n|r|nCave Troll can smell units he recently hit for a set period of time. Also reveals invisible units."

    set eyeRay = Spell.create('A832')
    set eyeRay.passive = true
    set eyeRay.info = "Eye Ray|n|cfff4a460Target|r: |cff3399ffPassive|n|r|cfff4a460Range|r: |cff3399ff1800 + (100 x level)|n|r|nCave Troll gains line of sight vision in front of him that can see through obstacles."

    set cauldron = Spell.create('A833')
    set cauldron.info = "Cauldron|n|cfff4a460Target|r: |cff3399ffPoint|n|r|cfff4a460Radius|r: |cff3399ff1000|n|r|cfff4a460Debuff Duration|r: |cff3399ff(3 x level) seconds|r|n|cfff4a460Duration|r: |cff3399ff(240 + 10 x level) seconds|r|n|cfff4a460Cooldown|r: |cff3399ff60 seconds|r|n|nCave Troll places smelly cauldron. Any units walking in the range of cauldron will carry it's smell and will be revealed for certain period of time. Also reveals invisible units."

    set totem = Spell.create('A841')
    set totem.info = "Totem|n|cfff4a460Target|r: |cff3399ffPoint|n|r|cfff4a460Range|r: |cff3399ff2500|n|r|cfff4a460Heal/Second|r: |cff3399ff(100 + 10 x level)|n|r|cfff4a460Attacks To Destroy|r: |cff3399ff(10 + 1 x level)|r|n|cfff4a460Duration|r: |cff3399ff60 seconds|r|n|cfff4a460Cooldown|r: |cff3399ff60 seconds|r|n|nCave Troll plants a Totem that will provide additional healing for himself and his allies. For every 250 range away from Totem 10% healing strength is lost. Heals 4x on ethereal units."

    set devour = Spell.create('A842')
    set devour.info = "Devour|n|cfff4a460Target|r: |cff3399ffEnemy Unit|n|r|cfff4a460Range|r: |cff3399ffMelee|n|r|cfff4a460Health/Second|r: |cff3399ff10% Target Max HP|n|r|cfff4a460Duration|r: |cff3399ff(1 x ability level) seconds|n|r|cfff4a460Cooldown|r: |cff3399ff20 seconds|r|n|nCave Troll eats enemy alive stealing 10% its maximum health per second for a certain duration. During feast Cave Troll is unmoved by Area Damage. Devour stops when Cave Troll or the target is ethereal."

    set rage = Spell.create('A843')
    set rage.passive = true
    set rage.info = "Rage|n|cfff4a460Target|r: |cff3399ffPassive, Enemy|n|r|cfff4a460Heal|r: |cff3399ff(1.5% Max HP x level)|n|r|nWhenever Cave Troll lands a hit he has a 5% chance to heal himself. Hitting structures only has 1% chance to heal. Heals 4x on ethereal units."

    set auraOfStrength = Spell.create('A844')
    set auraOfStrength.info = "Aura Of Strength|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Radius|r: |cff3399ff600|n|r|cfff4a460Heal/Second|r: |cff3399ff(60 x level)|n|r|cfff4a460Manacost/Second|r: |cff3399ff(10 x level)|r|n|nOnce activated drains mana to heal Cave Troll and nearby allies. Heals 4x on ethereal units."
endmodule

module CaveTrollConfig
    set caveTroll = Hero.create('UCav')
    set caveTroll.faction = ANCIENT_EVILS
    set caveTroll.name = "Cave Troll"
    set caveTroll.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_CaveTroll.blp"
    set caveTroll.scaleAdd = -0.45
    set caveTroll.modelPath = "Models\\Units\\CaveTroll.mdx"
    set caveTroll.info = "A VERY FORMIDABLE WARRIOR THAT SPECIALIZES IN DEALING ENORMOUS DAMAGE IN A SHORT INVERVALS AS WELL AS KEEPING OPPONENTS CLOSE AND |nPROPERLY DETAINED. UNAFRAID OF LARGE AMOUNTS OF DAMAGE CAN VERY QUICKLY REGAIN HIS HEALTH AS WELL AS ALLIES. MASTERED CLOSE RANGE |nCOMBAT AND ENEMY OBSERVATION TO PERFECTION, AND AT THE SAME TIME IS COMPLETELY UNAFRAID OF TAKING HEAVY ENEMY DAMAGE ON HIS CHEST."
    set caveTroll.infoSize = 4.7
    set caveTroll.attribute = "19 +4.5    7 +2.5   12 +1.2"
    set caveTroll.primary = STR

    //Configure Spells
    set caveTroll.innateSpell = cleave
    set caveTroll.spell11 = heavySwing
    set caveTroll.spell12 = threeSixty
    set caveTroll.spell13 = secondHit
    set caveTroll.spell14 = studdedClub
    set caveTroll.spell21 = testudo
    set caveTroll.spell22 = strongBack
    set caveTroll.spell23 = innerResistance
    set caveTroll.spell24 = bloodlust
    set caveTroll.spell31 = smell
    set caveTroll.spell32 = eyeRay
    set caveTroll.spell33 = cauldron
    set caveTroll.spell41 = totem
    set caveTroll.spell42 = devour
    set caveTroll.spell43 = rage
    set caveTroll.spell44 = auraOfStrength
    call caveTroll.end()
endmodule

module CaveTrollButton
    call HeroButton.create(caveTroll)
endmodule