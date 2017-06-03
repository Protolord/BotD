library Players uses PlayerStat, SystemConsole

    struct Players extends array

        readonly static force livingForce = CreateForce()
        readonly static force ancientEvils = CreateForce()
        readonly static force players = CreateForce()
        readonly static force users = CreateForce()
        readonly static force observers = CreateForce()

        private static constant boolean DEBUG = true

        private static method usersFilter takes nothing returns boolean
            local player p = GetFilterPlayer()
            return GetPlayerSlotState(p) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(p) == MAP_CONTROL_USER
        endmethod

        private static method playersFilter takes nothing returns boolean
            return GetPlayerSlotState(GetFilterPlayer()) == PLAYER_SLOT_STATE_PLAYING
        endmethod

        private static method observersFilter takes nothing returns boolean
            return GetFilterPlayer() == Player(10)
        endmethod

        private static method usersInit takes nothing returns nothing
            local player p = GetEnumPlayer()
            call Chat.register(p)
            call ConsoleCommand.register(p)
        endmethod

        private static method playersInit takes nothing returns nothing
            local player p = GetEnumPlayer()
            local integer n = GetPlayerId(p)
            static if thistype.DEBUG then
                if n == 0 then
                    call ForceAddPlayer(Players.ancientEvils, p)
                endif
            endif
            if n > 9 then
                call ForceAddPlayer(Players.ancientEvils, p)
            else
                call ForceAddPlayer(Players.livingForce, p)
            endif
            call PlayerStat.init(p)
        endmethod

        private static method onInit takes nothing returns nothing
            call SystemTest.start("Initializing Player Forces:")
            call ForceEnumPlayers(thistype.users, function thistype.usersFilter)
            call ForForce(thistype.users, function thistype.usersInit)
            call ForceEnumPlayers(thistype.players, function thistype.playersFilter)
            call ForForce(thistype.players, function thistype.playersInit)
            call ForceEnumPlayers(thistype.observers, function thistype.observersFilter)
            call SystemTest.end()
        endmethod

    endstruct

endlibrary