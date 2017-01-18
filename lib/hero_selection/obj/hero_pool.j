library HeroPool requires Table

/*
    HeroPool.create(player)
        - Creates a pool of heroes for a player based on the player's team.
    
    HeroPool.removeHero(Hero)
        - Remove a Hero from all HeroPools.
*/
    struct HeroPoolNode extends array
        implement Alloc
        
        readonly HeroPool poolHead
        readonly Hero hero
        readonly thistype next
        readonly thistype prev
        
        method destroy takes nothing returns nothing
            set this.prev.next = this.next
            set this.next.prev = this.prev
            set this.poolHead.count = this.poolHead.count - 1
            call this.deallocate()
        endmethod
        
        static method add takes thistype hnode, Hero h returns thistype
            local thistype this = thistype.allocate()
            set this.hero = h
            set this.next = hnode
            set this.prev = hnode.prev
            set this.prev.next = this
            set this.next.prev = this
            set this.poolHead = hnode
            return this
        endmethod
        
        static method head takes nothing returns thistype
            local thistype this = thistype.allocate()
            set this.next = this
            set this.prev = this
            return this
        endmethod
        
    endstruct

    struct HeroPool extends array
        
        public integer count
        
        private Table heroMap
        private thistype next
        private thistype prev
        
        method destroy takes nothing returns nothing
            local HeroPoolNode node = HeroPoolNode(this).next
            loop
                exitwhen node == HeroPoolNode(this)
                call node.destroy()
                set node = node.next
            endloop
            call this.heroMap.destroy()
            call HeroPoolNode(this).destroy()
        endmethod
        
        static method create takes player p returns thistype
            local thistype this = thistype(HeroPoolNode.head())
            local Hero h
            set this.count = 0
            set this.heroMap = Table.create()
            //Add heroes based on player's team
            if IsPlayerInForce(p, Players.livingForce) then
                set h = LIVING_FORCE.next
                loop
                    exitwhen h == LIVING_FORCE
                    set this.heroMap[h] = HeroPoolNode.add(HeroPoolNode(this), h)
                    set this.count = this.count + 1
                    set h = h.next
                endloop
            endif
            if IsPlayerInForce(p, Players.ancientEvils) then
                set h = ANCIENT_EVILS.next
                loop
                    exitwhen h == ANCIENT_EVILS
                    set this.heroMap[h] = HeroPoolNode.add(HeroPoolNode(this), h)
                    set this.count = this.count + 1
                    set h = h.next
                endloop
            endif
            set this.next = 0
            set this.prev = thistype(0).prev
            set this.next.prev = this
            set this.prev.next = this
            return this
        endmethod
        
        private static Hero globalHero
        
        private static method remove takes nothing returns nothing
            local thistype this = PlayerStat(GetPlayerId(GetEnumPlayer())).heroPool
            call HeroPoolNode(this.heroMap[thistype.globalHero]).destroy()
        endmethod
        
        //Remove a Hero from all HeroPools
        static method removeHero takes Hero h returns nothing
            set thistype.globalHero = h
            call ForForce(Players.users, function thistype.remove)
        endmethod
        
    endstruct
endlibrary