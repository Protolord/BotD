globals
    Hero wraith
    //Wraith Spells
    Spell chillingTouch
    Spell deathAndDecay
    Spell mistOfDarkness
    Spell brainSap
    Spell essenceOfEvil
    Spell cursedRift
    Spell horror
    Spell innerDrive
    Spell spiritualTunnel
    Spell ghostlyBeam
    Spell repression
    Spell soulDance
    Spell avante
    Spell spiritualLights
    Spell ancestralRift
    Spell inception
endglobals

module WraithSpells
    //Wraith
    set chillingTouch = Spell.create('A3XX')
    set chillingTouch.passive = true
    set chillingTouch.info = "Chilling Touch|n|cfff4a460Target|r: |cff3399ffPassive, Enemy|n|r|cfff4a460Slow|r: |cff3399ff(1% x Hero Level)|n|r|cfff4a460Duration|r: |cff3399ff5 seconds|r|n|nWraith's melee attacks touch enemies with the chill of the grave and slow their attack and movement speed based on Wraith's level."

    set deathAndDecay = Spell.create('A311')
    set deathAndDecay.info = "Death And Decay|n|cfff4a460Target|r: |cff3399ffArea of Effect (400)|n|r|cfff4a460Range|r: |cff3399ff300|n|r|cfff4a460Damage|r: |cff3399ff%HP x (1 + (0.5 x level))|n|r|cfff4a460Cooldown|r: |cff3399ff30 seconds|r|n|nCreates a magical blow which deals damage to all living units depending on the percentage of HP they have."

    set mistOfDarkness = Spell.create('A312')
    set mistOfDarkness.info = "Mist Of Darkness|n|cfff4a460Target|r: |cff3399ffSelf (400)|n|r|cfff4a460Damage|r: |cff3399ff(35 x level)|n|r|cfff4a460Silence Duration|r: |cff3399ff(0.5 x level) seconds|n|r|cfff4a460Cooldown|r: |cff3399ff20 seconds|r|n|nCreates a mysterious explosion which deals damage to enemies nearby and temporarily silences them."

    set brainSap = Spell.create('A313')
    set brainSap.info = "Brain Sap|n|cfff4a460Target|r: |cff3399ffEnemy Unit|n|r|cfff4a460Range|r: |cff3399ff600|n|r|cfff4a460Damage|r: |cff3399ff(75 x level)|n|r|cfff4a460Cooldown|r: |cff3399ff15 seconds|r|n|nInstantly absorbs hitpoints from target unit."

    set essenceOfEvil = Spell.create('A314')
    set essenceOfEvil.info = "Essence Of Evil|n|cfff4a460Target|r: |cff3399ffEnemy Unit|n|r|cfff4a460Range|r: |cff3399ff600|n|r|cfff4a460Damage|r: |cff3399ff(35 x level)|n|r|cfff4a460Cooldown|r: |cff3399ff20 seconds|r|n|nSends a wave of evil energy which deals damage to target unit and pulls it half way towards Wraith."

    set cursedRift = Spell.create('A321')
    set cursedRift.info = "Cursed Rift|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Damage|r: |cff3399ff(50 x level)|n|r|cfff4a460Duration|r: |cff3399ff(5 + (1 x level)) seconds|n|r|cfff4a460Cooldown|r: |cff3399ff(10 + (1 x level)) seconds|r|n|nWraith becomes invisible and damages units is passing through. Can damage each unit only once. Increases movement speed by 30%."

    set horror = Spell.create('A322')
    set horror.passive = true
    set horror.info = "Horror|n|cfff4a460Target|r: |cff3399ffPassive, Enemy units|n|r|cfff4a460Range|r: |cff3399ff(300 + (50 x level))|n|r|cfff4a460Reduction|r: |cff3399ff(20% + (1% x level))|r|n|nWraith is spreading fear which can slow combat abilities of nearby enemies."

    set innerDrive = Spell.create('A323')
    set innerDrive.info = "Inner Dive|n|cfff4a460Target|r: |cff3399ffPoint|n|r|cfff4a460Damage|r: |cff3399ff(30 x level)|n|r|cfff4a460Range|r: |cff3399ff1000|n|r|cfff4a460Cooldown|r: |cff3399ff30 seconds|r|n|nWraith rushes towards target point dealing damage to all units in it's path. Doesn't pass through obstacles."

    set spiritualTunnel = Spell.create('A324')
    set spiritualTunnel.info = "Spiritual Tunnel|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Effect Delay|r: |cff3399ff8 - (0.5 x level)|n|r|cfff4a460Cooldown|r: |cff3399ff30 seconds|r|n|nInstantly teleports to the middle of the map."

    set ghostlyBeam = Spell.create('A331')
    set ghostlyBeam.info = "Ghostly Beam|n|cfff4a460Target|r: |cff3399ffPoint|n|r|cfff4a460Width|r: |cff3399ff(100 x level)|n|r|cfff4a460Cooldown|r: |cff3399ff30 seconds|r|n|nWraith creates a magical beam which is exploring a long area until it reaches the target point."

    set repression = Spell.create('A332')
    set repression.info = "Repression|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Hitpoints|r: |cff3399ff(100 x level)|n|r|cfff4a460Sight|r: |cff3399ff200 + (100 x level)|n|r|cfff4a460Cooldown|r: |cff3399ff120 seconds|r|n|nSummons a permanent controllable flying scout to explore the map. Scouts reveal invisible units."

    set soulDance = Spell.create('A333')
    set soulDance.info = "Soul Dance|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Sight|r: |cff3399ff(150 x level)|n|r|cfff4a460Duration|r: |cff3399ff20 seconds|n|r|cfff4a460Cooldown|r: |cff3399ff60 seconds|r|n|nSummons four souls that hover around Wraith providing true sight and may be sent to any location on the map to explore it. Soul speed is 522."

    set avante = Spell.create('A341')
    set avante.info = "Avante|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Casting Time|r: |cff3399ff(12 - (0.5 x level))|n|r|cfff4a460Cooldown|r: |cff3399ff90 seconds|r|n|nWraith channels powerful magics. When fully channeled will completely heal Wraith."

    set spiritualLights = Spell.create('A342')
    set spiritualLights.info = "Spiritual Lights|n|cfff4a460Target|r: |cff3399ffSelf (500)|n|r|cfff4a460Heal per second|r: |cff3399ff(40 x level)|n|r|cfff4a460Extra Heal per enemy|r: |cff3399ff5%|n|r|cfff4a460Cooldown|r: |cff3399ff30 seconds|r|n|nWraith summons a number of mysterious lights around which for 10 seconds are healing Wraith and allies nearby. Those lights grow stronger if they sense enemy life within 2000 radius. Heals 4x more hitpoints on ethereal units."

    set ancestralRift = Spell.create('A343')
    set ancestralRift.info = "Ancestral Rift|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Timing|r: |cff3399ff(5 + (1 x level))|n|r|cfff4a460Cooldown|r: |cff3399ff(60 - (1 x level)) seconds|r|n|nBrings Wraith to hitpoints he had several seconds ago."

    set inception = Spell.create('A344')
    set inception.info = "Inception|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Dmg taken|r: |cff3399ff(900% - (50% x level))|n|r|cfff4a460Cooldown|r: |cff3399ff30 seconds|r|n|nWraith summons 2 illusions of himself. After 15 seconds illusions disappear and total hitpoints still maintained by them will heal Wraith. Illusions will perish if moved outside Wraith's 800 radius."
