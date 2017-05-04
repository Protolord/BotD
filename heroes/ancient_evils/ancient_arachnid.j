globals
    Hero ancient_arachnid
    //Arachnid Spells
    Spell burrow
    Spell dash
    Spell locustSwarm
    Spell poisonSpit
    Spell cocoon
    Spell dissimulation
    Spell hatch
    Spell stickyShell
    Spell web
    Spell spiders
    Spell webSpin
    Spell tunnel
    Spell spray
    Spell feed
    Spell poisonBlast
    Spell severeWounds
endglobals

module AncientArachnidSpells
    //Arachnid
    //Check spellId if already taken
    set burrow = Spell.create('A4XX')
    set burrow.info = "Burrow|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Cooldown|r: |cff3399ff5 seconds|r|n|nAncient Arachnid digs to the ground to become invisible. On unburrow kills any living units above him in range of 150."

    set dash = Spell.create('A411')
    set dash.info = "Dash|n|cfff4a460Target|r: |cff3399ffEnemy Unit|n|r|cfff4a460Range|r: |cff3399ff600|n|r|cfff4a460Slow|r: |cff3399ff50%|n|r|cfff4a460Duration|r: |cff3399ff(1 second x level)|n|r|cfff4a460Cooldown|r: |cff3399ff20 seconds|r|n|nAncient Arachnid jumps to the target unit to slow it's movement speed. Cannot pass through cliffs and obstacles."

    set locustSwarm = Spell.create('A412')
    set locustSwarm.info = "Locust Swarm|n|cfff4a460Target|r: |cff3399ffSelf (800)|n|r|cfff4a460Locust Damage|r: |cff3399ff15|n|r|cfff4a460Heal/Damage|r: |cff3399ff(100% x level)|n|r|cfff4a460Duration|r: |cff3399ff30 seconds|n|r|cfff4a460Cooldown|r: |cff3399ff60 seconds|r|n|nAncient Arachnid summons a Locust Swarm that deals damage each and returns to Ancient Arachnid to heal him."

    set poisonSpit = Spell.create('A413')
    set poisonSpit.info = "Poison Spit|n|cfff4a460Target|r: |cff3399ffEnemy unit|n|r|cfff4a460Range|r: |cff3399ffMelee|n|r|cfff4a460Damage per second|r: |cff3399ff40|n|r|cfff4a460Duration|r: |cff3399ff(1 second x level)|n|r|cfff4a460Cooldown|r: |cff3399ff20 seconds|r|n|nAncient Arachnid spits venom at his target silencing it and dealing damage per second."

    set cocoon = Spell.create('A414')
    set cocoon.info = "Cocoon|n|cfff4a460Target|r: |cff3399ffEnemy Unit|n|r|cfff4a460Range|r: |cff3399ffMelee|n|r|cfff4a460Attack Speed Slow|r: |cff3399ff%HP missing|n|r|cfff4a460Attack required|r: |cff3399ff(5 + (1 x level))|n|r|cfff4a460Cooldown|r: |cff3399ff20 seconds|r|n|nTraps enemy unit in cocoon making target unable to move and slowing it but retaining the ability to attack and cast spells. Cocoon can be destroyed with a number of attacks."

    set dissimulation = Spell.create('A421')
    set dissimulation.info = "Dissimulation|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Effect|r: |cff3399ff+25% MS|n|r|cfff4a460Silence duration|r: |cff3399ff(1 second x level)|n|r|cfff4a460Duration|r: |cff3399ff15 seconds|n|r|cfff4a460Cooldown|r: |cff3399ff20 seconds|r|n|nAncient Arachnid turns invisible, moves faster and on attack temporarily silences enemy unit."

    set hatch = Spell.create('A422')
    set hatch.info = "Hatch|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Hatchling Damage|r: |cff3399ff25|n|r|cfff4a460Duration|r: |cff3399ff(10 + (2 x level)) seconds |n|r|cfff4a460Cooldown|r: |cff3399ff30 seconds|r|n|nAncient Arachnid summons five uncontrollable and unattackable spiders that attack enemy units nearby. Each spider attacks once every second. Spiders are slow but they can pass through narrow obstacles."

    set stickyShell = Spell.create('A423')
    set stickyShell.passive = true
    set stickyShell.info = "Sticky Shell|n|cfff4a460Target|r: |cff3399ffPassive|n|r|cfff4a460Attack Slow|r: |cff3399ff50%|n|r|cfff4a460Damage per second|r: |cff3399ff50|n|r|cfff4a460Duration|r: |cff3399ff(1 second x level)|r|n|nMelee units that attacked Ancient Arachnid will be slowed by 50% and take damage over time."

    set web = Spell.create('A424')
    set web.info = "Web|n|cfff4a460Target|r: |cff3399ffEnemy unit|n|r|cfff4a460Range|r: |cff3399ff300|n|r|cfff4a460Duration|r: |cff3399ff(0.5 x level) seconds|n|r|cfff4a460Cooldown|r: |cff3399ff20 seconds|r|n|nCauses enemy unit to be temporarily bound the ground. Webbed units keep their ability to attack and cast spells."

    set spiders = Spell.create('A431')
    set spiders.info = "Spiders|n|cfff4a460Target|r: |cff3399ffSelf|r|n|cfff4a460Spiders Summoned|r: |cff3399ff(1 x level)|r|n|cfff4a460Spider HP|r: |cff3399ff200|r|n|cfff4a460Sight|r: |cff3399ff1000|r|n|cfff4a460Speed|r: |cff3399ff522|r|n|cfff4a460Cooldown|r: |cff3399ff30 seconds|r|n|nAncient Arachnid summons a number of uncontrollable spiders that rush to a random location around the map. Each Spider also reveals invisible units but it cannot pass through cliffs and obstacles."

    set webSpin = Spell.create('A432')
    set webSpin.info = "Web Spin|n|cfff4a460Target|r: |cff3399ffSelf (350)|r|n|cfff4a460Slow|r: |cff3399ff90%|r|n|cfff4a460Duration|r: |cff3399ff(10 + (2 x level)) seconds|r|n|cfff4a460Cooldown|r: |cff3399ff30 seconds|r|n|nAncient Arachnid spins a web providing vision. Enemy units inside the web will have it's movement speed slowed. Ancient Arachnid's movement speed is at maximum as long as there is an enemy unit inside the web."

    set tunnel = Spell.create('A433')
    set tunnel.info = "Tunnel|n|cfff4a460Target|r: |cff3399ffPoint|r|n|cfff4a460Tunneler HP|r: |cff3399ff800|r|n|cfff4a460Sight|r: |cff3399ff(150 x level)|r|n|cfff4a460Speed|r: |cff3399ff522|r|n|cfff4a460Duration|r: |cff3399ff15 seconds|r|n|cfff4a460Cooldown|r: |cff3399ff30 seconds|r|n|nAncient Arachnid sends an underground scout to the target location. Scout can move underground and reveals invisible units but it is visible and targetable."

    set spray = Spell.create('A441')
    set spray.info = "Spray|n|cfff4a460Target|r: |cff3399ffAoE (250)|n|r|cfff4a460Range|r: |cff3399ff800|n|r|cfff4a460Heal per second|r: |cff3399ff(150 x level) |n|r|cfff4a460Duration|r: |cff3399ff4 seconds|r|n|cfff4a460Cooldown|r: |cff3399ff30 seconds|r|n|nAncient Arachnid repeatedly blasts a small area with acid that heals allies in range. Heals 4x hitpoints on ethereal units."

    set feed = Spell.create('A442')
    set feed.info = "Feed|n|cfff4a460Target|r: |cff3399ffSelf |n|r|cfff4a460Scarab HP|r: |cff3399ff200|n|r|cfff4a460Heal per HP|r: |cff3399ff(100% x level)|n|r|cfff4a460Duration|r: |cff3399ff5 seconds|n|r|cfff4a460Cooldown|r: |cff3399ff30 seconds|r|n|nAncient Arachnid summons five scarabs that can be manually sacrificed to heal Ancient Arachnid or his ally based on Scarab's current HP. Heals 4x more hitpoints on ethereal units."

    set poisonBlast = Spell.create('A443')
    set poisonBlast.info = "Poison Blast|n|cfff4a460Target|r: |cff3399ffSelf (700)|n|r|cfff4a460Base Heal|r: |cff3399ff(100 x level)|n|r|cfff4a460Damage|r: |cff3399ff(5% x level) of current HP|n|r|cfff4a460Cooldown|r: |cff3399ff30 seconds|r|n|nAncient Arachnid blows with venomous poison which deals damage based on target's current HP and heals himself with base healing plus total damage dealt."

    set severeWounds = Spell.create('A444')
    set severeWounds.info = "Severe Wounds|n|cfff4a460Target|r: |cff3399ffSelf |n|r|cfff4a460Healer Bug HP|r: |cff3399ff500|n|r|cfff4a460Heal/second|r: |cff3399ff(100 x level)|r|n|cfff4a460Duration|r: |cff3399ff10 seconds|r|n|cfff4a460Cooldown|r: |cff3399ff30 seconds|r|n|nAncient Arachnid summons a friendly healer bug that heals certain amount per second. Bug is attackable and heals 4x more hitpoints on ethereal units."
