globals
    Hero guardian
    //Guardian Spells
endglobals

module GuardianSpells
endmodule

module GuardianConfig
    set guardian = Hero.create('H009')
    set guardian.faction = LIVING_FORCE
    set guardian.name = "Guardian"
    set guardian.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_Guardian.blp"
    set guardian.modelPath = "Models\\Units\\Guardian.mdl"
    set guardian.info = "<NOTHING YET>"
    set guardian.attribute = "20 +1.0   20 +1.5   20 +3.5"
    set guardian.primary = INT

    //Configure Spells
    call guardian.end()
endmodule

module GuardianButton
    call HeroButton.create(guardian)
endmodule