library ConfirmButton/*

*/ requires /*
    */ HeroPool /*
    */ SpellButton /*
    */ HeroButton /*
    */ SpellDisplay /*
    */ HeroDisplay /*
    */ PlayerStat /*
    */ SystemConsole /*
    */ Track /*
*/
    struct ConfirmButton extends array

        private Track trk
        private image icon

        static method show takes player p, boolean flag returns nothing
            local thistype this = GetPlayerId(p)
            if flag then
                call SetImageColor(this.icon, 255, 255, 255, 255)
            else
                call SetImageColor(this.icon, 25, 25, 25, 255)
            endif
        endmethod

        static method remove takes player p returns nothing
            local thistype this = GetPlayerId(p)
            call SystemTest.start("Removing ConfirmButton for " + GetPlayerName(p) + ": ")
            set this.trk.enabled = false
            call ReleaseImage(this.icon)
            call SystemTest.end()
        endmethod

        private static method clicked takes nothing returns nothing
            local thistype this = GetPlayerId(Track.tracker)
            local PlayerStat p = PlayerStat(this)
            local HeroButton hb = HeroButton.get(p.hero)
            if hb != 0 then
                if p.spell1 != Spell.BLANK and p.spell2 != Spell.BLANK and p.spell3 != Spell.BLANK and p.spell4 != Spell.BLANK then
                    //Make this HeroButton unavailable for other players
                    call hb.selected()
                    //Remove this hero from other player's HeroPool
                    call HeroPool.removeHero(p.hero)
                    //Hide StaticDisplay for this player
                    call StaticDisplay.hide(Track.tracker)
                    //Hide all other HeroButtons from this player
                    call HeroButton.hideAll(Track.tracker)
                    //Hide all other SpellButtons from this player
                    call SpellButton.hideAll(Track.tracker)
                    //Remove ConfirmButton and RandomButton from this player
                    call ConfirmButton.remove(Track.tracker)
                    call RandomButton.remove(Track.tracker)
                    //Hide this player's Spell Display
                    call SpellDisplay(this).destroy()
                    //Hide this player's Hero Display
                    call HeroDisplay(this).destroy()
                    //Create selected Hero for this player
                    call PlayerStat(this).createHero()
                else
                    call PlayerStat.errorMsg(Track.tracker, "Not enough spells selected")
                endif
            else
                call PlayerStat.errorMsg(Track.tracker, "Hero already taken")
            endif
        endmethod

        private static method createTrack takes nothing returns nothing
            local player p = GetEnumPlayer()
            local thistype this = GetPlayerId(p)
            set this.trk = Track.createForPlayer(TRACK_PATH_SMALL, CONFIRM_X, CONFIRM_Y, 0, 270, p)
            set this.icon = NewImage("UI\\HeroSelection\\Check.blp", 90, 90, CONFIRM_X, CONFIRM_Y, 1, 1)
            call SetImageRenderAlways(this.icon, true)
            call this.trk.registerClick(function thistype.clicked)
        endmethod

        static method init takes nothing returns boolean
            call SystemTest.start("Creating ConfirmButton: ")
            call ForForce(Players.users, function thistype.createTrack)
            call SystemTest.end()
            return false
        endmethod

    endstruct

endlibrary