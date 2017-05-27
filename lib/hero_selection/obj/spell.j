library Spell requires StringSize

    struct Spell extends array
        implement Alloc

        readonly image icon
        readonly real x
        readonly real y
        readonly boolean passive
        readonly boolean autocast
        readonly integer id
        readonly integer addId
        readonly string iconPath
        readonly string name
        readonly real yOffset1
        readonly real yOffset2

        readonly boolean initialized
        private string pInfo1
        private string pInfo2

        readonly static thistype BLANK

        method add takes unit u returns nothing
            local string s
            if not this.initialized then
                set this.initialized = true
                call ExecuteFunc("s__" + this.name + "_init")
            endif
            call UnitAddAbility(u, this.addId)
            call UnitRemoveAbility(u, this.addId)
        endmethod

        method operator info1 takes nothing returns string
            return this.pInfo1
        endmethod

        method operator info2 takes nothing returns string
            return this.pInfo2
        endmethod

        private static thistype global
        private static string text
        private static trigger trg = CreateTrigger()

        private static method setText takes nothing returns boolean
            local thistype this = thistype.global
            local integer lines = 0
            local integer i = 0         //counter for character number of the whole text
            local real count = 0     //number of characters in the line
            local real length = 0
            local real charAdd
            local string word = ""
            local string char
            local boolean getName = true

            set this.pInfo1 = ""
            set this.pInfo2 = ""

            if thistype.text != null then
                loop
                    set char = SubString(thistype.text, i, i + 1)
                    exitwhen char == ""

                    //Special character
                    if char == "|" then
                        set char = SubString(thistype.text, i + 1, i + 2)
                        //Check for color codes start seq
                        if char == "c" or char == "C" then
                            //Include color code in newText
                            set word = word + SubString(thistype.text, i, i + 10)
                            set i = i + 9
                        //Check for color codes end seq
                        elseif char == "r" or char == "R" then
                            set word = word + SubString(thistype.text, i, i + 2)
                            set i = i + 1
                        //Check for line breaker
                        elseif char == "n" or char == "N" then
                            if lines < 12 then
                                set this.pInfo1 = this.pInfo1 + word + SubString(thistype.text, i, i + 2)
                            else
                                set this.pInfo2 = this.pInfo2 + word + SubString(thistype.text, i, i + 2)
                            endif
                            set i = i + 1
                            //Reset new line
                            set lines = lines + 1
                            set count = 0
                            set word = ""
                            set length = 0
                        endif
                        if getName then
                            set getName = false
                        endif
                    else
                        set charAdd =StringSize.measureChar(char)//thistype.length(char)
                        if char == " " then
                            if lines < 12 then
                                set this.pInfo1 = this.pInfo1 + word + " "
                            else
                                set this.pInfo2 = this.pInfo2 + word + " "
                            endif
                            set word = ""
                            set length = 0
                        else
                            set word = word + char
                            set length = length + charAdd
                            if count > 428 then
                                if lines < 12 then
                                    set this.pInfo1 = this.pInfo1 + "\n"
                                else
                                    set this.pInfo2 = this.pInfo2 + "\n"
                                endif
                                set lines = lines + 1
                                set count = length
                            endif
                            if getName then
                                set this.name = this.name + char
                            endif
                        endif
                        set count = count + charAdd
                    endif
                    set i = i + 1
                endloop
                if lines < 12 then
                    set this.pInfo1 = this.pInfo1 + word
                else
                    set this.pInfo2 = this.pInfo2 + word
                endif
                if lines < 12 then
                    set this.yOffset1 = 27.5*lines
                else
                    set this.yOffset1 = 27.5*11
                endif
                set this.yOffset2 = 27.5*(lines) - 1.0
            endif
            if this.iconPath == null then
                if this.passive then
                    set this.iconPath = "ReplaceableTextures\\PassiveButtons\\PASBTN_" + this.name + ".blp"
                elseif this.autocast then
                    set this.iconPath = "ReplaceableTextures\\CommandButtons\\ATC_" + this.name + ".blp"
                else
                    set this.iconPath = "ReplaceableTextures\\CommandButtons\\BTN_" + this.name + ".blp"
                endif
            endif
            return false
        endmethod

        method operator info= takes string str returns nothing
            set thistype.global = this
            set thistype.text = str
            call TriggerEvaluate(thistype.trg)
        endmethod

        static method create takes integer id returns thistype
            local thistype this = thistype.allocate()
            set this.id = id
            set this.addId = 0x02000000 + id
            set this.initialized = false
            set this.name = ""
            set this.passive = false
            set this.autocast = false
            return this
        endmethod

        static method initialize takes nothing returns nothing
            call SystemTest.start("Initializing thistype" + "s:")
            //! runtextmacro SELECTION_SYSTEM_SPELL_IMPLEMENTATION()
            call DestroyTrigger(thistype.trg)
            call SystemTest.end()
        endmethod

        private static method onInit takes nothing returns nothing
            set thistype.BLANK = 0
            set thistype.BLANK.id = 0
            set thistype.BLANK.addId = 0
            set thistype.BLANK.info = ""
            set thistype.BLANK.iconPath = "UI\\BlackImage.blp"
            call TriggerAddCondition(thistype.trg, function thistype.setText)
        endmethod

    endstruct

endlibrary