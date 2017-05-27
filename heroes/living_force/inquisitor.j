globals
    Hero inquisitor
    //Inquisitor Spells
    Spell manaShield
    Spell manaBlast
    Spell brillianceAura
    Spell silencingPain
endglobals

module InquisitorSpells
    set manaShield = Spell.create('AHA1')
    set manaShield.info = "Mana Shield|n|cfff4a460Target|r: |cff3399ffSelf|n|r|cfff4a460Damage per Mana|r: |cff3399ff(0.5 x level)|n|r|nInquisitor creates a mana shield that absorbs any incoming damage in exchange for his mana."

    set manaBlast = Spell.create('AHA2')
    set manaBlast.info = "Mana Blast"

    set brillianceAura = Spell.create('AHA3')
    set brillianceAura.info = "Brilliance Aura"

    set silencingPain = Spell.create('AHA4')
    set silencingPain.info = "Silencing Pain|n|cfff4a460Target|r: |cff3399ffEnemy Unit|n|r|cfff4a460Range|r: |cff3399ff400|n|r|cfff4a460Duration|r: |cff3399ff(10 x level) seconds|n|r|cfff4a460Cooldown|r: |cff3399ff90 seconds|r|n|nInquisitor puts a seal on target unit making it suffer each time it casts a spell. Each cast attempt refreshes the debuff duration and deals damage based on mana costs of the spell. First spell deals 100% mana costs and adds additional 100% to each further spell."
endmodule

module InquisitorConfig
    set inquisitor = Hero.create('H00A')
    set inquisitor.faction = LIVING_FORCE
    set inquisitor.name = "Inquisitor"
    set inquisitor.scaleAdd = -0.2
    set inquisitor.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_Inquisitor.blp"
    set inquisitor.modelPath = "Models\\Units\\Inquisitor.mdl"
    set inquisitor.info = "<NOTHING YET>"
    set inquisitor.attribute = "20 +1.0   20 +1.5   20 +3.5"
    set inquisitor.primary = INT

    //Configure Spells
    set inquisitor.spell11 = manaShield
    set inquisitor.spell21 = manaBlast
    set inquisitor.spell31 = brillianceAura
    set inquisitor.spell41 = silencingPain
    call inquisitor.end()
endmodule

module InquisitorButton
    call HeroButton.create(inquisitor)
endmodule