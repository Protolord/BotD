globals
    Hero zealot
    //Zealot Spells
    Spell dodge
    Spell arcaneNet
    Spell arcaneBomb
    Spell fieryDust
endglobals

module ZealotSpells
    set dodge = Spell.create('AHM1')
    set dodge.info = "Dodge"

    set arcaneNet = Spell.create('AHM2')
    set arcaneNet.info = "Arcane Net|n|cfff4a460Target|r: |cff3399ffEnemy unit|n|r|cfff4a460Range|r: |cff3399ff500|n|r|cfff4a460Duration|r: |cff3399ff(0.5 x ability level) seconds|n|r|cfff4a460Cooldown|r: |cff3399ff20 seconds|r|n|nCauses enemy unit to be temporarily bound the ground. Ensnared units keep their ability to attack and cast spells."

    set arcaneBomb = Spell.create('AHM3')
    set arcaneBomb.info = "Arcane Bomb"

    set fieryDust = Spell.create('AHM4')
    set fieryDust.passive = true
    set fieryDust.info = "Fiery Dust|n|cfff4a460Target|r: |cff3399ffPassive|n|r|cfff4a460Radius|r: |cff3399ff200|n|r|cfff4a460Max Damage/Second|r: |cff3399ff(3% x ability level) Max HP|n|r|cfff4a460Min Damage/Second|r: |cff3399ff(1.5% x ability level) Max HP|r|n|nProvides Zealot with a vortex of Fiery Dust dealing magic damage to all units around him equal to a percentage of their maximum hitpoints based on how close they are to Zealot."
endmodule

module ZealotConfig
    set zealot = Hero.create('H00M')
    set zealot.faction = LIVING_FORCE
    set zealot.name = "Zealot"
    set zealot.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_Zealot.blp"
    set zealot.modelPath = "Models\\Units\\Zealot.mdl"
    set zealot.info = "<NOTHING YET>"
    set zealot.attribute = "20 +1.9   20 +3.5   20 +2.1"
    set zealot.primary = AGI

    //Configure Spells
    set zealot.spell11 = dodge
    set zealot.spell21 = arcaneNet
    set zealot.spell31 = arcaneBomb
    set zealot.spell41 = fieryDust
    call zealot.end()
endmodule

module ZealotButton
    call HeroButton.create(zealot)
endmodule