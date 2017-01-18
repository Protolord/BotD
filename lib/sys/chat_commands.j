library ChatCommands uses Table, SystemConsole, PlayerStat
    
   struct Chat extends array

        private static method ms takes nothing returns boolean
            local player p = GetTriggerPlayer()
            local PlayerStat ps = PlayerStat.get(p)
            if p == GetLocalPlayer() then
                call SystemMsg.create(ps.color + ps.name + "|r" + " (" + GetUnitName(ps.unit) + ")'s current movespeed is " + I2S(R2I(GetUnitMoveSpeed(ps.unit))))
            endif
            return false
        endmethod
        
        private static method roll takes nothing returns boolean
            local string s = GetEventPlayerChatString()
            local player p = GetTriggerPlayer()
            local PlayerStat ps = PlayerStat.get(p)
            local integer length = StringLength(s)
            local integer limit = 100
            if length > 6 then
                set limit = S2I(SubString(s, 6, length))
                if limit <= 1 then
                    set limit = 100
                endif
            endif
            if p == GetLocalPlayer() then
                call SystemMsg.create(ps.color + ps.name + "|r has rolled " + I2S(GetRandomInt(0, limit)) + " out of " + I2S(limit))
            endif
            return false
        endmethod
        
        //! textmacro CHAT_TRIGGER_REGISTER takes WORD, MATCH
            set t = CreateTrigger()
            call TriggerRegisterPlayerChatEvent(t, p, "-$WORD$", $MATCH$)
            call TriggerAddCondition(t, function thistype.$WORD$)
        //! endtextmacro
        
        static method register takes player p returns nothing
            local trigger t
            //! runtextmacro CHAT_TRIGGER_REGISTER("ms", "true")
            //! runtextmacro CHAT_TRIGGER_REGISTER("roll", "false")
            set t = null
        endmethod
        
    endstruct
    
endlibrary