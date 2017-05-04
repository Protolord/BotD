globals
    Hero gnomeTechnician
    //GnomeTechnician Spells
    Spell stasisTrap
    Spell bomb
    Spell stickyLiquid
    Spell motionController
endglobals

module GnomeTechnicianSpells

    set stasisTrap = Spell.create('AH61')
    set stasisTrap.info = "Stasis Trap|n|cfff4a460Target|r: |cff3399ffPoint|n|r|cfff4a460Cast Range|r: |cff3399ffMelee|n|r|cfff4a460Stasis Trap HP|r: |cff3399ff100|n|r|cfff4a460Trigger Radius|r: |cff3399ff200|n|r|cfff4a460Detonate Radius|r: |cff3399ff400|n|r|cfff4a460Slow|r: |cff3399ff50%|n|r|cfff4a460Slow Duration|r: |cff3399ff(0.5 x level) seconds|n|r|cfff4a460Cooldown|r: |cff3399ff20 seconds|r|n|nGnome Technician plants a stasis trap that slows nearby enemy units instantly when triggered."

    set bomb = Spell.create('AH62')
    set bomb.info = "Bomb|n|cfff4a460Target|r: |cff3399ffPoint|n|r|cfff4a460Explosion Radius|r: |cff3399ff300|n|r|cfff4a460Range|r: |cff3399ff(100 x level)|n|r|cfff4a460Damage|r: |cff3399ff(50 x level)|r|cfff4a460|nCooldown|r: |cff3399ff30 seconds|r|n|nGnome Technician tosses a bomb to the target location. On impact with the ground bomb explodes dealing magic damage to all enemies within radius."

    set stickyLiquid = Spell.create('AH63')
    set stickyLiquid.info = "Sticky Liquid"

    set motionController = Spell.create('AH64')
    set motionController.info = "Motion Controller|n|cfff4a460Target|r: |cff3399ffEnemy Hero|n|r|cfff4a460Range|r: |cff3399ff600|n|r|cfff4a460Attacks to Destroy|r: |cff3399ff5|n|r|cfff4a460Duration|r: |cff3399ff(L1: 5 / L2: 10) seconds|n|r|cfff4a460Cooldown|r: |cff3399ff60 seconds|r|n|nDelvus creates a device that will be directly connected to the Ancient and will not allow it to go further than 300 range away. Device can be destroyed by attacks."

endmodule

module GnomeTechnicianConfig
    set gnomeTechnician = Hero.create('H006')
    set gnomeTechnician.faction = LIVING_FORCE
    set gnomeTechnician.name = "Gnome Technician"
    set gnomeTechnician.scaleAdd = -0.55
    set gnomeTechnician.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_GnomeTechnician.blp"
    set gnomeTechnician.modelPath = "Models\\Units\\GnomeTechnician.mdx"
    set gnomeTechnician.info = "<NOTHING YET>"
    set gnomeTechnician.attribute = "20 +1.0   20 +1.5   20 +3.5"
    set gnomeTechnician.primary = INT

    //Configure Spells
    set gnomeTechnician.spell11 = stasisTrap
    set gnomeTechnician.spell21 = bomb
    set gnomeTechnician.spell31 = stickyLiquid
    set gnomeTechnician.spell41 = motionController
    call gnomeTechnician.end()
endmodule

module GnomeTechnicianButton
    call HeroButton.create(gnomeTechnician)
endmodule