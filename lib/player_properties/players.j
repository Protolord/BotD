library Players uses PlayerStat
    
    private module M
        
        readonly static force livingForce = CreateForce()
        readonly static force ancientEvils = CreateForce()
        readonly static force players = CreateForce()
        readonly static force users = CreateForce()
        readonly static force observers = CreateForce()
        
        private static method usersFilter takes nothing returns boolean
            local player p = GetFilterPlayer()
            return GetPlayerSlotState(p) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(p) == MAP_CONTROL_USER
        endmethod
        
        private static method playersFilter takes nothing returns boolean
            return GetPlayerSlotState(GetFilterPlayer()) == PLAYER_SLOT_STATE_PLAYING
        endmethod
        
        private static method observersFilter takes nothing returns boolean
            static if DEBUG_MODE then
                return GetFilterPlayer() == Player(0)
            else
                return GetFilterPlayer() == Player(10)
            endif
        endmethod
        
        private static method usersInit takes nothing returns nothing
            local player p = GetEnumPlayer()
            call Chat.register(p)
            debug call ConsoleCommand.register(p)
        endmethod
        
        private static method playersInit takes nothing returns nothing
            local player p = GetEnumPlayer()
            local integer n = GetPlayerId(p)
            static if DEBUG_MODE then
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
        
        private static method initialize takes nothing returns nothing
            call DestroyTimer(GetExpiredTimer())
            call ForceEnumPlayers(thistype.users, function thistype.usersFilter)
            call ForForce(thistype.users, function thistype.usersInit)
            call ForceEnumPlayers(thistype.players, function thistype.playersFilter)
            call ForForce(thistype.players, function thistype.playersInit)
            call ForceEnumPlayers(thistype.observers, function thistype.observersFilter)
        endmethod
        
        private static method onInit takes nothing returns nothing
            call TimerStart(CreateTimer(), 0.0, false, function thistype.initialize)
        endmethod
        
    endmodule
    
    struct Players extends array
        implement M
    endstruct
    
endlibrary