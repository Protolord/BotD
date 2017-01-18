globals
    Hero werewolf
    //Werewolf Spells
    Spell shapeshift
    Spell envenomedFangs
    Spell forceOfLycan
    Spell clawPierce
    Spell fleshHunger
    Spell prowl
    Spell rabies
    Spell enragedKiller
    Spell lycanthrope
    Spell wolfSpirit
    Spell childOfTheNight
    Spell fetch
    Spell rabid
    Spell bloodthirst
    Spell furyOfTheLycan
    Spell revitalize
endglobals

module WerewolfSpells
    //Werewolf

    set shapeshift = Spell.create('A2XX')
    set shapeshift.info = "Shapeshift|n|cfff4a460Target|r: |cff3399ffSelf|r|n|cfff4a460Duration|r: |cff3399ff5 seconds|r|n|nAllows Werewolf to transform into a human making his size lot smaller to enable him to pass through narrow passages. Disables ability to attack."
    
    set envenomedFangs = Spell.create('A211')
    set envenomedFangs.passive = true
    set envenomedFangs.info = "Envenomed Fangs|n|cfff4a460Target|r: |cff3399ffPassive, Enemy|n|r|cfff4a460Effect|r:|cff3399ff 100 damage/sec|n|r|cfff4a460Duration|r:|cff3399ff (1 x level) seconds|n|n|rPoisons attacked unit dealing damage per second."
    
    set forceOfLycan = Spell.create('A212')
    set forceOfLycan.info = "Force Of Lycan|n|cfff4a460Target|r: |cff3399ffEnemy unit|n|r|cfff4a460Range|r: |cff3399ff100|n|r|cfff4a460Duration|r: |cff3399ff(0.5 x level) seconds|n|r|cfff4a460Cooldown|r: |cff3399ff20 seconds|r|n|nChannels your animal instinct to an enemy unit causing it to lose control and attack anything around."
    
    set clawPierce = Spell.create('A213')
    set clawPierce.passive = true
    set clawPierce.info = "Claw Pierce|n|cfff4a460Target|r: |cff3399ffPassive, Enemy|n|r|cfff4a460Chance|r: |cff3399ff(5% x level)|r|n|nEach attack has a chance to devastate the target if it has been hit from behind bringing it to a near-dead state of 1 hitpoint left."
    
    set fleshHunger = Spell.create('A214')
    set fleshHunger.info = "Flesh Hunger|n|cfff4a460Target|r: |cff3399ffEnemy unit|n|r|cfff4a460Range|r:|cff3399ff 100|n|r|cfff4a460Duration|r: |cff3399ff(1 x level) seconds|n|r|cfff4a460Cooldown|r: |cff3399ff15 seconds|r|n|nBites an enemy unit and decreases it's movement speed by 85% for a short period of time."
    
    set prowl = Spell.create('A221')
    set prowl.info = "Prowl|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Duration|r: |cff3399ff(5 x level) seconds|n|r|cfff4a460Effect|r: |cff3399ff(125 damage bonus x level)|n|r|cfff4a460Cooldown|r: |cff3399ff(5 x level) + 5 seconds|r|n|nAllows Werewolf to become temporarily invisible, move 20% slower but deal extra damage on attack breaking invisibility."
    
    set rabies = Spell.create('A222')
    set rabies.passive = true
    set rabies.info = "Rabies|n|cfff4a460Target|r: |cff3399ffPassive, Self|n|r|cfff4a460Max Bonus|r: |cff3399ff(10% x level)|r|n|nWerewolf adrenaline level grows to deadly level. His movement speed has been increased with the same percent as hitpoints missing."
    
    set enragedKiller = Spell.create('A223')
    set enragedKiller.passive = true
    set enragedKiller.info = "Enraged Killer|n|cfff4a460Target|r: |cff3399ffPassive, Enemy|r|n|cfff4a460Damage/Stack|r: |cff3399ff1 + (0.5 x level)|r|n|nSubsequent attack to the same target will deal more damage. If the same target is not attacked after 5 seconds, the bonus damage is lost."
    
    set lycanthrope = Spell.create('A224')
    set lycanthrope.info = "Lycanthrope|n|cfff4a460|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Duration|r: |cff3399ff(0.5 x level) seconds|n|r|cfff4a460Cooldown|r: |cff3399ff25 seconds|r|n|nWerewolf enrages to attack at it's maximum speed for a short period of time."
    
    set wolfSpirit = Spell.create('A231')
    set wolfSpirit.info = "Wolf Spirit|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Wolf Speed|r: |cff3399ff(200 + 35 x level)|n|r|cfff4a460Duration|r: |cff3399ff20 seconds|n|r|cfff4a460Cooldown|r: |cff3399ff20 seconds|r|n|nSummons a spirit wolf which will seek the closest human builder. Has sight range of 1000. Also reveals invisible units."
    
    set childOfTheNight = Spell.create('A232')
    set childOfTheNight.passive = true
    set childOfTheNight.info = "Child Of The Night|n|cfff4a460Target|r: |cff3399ffPassive, Self|n|r|cfff4a460Range|r: |cff3399ff(100 x level)|r|n|nProvides true sight at night."
    
    set fetch = Spell.create('A233')
    set fetch.info = "Fetch|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Duration|r: |cff3399ff5 seconds|n|r|cfff4a460Cooldown|r: |cff3399ff20 seconds|n|r|cfff4a460Range|r: |cff3399ff(1000 x level) |r|n|nProvides a temporary vision over any living units around Werewolf. Also reveals invisible units."
    
    set rabid = Spell.create('A241')
    set rabid.passive = true
    set rabid.info = "Rabid|n|cfff4a460Target|r: |cff3399ffPassive, Self|n|r|cfff4a460Max HP Regen|r: |cff3399ff(1% + 0.2% x level)|n|r|nProvides Werewolf with passive healing based on max hitpoints."
    
    set bloodthirst = Spell.create('A242')
    set bloodthirst.info = "Bloodthirst|n|cfff4a460Target|r: |cff3399ffSelf (800)|n|r|cfff4a460Cooldown|r: |cff3399ff30 seconds|n|r|cfff4a460Initial Heal|r: |cff3399ff(250 x level)|n|r|cfff4a460Bonus Heal/Unit|r:|cff3399ff (50  x level)|r|n|nCalls a wave of dark energy which heals Werewolf depending on number of living enemies in range of 800. Heals 4x more hitpoints on ethereal units."
    
    set furyOfTheLycan = Spell.create('A243')
    set furyOfTheLycan.info = "Fury Of The Lycan|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Duration|r: |cff3399ff9 seconds|n|r|cfff4a460Cooldown|r: |cff3399ff40 - (1 x level) seconds|r|n|nConverts damage taken into heal with twice the amount."
    
    set revitalize = Spell.create('A244')
    set revitalize.info = "Revitalize|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Cooldown|r: |cff3399ff60 seconds|n|r|cfff4a460Max HP Heal|r: |cff3399ff3% + (3% x level)|r|n|nInstantly regenerates lost hitpoints. Heals 4x more hitpoints on ethereal units."
