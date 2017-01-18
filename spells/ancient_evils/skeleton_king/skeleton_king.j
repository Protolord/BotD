globals
    Hero skeletonKing
    //SkeletonKing Spells
endglobals

module SkeletonKingSpells
    
    call BJDebugMsg("sk done")
endmodule

module SkeletonKingConfig
    set skeletonKing = Hero.create('USke')
    set skeletonKing.faction = ANCIENT_EVILS
    set skeletonKing.name = "Skeleton King"
    set skeletonKing.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_SkeletonKing.blp"
    set skeletonKing.modelPath = "Models\\Units\\SkeletonKing.mdx"
    set skeletonKing.info = "<NOTHING YET>"
    set skeletonKing.attribute = "19 +3.0    7 +4.3   12 +1.5"
    set skeletonKing.primary = STR
    
    //Configure Spells
    set skeletonKing.innateSpell = 0
    set skeletonKing.spell11 = 0
    set skeletonKing.spell12 = 0
    set skeletonKing.spell13 = 0
    set skeletonKing.spell14 = 0
    set skeletonKing.spell21 = 0
    set skeletonKing.spell22 = 0
    set skeletonKing.spell23 = 0
    set skeletonKing.spell24 = 0
    set skeletonKing.spell31 = 0
    set skeletonKing.spell32 = 0
    set skeletonKing.spell33 = 0
    set skeletonKing.spell34 = 0
    set skeletonKing.spell41 = 0
    set skeletonKing.spell42 = 0
    set skeletonKing.spell43 = 0
    set skeletonKing.spell44 = 0
    call skeletonKing.end()
endmodule

module SkeletonKingButton
    call HeroButton.create(skeletonKing)
endmodule