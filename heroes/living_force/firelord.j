globals
    Hero firelord
    //Firelord Spells
    Spell pyro
    Spell firebolt
    Spell enchantedFires
    Spell meteor
endglobals

module FirelordSpells
    set pyro = Spell.create('AH51')
    set pyro.info = "Pyro"

    set firebolt = Spell.create('AH52')
    set firebolt.info = "Firebolt|n|cfff4a460Target|r: |cff3399ffEnemy unit|n|r|cfff4a460Range|r: |cff3399ff700|n|r|cfff4a460Damage|r: |cff3399ff(60 x level)|n|r|cfff4a460Burn Duration|r: |cff3399ff5 seconds|n|r|cfff4a460Cooldown|r: |cff3399ff20 seconds|r|n|nFirelord releases flaming bolt dealing magic damage to the target enemy unit and applies a Burn debuff. Burn debuff reduces affected unit's attack damage by 30%. Burn debuff duration stacks additively."

    set enchantedFires = Spell.create('AH53')
    set enchantedFires.passive = true
    set enchantedFires.info = "Enchanted Fires|n|cfff4a460Target|r: |cff3399ffPassive|n|r|cfff4a460Radius|r: |cff3399ff250|n|r|cfff4a460Chance|r: |cff3399ff(1% x level)|n|r|nAny time Firelord is attacked by a melee unit, Firelord has a chance to explode dealing magic damage around the attacker equal to his current hitpoints."

    set meteor = Spell.create('AH54')
    set meteor.info = "Meteor|n|cfff4a460Target|r: |cff3399ffArea of Effect|n|r|cfff4a460Radius|r: |cff3399ff250|n|r|cfff4a460Range|r: |cff3399ff900|n|r|cfff4a460Base Damage|r: |cff3399ff10% Max HP|n|r|cfff4a460Damage/Burn Duration|r: |cff3399ff(0.4% x level - 0.3%) Max HP|n|r|cfff4a460Cooldown|r: |cff3399ff60 seconds|r|n|nFirelord calls down a Meteor from the sky which deals damage based on target's max hitpoints. Deals extra damage for affected units with Burn debuff."
endmodule

module FirelordConfig
    set firelord = Hero.create('H005')
    set firelord.faction = LIVING_FORCE
    set firelord.name = "Firelord"
    set firelord.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_Elementalist.blp"
    set firelord.modelPath = "Units\\Human\\HeroBloodElf\\HeroBloodElf.mdl"
    set firelord.info = "<NOTHING YET>"
    set firelord.attribute = "19 +3.0    7 +4.3   12 +1.5"
    set firelord.primary = STR
    
    //Configure Spells
    set firelord.spell11 = pyro
    set firelord.spell21 = firebolt
    set firelord.spell31 = enchantedFires
    set firelord.spell41 = meteor
    call firelord.end()
endmodule

module FirelordButton
    call HeroButton.create(firelord)
endmodule