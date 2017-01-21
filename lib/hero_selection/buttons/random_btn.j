library RandomButton/*

*/ requires /*
    */ HeroPool /*
    */ SystemConsole /*
    */ Track /*
*/

    struct RandomButton extends array
        
        private Track trk
        
        static method remove takes player p returns nothing
            local thistype this = GetPlayerId(p)
            call SystemTest.start("Removing RandomButton for " + GetPlayerName(p) + ": ")
            set this.trk.enabled = false
            call SystemTest.end()
        endmethod
        
        private static method clicked takes nothing returns nothing
            local thistype this = GetPlayerId(Track.tracker)
            local HeroPoolNode head = HeroPoolNode(PlayerStat(this).heroPool)
            local integer i = GetRandomInt(1, HeroPool(head).count - 1)
            local HeroPoolNode hn = head
            loop
                exitwhen i == 0
                set hn = hn.next
                if hn == head then
                    set hn = hn.next
                endif
                if hn == PlayerStat(this).hero then
                    set hn = hn.next
                endif
                set i = i - 1
            endloop
            call HeroDisplay.change(Track.tracker, hn.hero)
            call SpellDisplay.reset(Track.tracker, hn.hero)
        endmethod
        
        private static method createTrack takes nothing returns nothing
            local player p = GetEnumPlayer()
            local thistype this = GetPlayerId(p)
            set this.trk = Track.createForPlayer(TRACK_PATH_SMALL, RANDOM_BTN_X, RANDOM_BTN_Y, 0, 270, p)
            call this.trk.registerClick(function thistype.clicked)
        endmethod
        
        static method init takes nothing returns boolean
            call SystemTest.start("Creating RandomButton: ")
            call ForForce(Players.users, function thistype.createTrack)
            call SystemTest.end()
            return false
        endmethod
        
    endstruct

endlibrary