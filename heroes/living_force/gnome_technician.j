globals
    Hero gnomeTechnician
    //GnomeTechnician Spells
    Spell statisTrap
    Spell bomb
    Spell stickyLiquid
    Spell motionController
endglobals

module GnomeTechnicianSpells

    set statisTrap = Spell.create('AH61')
    set statisTrap.info = "Statis Trap"

    set bomb = Spell.create('AH62')
    set bomb.info = "Bomb"

    set stickyLiquid = Spell.create('AH63')
    set stickyLiquid.info = "Sticky Liquid"

    set motionController = Spell.create('AH64')
    set motionController.info = "Motion Controller"

endmodule

module GnomeTechnicianConfig
    set gnomeTechnician = Hero.create('H006')
    set gnomeTechnician.faction = LIVING_FORCE
    set gnomeTechnician.name = "Gnome Technician"
    set gnomeTechnician.scaleAdd = -0.55
    set gnomeTechnician.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_GnomeTechnician.blp"
    set gnomeTechnician.modelPath = "Models\\Units\\GnomeTechnician.mdx"
    set gnomeTechnician.info = "<NOTHING YET>"
    set gnomeTechnician.attribute = "19 +3.0    7 +4.3   12 +1.5"
    set gnomeTechnician.primary = STR
    
    //Configure Spells
    set gnomeTechnician.spell11 = statisTrap
    set gnomeTechnician.spell21 = bomb
    set gnomeTechnician.spell31 = stickyLiquid
    set gnomeTechnician.spell41 = motionController
    call gnomeTechnician.end()
endmodule

module GnomeTechnicianButton
    call HeroButton.create(gnomeTechnician)
endmodule