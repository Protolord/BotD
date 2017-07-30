globals
    Hero templar
    //Templar Spells
    Spell holyAura
    Spell holySpiral
    Spell sacrifice
    Spell beamingGlare
endglobals

module TemplarSpells
    set holyAura = Spell.create('AHJ1')
    set holyAura.passive = true
    set holyAura.info = "Holy Aura|n|cfff4a460Range|r: |cff3399ff300|n|r|cfff4a460Slow|r: |cff3399ff(3% x level)|n|r|nAll enemies around Templar will have their movement speed reduced."

    set holySpiral = Spell.create('AHJ2')
    set holySpiral.info = "Holy Spiral|n|cfff4a460Target|r: |cff3399ffPoint|n|r|cfff4a460Range|r: |cff3399ff500|n|r|cfff4a460Damage|r: |cff3399ff(50 x level)|n|r|cfff4a460Cooldown|r: |cff3399ff20 seconds|r|n|nTemplar sends a Holy Spiral to deal magic damage to all enemies in the path of the spiral."

    set sacrifice = Spell.create('AHJ3')
    set sacrifice.autocast = true
    set sacrifice.info = "Sacrifice"

    set beamingGlare = Spell.create('AHJ4')
    set beamingGlare.info = "Beaming Glare|n|cfff4a460Target|r: |cff3399ffEnemy unit|n|r|cfff4a460Range|r: |cff3399ff500|n|r|cfff4a460Initial Damage|r: |cff3399ff50|n|r|cfff4a460Duration|r: |cff3399ff(7 + (4 x level)) seconds|n|r|cfff4a460Cooldown|r: |cff3399ff60 seconds|r|n|nTemplar creates a beaming glare between him and target Ancient which deal initial magic damage per second doubling every second. Beaming Glare is lost when Templar moves is outside range of the target."
endmodule

module TemplarConfig
    set templar = Hero.create('H00J')
    set templar.faction = LIVING_FORCE
    set templar.name = "Templar"
    set templar.scaleAdd = -0.25
    set templar.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_Templar.blp"
    set templar.modelPath = "Models\\Units\\Templar.mdl"
    set templar.info = "<NOTHING YET>"
    set templar.attribute = "20 +3.2   20 +2.7   20 +1.3"
    set templar.primary = STR

    //Configure Spells
    set templar.spell11 = holyAura
    set templar.spell21 = holySpiral
    set templar.spell31 = sacrifice
    set templar.spell41 = beamingGlare
    call templar.end()
endmodule

module TemplarButton
    call HeroButton.create(templar)
endmodule