endmodule

module AncientArachnidConfig
    set ancient_arachnid = Hero.create('UAra')
    set ancient_arachnid.faction = ANCIENT_EVILS
    set ancient_arachnid.name = "Ancient Arachnid"
    set ancient_arachnid.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_AncientArachnid.blp"
    set ancient_arachnid.scaleAdd = -0.15
    set ancient_arachnid.modelPath = "Models\\Units\\AncientArachnid.mdl"
    set ancient_arachnid.info = "ARACHNIDS MASTERED THEIR SUMMON, STICKY WEB AND ACID ABILITIES. WHEN COMBINED IT TURNS ARACHNID INTO DEADLY WEAPON IN THE |nHANDS OF THE SCOURGE. AS A PART OF THE SPIDER KINGDOM THEY EXCEL AT HUNTING DOWN ANYTHING THAT MOVES AND PROVIDING |nUNSTOPPABLE SUPPORT TO ALLIES."
    set ancient_arachnid.attribute = "19 +3.0    7 +4.2   12 +1.7"
    set ancient_arachnid.primary = AGI

    //Configure Spells
    set ancient_arachnid.innateSpell = burrow
    set ancient_arachnid.spell11 = dash
    set ancient_arachnid.spell12 = locustSwarm
    set ancient_arachnid.spell13 = poisonSpit
    set ancient_arachnid.spell14 = cocoon
    set ancient_arachnid.spell21 = dissimulation
    set ancient_arachnid.spell22 = hatch
    set ancient_arachnid.spell23 = stickyShell
    set ancient_arachnid.spell24 = web
    set ancient_arachnid.spell31 = spiders
    set ancient_arachnid.spell32 = webSpin
    set ancient_arachnid.spell33 = tunnel
    set ancient_arachnid.spell41 = spray
    set ancient_arachnid.spell42 = feed
    set ancient_arachnid.spell43 = poisonBlast
    set ancient_arachnid.spell44 = severeWounds
    call ancient_arachnid.end()
endmodule

module AncientArachnidButton
    call HeroButton.create(ancient_arachnid)
endmodule