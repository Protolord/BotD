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
    set pyro.info = "Pyro|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Damage|r: |cff3399ff50 + (60/Burn Duration)|n|r|cfff4a460Burn Duration|r: |cff3399ff3 seconds|n|r|cfff4a460Duration|r: |cff3399ff10 seconds|n|r|cfff4a460Cooldown|r: |cff3399ff(30 - (2 x level)) seconds|r|n|nFirelord transforms into a Fire Elemental that burns and damages melee attackers based on previous Burn duration. Burn debuff reduces affected unit's attack damage by 30%. Burn debuff duration stacks additively."

    set firebolt = Spell.create('AH52')
    set firebolt.info = "Firebolt|n|cfff4a460Target|r: |cff3399ffEnemy unit|n|r|cfff4a460Range|r: |cff3399ff700|n|r|cfff4a460Damage|r: |cff3399ff(60 x level)|n|r|cfff4a460Burn Duration|r: |cff3399ff5 seconds|n|r|cfff4a460Cooldown|r: |cff3399ff20 seconds|r|n|nFirelord releases flaming bolt dealing magic damage to the target enemy unit and applies a Burn debuff. Burn debuff reduces affected unit's attack damage by 30%. Burn debuff duration stacks additively."

    set enchantedFires = Spell.create('AH53')
    set enchantedFires.passive = true
    set enchantedFires.info = "Enchanted Fires|n|cfff4a460Target|r: |cff3399ffPassive|n|r|cfff4a460Radius|r: |cff3399ff250|n|r|cfff4a460Chance|r: |cff3399ff(1% x level)|n|r|nAny time Firelord is attacked by a melee unit, Firelord has a chance to explode dealing magic damage around the attacker equal to his current hitpoints. Chance is doubled during Pyro form."

    set meteor = Spell.create('AH54')
    set meteor.info = "Meteor|n|cfff4a460Target|r: |cff3399ffArea of Effect|n|r|cfff4a460Radius|r: |cff3399ff250|n|r|cfff4a460Range|r: |cff3399ff900|n|r|cfff4a460Base Damage|r: |cff3399ff10% Max HP|n|r|cfff4a460Damage/Burn Duration|r: |cff3399ffL1: 1% / L2: 5%|n|r|cfff4a460Cooldown|r: |cff3399ff60 seconds|r|n|nFirelord calls down a Meteor from the sky which deals damage based on target's max hitpoints. Deals extra damage for affected units with Burn debuff."
endmodule

module FirelordConfig
    set firelord = Hero.create('H005')
    set firelord.faction = LIVING_FORCE
    set firelord.name = "Firelord"
    set firelord.scaleAdd = 0.3
    set firelord.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_Firelord.blp"
    set firelord.modelPath = "Models\\Units\\Firelord.mdl"
    set firelord.info = "<NOTHING YET>"
    set firelord.attribute = "20 +1.0   20 +1.5   20 +3.5"
    set firelord.primary = INT

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