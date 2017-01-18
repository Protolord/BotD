library HeroButton/*

*/ requires /*
    */ Hero /*
    */ SpellDisplay /*
    */ HeroDisplay /*
    */ TrackList /*
    */ SystemConsole /*
*/
    struct HeroButton extends array
        implement Alloc
        
        public image icon
        public real x
        public real y
        public Hero h
        public TrackList tHead
        
        public static real buttonX
        public static real buttonY
        public static Hero array heroes
        public static thistype global
        
        public thistype next
        public thistype prev
        
        public static thistype array heroButton
        
        static method get takes Hero h returns thistype
            return thistype.heroButton[h]
        endmethod
        
        //When a HeroButton gets selected, do not disable Trackable so that it
        //is still clickable
        method selected takes nothing returns nothing
            call SetImageColor(this.icon, 25, 25, 25, 255)
            set thistype.heroButton[this.h] = 0
        endmethod
        
        method destroy takes nothing returns nothing
            local TrackList tl = this.tHead.next
            set this.prev.next = .next
            set this.next.prev = .prev
            loop
                exitwhen tl == 0
                set tl.t.enabled = false
                call tl.destroy()
                set tl = tl.next
            endloop
            call ReleaseImage(this.icon)
            set this.icon = null
            call this.deallocate()
        endmethod
        
        static method destroyAll takes nothing returns nothing
            local thistype this = thistype(0).next
            loop
                exitwhen this == 0
                call this.destroy()
                set this = this.next
            endloop
        endmethod
        
        method show takes player p returns nothing
            local TrackList tl = this.tHead.next
            if GetLocalPlayer() == p then
                call SetImageRenderAlways(this.icon, true)
            endif
            loop
                exitwhen tl == 0
                if tl.p == p then
                    set tl.t.enabled = true
                    exitwhen true
                endif
                set tl = tl.next
            endloop
        endmethod
        
        method hide takes player p returns nothing
            local TrackList tl = this.tHead.next
            if GetLocalPlayer() == p then
                call SetImageRenderAlways(this.icon, false)
            endif
            loop
                exitwhen tl == 0
                if tl.p == p then
                    set tl.t.enabled = false
                    exitwhen true
                endif
                set tl = tl.next
            endloop
        endmethod
        
        static method hideAll takes player p returns nothing
            local thistype this = thistype(0).next
            call SystemTest.start("Disabling HeroButtons for " + GetPlayerName(p) + ": ")
            loop
                exitwhen this == 0
                call this.hide(p)
                set this = this.next
            endloop
            call SystemTest.end()
        endmethod
        
        public static method clicked takes nothing returns nothing
            local thistype this = GetPlayerId(Track.tracker)
            if PlayerStat(this).hero != thistype.heroes[Track.instance] then
                call HeroDisplay.change(Track.tracker, thistype.heroes[Track.instance])
                call SpellDisplay.reset(Track.tracker, thistype.heroes[Track.instance])
            endif
        endmethod
        
        public static method createTrack takes nothing returns nothing
            local player p = GetEnumPlayer()
            local thistype this = thistype.global
            local Track t = Track.createForPlayer(TRACK_PATH_SMALL, thistype.buttonX, thistype.buttonY, 1, 270, p)
            set thistype.heroes[t] = this.h
            call t.registerClick(function thistype.clicked)
            call TrackList.create(this.tHead, t, p)
        endmethod
        
        public static method changeButtonPos takes nothing returns nothing
            set thistype.buttonX = thistype.buttonX + HERO_BUTTON_SPACING
            if thistype.buttonX > HERO_BUTTON_LIMIT then
                set thistype.buttonX = HERO_BUTTON_ORIGIN_X
                set thistype.buttonY = thistype.buttonY - HERO_BUTTON_SPACING
            endif
        endmethod
        
        static method create takes Hero h returns thistype
            local thistype this = thistype.allocate()
            //Declare the Hero for this button
            set this.h = h
            set this.tHead = TrackList.head()
            set thistype.heroButton[h] = this
            //Create a trackable for each group
            set thistype.global = this
            call ForForce(Players.users, function thistype.createTrack)
            //Create the Icon Image
            set this.icon = NewImage(h.iconPath, 64, 64, thistype.buttonX, thistype.buttonY, 1, 1)
            call SetImageRenderAlways(this.icon, true)
            //Change the button position for the next instance to be created
            call thistype.changeButtonPos()
            //Add to List
            set this.next = 0
            set this.prev = thistype(0).prev
            set this.next.prev = this
            set this.prev.next = this
            return this
        endmethod
        
        static method init takes nothing returns boolean
            call SystemTest.start("Creating HeroButtons: ")
            //! runtextmacro SELECTION_SYSTEM_HERO_BUTTON_IMPLEMENTATION()
            call SystemTest.end()
            return false
        endmethod
        
    endstruct

endlibrary