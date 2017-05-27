globals
    Hero knight
    //Knight Spells
    Spell angelicBlessing
    Spell robustForce
    Spell shieldReaction
    Spell bash
endglobals

module KnightSpells
    set angelicBlessing = Spell.create('AHB1')
    set angelicBlessing.info = "Angelic Blessing"

    set robustForce = Spell.create('AHB2')
    set robustForce.passive = true
    set robustForce.info = "Robust Force|n|cfff4a460Target|r: |cff3399ffPassive / Self and Allies|r|cfff4a460|nRange|r: |cff3399ff300|n|r|cfff4a460Return Damage|r: |cff3399ff(4% x level)|n|r|nKnight and nearby allies will return percent of damage back to attacker."

    set shieldReaction = Spell.create('AHB3')
    set shieldReaction.info = "Shield Reaction"

    set bash = Spell.create('AHB4')
    set bash.passive = true
    set bash.info = "Bash|n|cfff4a460Target|r: |cff3399ffEnemy Unit|n|r|cfff4a460Range|r: |cff3399ffMelee|n|r|cfff4a460Chance|r: |cff3399ff(7.5% x level)|n|r|cfff4a460Stun Duration|r: |cff3399ff2 seconds|r|n|nPassive ability providing Knight with a chance to stun enemy unit upon an attack."
endmodule

module KnightConfig
    set knight = Hero.create('H00B')
    set knight.faction = LIVING_FORCE
    set knight.name = "Knight"
    set knight.scaleAdd = 0.25
    set knight.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_Knight.blp"
    set knight.modelPath = "Models\\Units\\Knight.mdl"
    set knight.info = "<NOTHING YET>"
    set knight.attribute = "20 +1.0   20 +1.5   20 +3.5"
    set knight.primary = INT

    //Configure Spells
    set knight.spell11 = angelicBlessing
    set knight.spell21 = robustForce
    set knight.spell31 = shieldReaction
    set knight.spell41 = bash
    call knight.end()
endmodule

module KnightButton
    call HeroButton.create(knight)
endmodule