endmodule

module WerewolfConfig
    set werewolf = Hero.create('UWeW')
    set werewolf.faction = ANCIENT_EVILS
    set werewolf.name = "Werewolf"
    set werewolf.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_Werewolf.blp"
    set werewolf.modelPath = "Models\\Units\\Werewolf.mdx"
    set werewolf.info = "WEREWOLVES ARE THE MASTER'S FAVOURITE. ALTHOUGH DEPENDANT ON THE CLOSE DISTANCE COMBAT THEY ARE CAPABLE OF DEALING |nDESTRUCTIVE DAMAGE TO ANYTHING, WHETHER ALIVE OR NOT. WEREWOLVES ARE THE REAL HUNTERS THAT HAVE MASTERED HUNTING |nHUMAN HEROES TO PERFECTION." 
    set werewolf.attribute = "19 +4.1    7 +3.2   12 +1.2"
    set werewolf.primary = AGI
    //Configure Spells
    set werewolf.innateSpell = shapeshift
    set werewolf.spell11 = envenomedFangs
    set werewolf.spell12 = forceOfLycan
    set werewolf.spell13 = clawPierce
    set werewolf.spell14 = fleshHunger
    set werewolf.spell21 = prowl
    set werewolf.spell22 = rabies
    set werewolf.spell23 = enragedKiller
    set werewolf.spell24 = lycanthrope
    set werewolf.spell31 = wolfSpirit
    set werewolf.spell32 = childOfTheNight
    set werewolf.spell33 = fetch
    set werewolf.spell34 = Spell.BLANK
    set werewolf.spell41 = rabid
    set werewolf.spell42 = bloodthirst
    set werewolf.spell43 = furyOfTheLycan
    set werewolf.spell44 = revitalize
    call werewolf.end()
endmodule

module WerewolfButton
    call HeroButton.create(werewolf)
endmodule