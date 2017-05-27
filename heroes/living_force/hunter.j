globals
    Hero hunter
    //Hunter Spells
    Spell clawBlock
    Spell chains
    Spell companion
    Spell viciousStrike
endglobals

module HunterSpells
    set clawBlock = Spell.create('AH81')
    set clawBlock.info = "Claw Block"

    set chains = Spell.create('AH82')
    set chains.info = "Chains"

    set companion = Spell.create('AH83')
    set companion.info = "Companion|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Bird Damage Dealt|r: |cff3399ff(10% x ability level)|n|r|cfff4a460Cooldown|r: |cff3399ff1 second|r|n|nHunter summons a particular type of bird every cast. Summoned bird is uncontrollable and flies around Hunter within 500 range. Can call upon an Owl with 350 True Sight, an Eagle with 2.5x Critical Hit and a Falcon with Bash. Birds deals only a portion of their attack damage."

    set viciousStrike = Spell.create('AH84')
    set viciousStrike.info = "Vicious Strike"
endmodule

module HunterConfig
    set hunter = Hero.create('H008')
    set hunter.faction = LIVING_FORCE
    set hunter.name = "Hunter"
    set hunter.scaleAdd = -0.15
    set hunter.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_Hunter.blp"
    set hunter.modelPath = "Models\\Units\\Hunter.mdl"
    set hunter.info = "<NOTHING YET>"
    set hunter.attribute = "20 +2.0   20 +3.0   20 +1.3"
    set hunter.primary = AGI

    //Configure Spells
    set hunter.spell11 = clawBlock
    set hunter.spell21 = chains
    set hunter.spell31 = companion
    set hunter.spell41 = viciousStrike
    call hunter.end()
endmodule

module HunterButton
    call HeroButton.create(hunter)
endmodule