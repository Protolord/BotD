library SystemConsoleCommands requires SystemConsole
    
    /*
                    SystemConsoleCommands v1.00
                              by Flux
            
            Contains various console commands to control visibility
            or to scroll the console messages.
            
            COMMANDS:
                "/show"   - Shows/unhide the console
                "/hide"   - Hides the console
                "/down #" - Scroll the console cursor downward by # lines
                "/up #"   - Scroll the console cursor upward by # lines
                "/clear"  - Clears the console
    */
    
    globals
        private constant string CMD_PREFIX = "/"
    endglobals
    
    struct ConsoleCommand extends array
            
        private static method show takes nothing returns boolean
            if GetLocalPlayer() == GetTriggerPlayer() then
                set SystemMsg.show = true
            endif
            return false
        endmethod
        
        private static method hide takes nothing returns boolean
            if GetLocalPlayer() == GetTriggerPlayer() then
                set SystemMsg.show = false
            endif
            return false
        endmethod
        
        private static method clear takes nothing returns boolean
            local SystemMsg this = SystemMsg(0).next
            if GetLocalPlayer() == GetTriggerPlayer() then
                loop
                    exitwhen this == 0
                    call this.destroy()
                    set this = this.next
                endloop
                set SystemMsg.lineCount = 0
                call SystemMsg.refresh()
            endif
            return false
        endmethod
        
        private static method up takes nothing returns boolean
            local string s = GetEventPlayerChatString()
            local integer length = StringLength(s)
            local integer d = 1
            local integer temp
            if length > 4 then
                set d = S2I(SubString(s, 4, length))
                if d < 1 then
                    set d = 0
                endif
            endif
            if GetLocalPlayer() == GetTriggerPlayer() then
                set temp = SystemMsg.cursor + d
                if temp < SystemMsg.count + 16 then
                    set SystemMsg.cursor = temp
                else
                    set SystemMsg.cursor = SystemMsg.count + 15
                endif
                call SystemMsg.refresh()
            endif
            return false
        endmethod
        
        private static method down takes nothing returns boolean
            local string s = GetEventPlayerChatString()
            local integer length = StringLength(s)
            local integer d = 1
            if length > 6 then
                set d = S2I(SubString(s, 6, length))
                if d < 1 then
                    set d = 0
                endif
            endif
            if GetLocalPlayer() == GetTriggerPlayer() then
                if SystemMsg.cursor - d > 16 then
                    set SystemMsg.cursor = SystemMsg.cursor - d
                else
                    set SystemMsg.cursor = 16
                endif
                call SystemMsg.refresh()
            endif
            return false
        endmethod
        
        //! textmacro CONSOLE_CMD_TRIGGER_REGISTER takes WORD, MATCH
            set t = CreateTrigger()
            call TriggerRegisterPlayerChatEvent(t, p, CMD_PREFIX + "$WORD$", $MATCH$)
            call TriggerAddCondition(t, function thistype.$WORD$)
        //! endtextmacro
        
        static method register takes player p returns nothing
            local trigger t
            //! runtextmacro CONSOLE_CMD_TRIGGER_REGISTER("show", "true")
            //! runtextmacro CONSOLE_CMD_TRIGGER_REGISTER("hide", "true")
            //! runtextmacro CONSOLE_CMD_TRIGGER_REGISTER("clear", "true")
            //! runtextmacro CONSOLE_CMD_TRIGGER_REGISTER("up", "false")
            //! runtextmacro CONSOLE_CMD_TRIGGER_REGISTER("down", "false")
            set t = null
        endmethod
        
        private static method onInit takes nothing returns nothing
            call thistype.register(GetLocalPlayer())
        endmethod
        
    endstruct

        
endlibrary