endmodule

module WraithConfig
    set wraith = Hero.create('UWra')
    set wraith.faction = ANCIENT_EVILS
    set wraith.name = "Wraith"
    set wraith.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_Wraith.blp"
    set wraith.scaleAdd = 0.15
    set wraith.modelPath = "Models\\Units\\Wraith.mdx"
    set wraith.info = "WRAITHS ARE THE MOST POWERFUL SPELLCASTERS OF THE LICH KING'S ARMY. EXCELLENT AT DEALING ENORMOUS DAMAGE TO LIVING |nCREATURES AND UNSTOPPABLE IN CLOSE COMBAT AS WELL AS IN DISTANCE. WRAITHS PROVIDE EXCELLENT SUPPORT FOR ANY ALLIES."
    set wraith.attribute = "19 +3.0    7 +3.0   12 +3.5"
    set wraith.primary = INT

    //Configure Spells
    set wraith.innateSpell = chillingTouch
    set wraith.spell11 = deathAndDecay
    set wraith.spell12 = mistOfDarkness
    set wraith.spell13 = brainSap
    set wraith.spell14 = essenceOfEvil
    set wraith.spell21 = cursedRift
    set wraith.spell22 = horror
    set wraith.spell23 = innerDrive
    set wraith.spell24 = spiritualTunnel
    set wraith.spell31 = ghostlyBeam
    set wraith.spell32 = repression
    set wraith.spell33 = soulDance
    set wraith.spell41 = avante
    set wraith.spell42 = spiritualLights
    set wraith.spell43 = ancestralRift
    set wraith.spell44 = inception
    call wraith.end()
endmodule

module WraithButton
    call HeroButton.create(wraith)
endmodule