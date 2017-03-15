library PlayerStat uses RegisterPlayerUnitEvent, SystemConsole, HeroPool

    globals
        private constant real SPAWN_X = 0
        private constant real SPAWN_Y = 0
    endglobals
    
    struct PlayerStat extends array
        
        public Hero hero
        public Spell spell1
        public Spell spell2
        public Spell spell3
        public Spell spell4
        public HeroPool heroPool
        
        readonly player player
        readonly unit unit
        readonly string name
        readonly string color
        
        private boolean ultimateAdded
        private static trigger trg = CreateTrigger()
        
        static method errorMsg takes player p, string s returns nothing
            call DisplayTimedTextToPlayer(p, 0, 0, 10, "[|cffffcc00Invalid Action]|r: " + s)
            if GetLocalPlayer() == p then
                //call StartSound(thistype.error)
            endif
        endmethod
        
        static method get takes player p returns thistype
            return GetPlayerId(p)
        endmethod
        
        readonly static thistype initializer
        
        method createHero takes nothing returns nothing
            local fogmodifier fm
            call SystemTest.start("Creating " + this.hero.name)
            set thistype.initializer = this
            set this.unit = CreateUnit(this.player, this.hero.unitId, SPAWN_X, SPAWN_Y, 270)
            call SystemTest.end()
            set this.ultimateAdded = false
            call this.spell1.add(this.unit)
            call this.spell2.add(this.unit)
            call this.spell3.add(this.unit)
            call this.spell4.add(this.unit)
            if GetLocalPlayer() == this.player then
                call SelectUnit(this.unit, true)
                call SetCameraPosition(SPAWN_X, SPAWN_Y)
                call SetCameraField(CAMERA_FIELD_TARGET_DISTANCE, 1600, 0)
            endif
            call ExecuteFunc("s__" + this.hero.innateSpell.name + "_init")
            set fm = CreateFogModifierRect(this.player, FOG_OF_WAR_FOGGED, WorldBounds.world, false, false)
            call FogModifierStart(fm)
            call DestroyFogModifier(fm)
            call SetHeroLevel(this.unit, 40, true)
        endmethod
        
        private static method addUltimates takes nothing returns boolean
            local thistype this = thistype.get(GetTriggerPlayer())
            if GetHeroLevel(this.unit) > 40 and not this.ultimateAdded then
                call SystemTest.start("Changing " + GetUnitName(this.unit) + "'s ability to Ultimate Form")
                call SelectHeroSkill(this.unit, this.spell1.id)
                call SelectHeroSkill(this.unit, this.spell2.id)
                call SelectHeroSkill(this.unit, this.spell3.id)
                call SelectHeroSkill(this.unit, this.spell4.id)
                call SetUnitAbilityLevel(this.unit, this.spell1.id, 11)
                call SetUnitAbilityLevel(this.unit, this.spell2.id, 11)
                call SetUnitAbilityLevel(this.unit, this.spell3.id, 11)
                call SetUnitAbilityLevel(this.unit, this.spell4.id, 11)
                call UnitModifySkillPoints(this.unit, 0 - GetHeroSkillPoints(this.unit))
                set this.ultimateAdded = true
                call SystemTest.end()
            endif
            return false
        endmethod
        
        static method ultimateEvent takes code c returns nothing
            call TriggerAddCondition(thistype.trg, Condition(c))
        endmethod
        
        static method init takes player p returns nothing
            local thistype this = thistype.get(p)
            call SystemTest.start("Initializing thistype for " + GetPlayerName(p) + ":")
            set this.name = GetPlayerName(p)
            set this.player = p
            call SetPlayerAbilityAvailable(p, 'Abl1', false)
            call SetPlayerAbilityAvailable(p, 'Abl2', false)
            call SetPlayerAbilityAvailable(p, 'Abl3', false)
            call SetPlayerAbilityAvailable(p, 'Abl4', false)
            call TriggerRegisterPlayerUnitEvent(thistype.trg, p, EVENT_PLAYER_HERO_LEVEL, null)
            set this.heroPool = HeroPool.create(p)
            call SystemTest.end()
        endmethod
        
        private static method onInit takes nothing returns nothing
            call TriggerAddCondition(thistype.trg, Condition(function thistype.addUltimates))
            set thistype(0).color = "|c00FF0303"
            set thistype(1).color = "|c000042FF"
            set thistype(2).color = "|c001CE6B9"
            set thistype(3).color = "|c00540081"
            set thistype(4).color = "|c00FFFC01"
            set thistype(5).color = "|c00FEBA0E"
            set thistype(6).color = "|c0020C000"
            set thistype(7).color = "|c00E55BB0"
            set thistype(8).color = "|c00959697"
            set thistype(9).color = "|c007EBFF1"
            set thistype(10).color = "|c00106246"
            set thistype(11).color = "|c004E2A04"
        endmethod
        
    endstruct
    
endlibrary