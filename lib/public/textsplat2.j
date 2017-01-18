//**
//*    Credits:
//*        - Vexorian   ( ARGB )
//*        - Nestharus  ( ErrorMessage  )
//*        - Bribe      ( Table )
//*        - PitzerMike ( original TextSplat system )
//*        - Deaod      ( TextSplat system of the second generation )
//**
//* Written by BPower
library TextSplat2 /*v2.0
*************************************************************************************
*
*   Creates objects of type "textsplat", which are strings displayed in a sequence of images. 
*   In API textsplats have a remarkable resemblance to the texttag handle.  
*   Only the creation of a textsplat requires an extra argument ( a font ).
*
*************************************************************************************
*
*   */ requires /*
*  
*       */ ARGB       /*            wc3c.net/showthread.php?t=101858
*       */ Font       /*            hiveworkshop.com/forums/submissions-414/textsplat2-273717/
*       */ Table      /*            hiveworkshop.com/forums/jass-resources-412/snippet-new-table-188084/
*       */ Queue      /*            github.com/nestharus/JASS/blob/master/jass/Data%20Structures/Queue/script.j
*       */ optional ImageUtils   /* wc3c.net/showthread.php?t=107707[/url]
*       */ optional ImageTools   /* hiveworkshop.com/forums/submissions-414/imagetools-271099/
*       */ optional ErrorMessage /* github.com/nestharus/JASS/tree/master/jass/Systems/ErrorMessage
*
************************************************************************************/
//**
//* Import instruction:
//* ===================
    //*  Copy the TextSplat2, Font and their requirements into your map.
//**
//*  API: 
//*  ====
    //*  The API is similar to the texttag API with one exception. 
    //* "CreateTextsplat(font)" expects a font as argument, while CreateTextTag() doesn't require any argument.
    //* Below the object orientated API is listed, as it offers some cool feature texttags don't have.
//! novjass ( Disables the compiler until the next endnovjass )
    
    struct textsplat
    //**
    //*  Methods:
    //*  ========
        static method create takes font f returns textsplat
        method destroy       takes nothing returns nothing

        method setText takes string s, real height, integer aligntype returns nothing
        //*  Available aligntype are TEXTSPLAT_TEXT_ALIGN_LEFT, TEXTSPLAT_TEXT_ALIGN_CENTER and TEXTSPLAT_TEXT_ALIGN_RIGHT
        //*
        //* Hint: You can bind images into a text ( if added to the font ) by using "|i" as identifier.
        //* Example:  "The price is 2000 |igold|i"
        //* Output: Textsplat will translate "|igold|i" into the gold coin image.
        
        method setVelocity  takes real xvel, real yvel, real zvel returns nothing
        method setColor     takes integer red, integer green, integer blue, integer alpha returns nothing
        method setPosition  takes real x, real y, real z return nothing
        method setPosUnit   takes unit u, real z returns nothing
        method setSuspended takes boolean flag returns nothing
        method setVisible   takes boolean flag returns nothing
    //**
    //*  Fields you may manipulate directly:
    //*  ===================================
        font    fontType
        real    age
        real    lifespan
        real    fadepoint
        boolean permanent
    //**
    //*  Fields you may read:
    //*  ====================
        readonly integer charCount
        //*  Position values.
        readonly real    x
        readonly real    y
        readonly real    z
        //*  Velocity values.
        readonly real    dX
        readonly real    dY
        readonly real    dZ
        //*  Width and height of a text are very useful.
        readonly real    width
        readonly real    height
        readonly boolean suspended
        readonly boolean visible
        readonly string  text
        readonly ARGB    color
//! endnovjass
//**
//*  User configuration:
//*  ===================
    globals
        //*  Set the timer accuracy.
        private constant real    ACCURACY           = 1./32.
        //*  Set the default color for textsplats. If unsure use 0xFFFFFFFF.
        private constant integer DEFAULT_COLOR      = 0xFFFFFFFF
        //*  Set the default image type for textsplats.
        private constant integer DEFAULT_IMAGE_TYPE = IMAGE_TYPE_SELECTION
        //*  Set how many chars can be parsed per function evaluation.
        //* Use lower values if you use many |cAARRGGBB strings in textsplats. Maximum working value is about 65.
        private constant    integer TOKENS_PER_CHUNK = 40
//**
//*  Globals you can read: 
//*  =====================
    //* ( Do not change these global values )
        constant integer DEFAULT_IMAGE_SIZE          = 32
        constant integer TEXTSPLAT_TEXT_ALIGN_LEFT   = 0
        constant integer TEXTSPLAT_TEXT_ALIGN_CENTER = 1
        constant integer TEXTSPLAT_TEXT_ALIGN_RIGHT  = 2
        constant real    TEXT_SIZE_TO_IMAGE_SIZE     = 4.146479
    endglobals
//========================================================================
//*  Textsplat2 system code. Make changes carefully.
//========================================================================    
//**
//*  Terrain offset z:
//*  =================
    //*  Native SetImageConstantHeight() expects an absolute z value.
    globals 
        private constant location LOC = Location(0, 0)
    endglobals
    private function GetLocZ takes real x, real y returns real
        call MoveLocation(LOC, x, y)
        return GetLocationZ(LOC)
    endfunction
//**
//*  Struct Char:
//*  ============
    //*  The data struture is a queue. You can replace the module
    //* with any data structure module which supports
    //* create(), destroy(), enqueue() and clear()
    private struct Char extends array
        implement Queue
        //*  Struct members.
        image   img
        integer imageType
        string  path
        real    sizeX
        real    sizeY
        real    x
        real    y
        real    z
        boolean show
        boolean colorize//*  Non char images are not colorized.
        integer alpha
        integer red
        integer blue
        integer green
        
        private method draw takes nothing returns nothing
            if (img != null) then
                call ReleaseImage(img)
            endif
            static if LIBRARY_ImageTools then
                set img = NewImage(path, sizeX, sizeY, x, y, 0, imageType)
            elseif LIBRARY_ImageUtils then
                set img = NewImage(path, sizeX, sizeY, 0, x, y, 0, 0, 0, 0, imageType)
            endif
            call SetImageConstantHeight(img, true, z + GetLocZ(x, y))
            call SetImageColor(img, red, green, blue, alpha)
            call SetImageRenderAlways(img, show)            
        endmethod
        
        method setColor takes ARGB value returns nothing
            set alpha = value.alpha
            set red   = value.red
            set green = value.green
            set blue  = value.blue
            call SetImageColor(img, red, green, blue, alpha)
        endmethod
        
        private method new takes string strPath, real sX, real sY, real posX, real posY, real posZ returns thistype
            local ARGB val = DEFAULT_COLOR
            set this = enqueue()//*  New node.
            set path = strPath
            set sizeX = sX
            set sizeY = sY
            set x = posX
            set y = posY
            set z = posZ
            set show = true
            set imageType = DEFAULT_IMAGE_TYPE
            set alpha = val.alpha
            set red = val.red
            set green = val.green
            set blue = val.blue
            call draw()
            return this
        endmethod
        
        method createChar takes font ft, string symbol, real x, real y, real z, real size returns thistype
            return new(ft.getChar(symbol).path, size*TEXT_SIZE_TO_IMAGE_SIZE, size*TEXT_SIZE_TO_IMAGE_SIZE, x, y, z)
        endmethod
        
        method createImage takes font ft, string img, real x, real y, real z, real size returns thistype
            return new(ft.getImage(img).path, size*TEXT_SIZE_TO_IMAGE_SIZE, size*TEXT_SIZE_TO_IMAGE_SIZE, x, y, z)
        endmethod
    endstruct
    
    globals
        //*  Globals to transfer variable values between functions, which use
        //* either function.evaluate or ForForce to not hit the OOP limit.
        private integer strLength
        private integer currentLength  
        private integer tokenAmount
        private real    maxLineWidth
        private integer currentLine
        private boolean defaultColor
        private ARGB    currentColor
        private real    sourceX
        private real    sourceY
        //*
        private string array textChars
        private real   array lineWidth
    endglobals
//**
//*  Hex to Decimal:
//*  ===============
    globals
        private Table Hex2Dec 
        private Table IsHex   
    endglobals
    
    private function IsHexadecimal takes integer i returns boolean
        local integer l = i + 8
        loop
            exitwhen (i >= l)
            if not IsHex.has(StringHash(textChars[i])) then
                return false
            endif
            set i = i + 1
        endloop
        return true
    endfunction
//**
//*  Perpare source string:
//*  ======================
    private function SplitString takes string text returns nothing
        local integer i = 0
        loop
            exitwhen (i == strLength)
            set textChars[i] = SubString(text, i, i + 1)
            set i = i + 1
        endloop
        set textChars[i] = null//*  Will indicate the end of the text.
    endfunction
//**
//*  String parsing:
//*  ===============
    globals
        private constant integer TOKEN_TYPE_INVALID  = 0
        private constant integer TOKEN_TYPE_NORMAL   = 1
        private constant integer TOKEN_TYPE_NEWLINE  = 2
        private constant integer TOKEN_TYPE_COLOR    = 3
        private constant integer TOKEN_TYPE_COLOREND = 4
        private constant integer TOKEN_TYPE_IMAGE    = 5
    endglobals
    
    private struct TextToken extends array
        static thistype current
        integer tokenType
        string  value
        ARGB    color
        boolean isDefaultColor
        integer line
        real    posX
        real    posY
    endstruct
    
    private function TokenizeText takes nothing returns nothing
        local integer   i     = currentLength
        local TextToken base  = TextToken.current
        local TextToken token = base
        local string    char
        loop
            exitwhen (integer(token) - integer(base) >= TOKENS_PER_CHUNK) or (i >= strLength)
            set char = textChars[i]
            
            //*  Check for \n or \r\n or |n
            if (char == "\n") or (char == "\r" and textChars[i + 1] == "\n") or (char=="|" and textChars[i + 1]=="n") then
                set token.tokenType = TOKEN_TYPE_NEWLINE
                if (char != "\n") then
                    set i = i + 1
                endif
            //*  Check for color start and color code. 
            elseif (char=="|") and (textChars[i + 1] == "c") and (strLength - i >= 10) and (IsHexadecimal(i + 2)) then
                set token.tokenType = TOKEN_TYPE_COLOR
                set token.color = ARGB.create(Hex2Dec[StringHash(textChars[i + 2] + textChars[i + 3])], Hex2Dec[StringHash(textChars[i + 4] + textChars[i + 5])], Hex2Dec[StringHash(textChars[i + 6] + textChars[i + 7])], Hex2Dec[StringHash(textChars[i + 8] + textChars[i + 9])])
                set i = i + 9
            //*  Check for color end
            elseif (char=="|") and (textChars[i + 1] == "r") then
                set token.tokenType = TOKEN_TYPE_COLOREND
                set i = i + 1
            //*  Check for image start, path and end.
            elseif (char == "|") and (textChars[i + 1] == "i") then
                set token.tokenType = TOKEN_TYPE_IMAGE
                set token.value = ""
                set i = i + 2
                loop
                    exitwhen (textChars[i] == "|" and textChars[i + 1] == "i") or (i >= strLength)
                    set token.value = token.value + textChars[i]
                    set i = i + 1
                endloop
                set i = i + 1
            //*  Otherwise it is a normal ascii char.
            else
                set token.tokenType = TOKEN_TYPE_NORMAL
                set token.value = char
            endif
            set token = token + 1
            set i = i + 1
        endloop
        set TextToken.current = token
        set currentLength = i
    endfunction
    
    private function LayoutText takes ARGB backgroundColor, font textFont, real lineHeight returns nothing
        local TextToken base = TextToken.current
        local TextToken token = base
        local real width
        loop
            exitwhen (integer(token) - integer(base) >= TOKENS_PER_CHUNK) or (integer(token) >= tokenAmount)
            
            if (token.tokenType == TOKEN_TYPE_NEWLINE) then
                if (lineWidth[currentLine] > maxLineWidth) or (currentLine == 0) then
                    set maxLineWidth = lineWidth[currentLine]
                endif
                set currentLine = currentLine + 1
                set lineWidth[currentLine] = 0
            elseif (token.tokenType == TOKEN_TYPE_COLOR) then
                set currentColor = token.color
                set defaultColor = false
            elseif (token.tokenType == TOKEN_TYPE_COLOREND) then
                set currentColor = backgroundColor
                set defaultColor = true
            elseif (token.tokenType == TOKEN_TYPE_IMAGE) or (token.tokenType == TOKEN_TYPE_NORMAL) then
                set token.color          = currentColor
                set token.isDefaultColor = defaultColor
                set token.line           = currentLine
                if (token.tokenType == TOKEN_TYPE_IMAGE) then
                    set width = (textFont.getImage(token.value).width*TEXT_SIZE_TO_IMAGE_SIZE*lineHeight/DEFAULT_IMAGE_SIZE)
                else
                    set width = (textFont.getChar(token.value).width*TEXT_SIZE_TO_IMAGE_SIZE*lineHeight/DEFAULT_IMAGE_SIZE)
                endif
                set token.posY = (currentLine)*(lineHeight + 1.0)*TEXT_SIZE_TO_IMAGE_SIZE
                set token.posX = lineWidth[currentLine]
                
                set lineWidth[currentLine] = lineWidth[currentLine] + width
            endif
            
            set token = token + 1
        endloop
        
        set TextToken.current = token
    endfunction
    
    private function DisplayText takes real lineHeight, real bonus, real z, boolean visible, font fontType, Char chars returns nothing
        local TextToken token = TextToken.current
        local real x
        local real y
        local Char char
       // call BJDebugMsg(R2S(bonus))
        loop
            exitwhen (integer(token) - integer(TextToken.current) >= TOKENS_PER_CHUNK) or (integer(token) >= tokenAmount)
            if (token.tokenType == TOKEN_TYPE_IMAGE) or (token.tokenType == TOKEN_TYPE_NORMAL) then
                set x = sourceX + token.posX + (bonus*(maxLineWidth - lineWidth[token.line]))
                set y = sourceY - token.posY
                if (token.tokenType == TOKEN_TYPE_IMAGE) then 
                    set char = chars.createImage(fontType, token.value, x, y, z, lineHeight)
                else
                    set char = chars.createChar(fontType, token.value, x, y, z, lineHeight)
                endif
                set char.colorize = token.isDefaultColor
                call char.setColor(token.color)
                set char.show = visible
                call SetImageRenderAlways(char.img, visible)
                set currentLength = currentLength + 1
            endif
            set token = token + 1
        endloop
        set TextToken.current = token
    endfunction
//**
//*  Struct textsplat:
//*  =================
    struct textsplat
        private static constant timer TMR = CreateTimer()
        //*  Linked list data structure.
        private static integer array next
        private static integer array prev
        private static boolean array inList
    //**
    //*  Members:
    //*  ========
        private Char    chars
        private integer ref
        //*  Fields you may read.
        readonly integer charCount
        readonly real    x
        readonly real    y
        readonly real    z
        readonly real    dX
        readonly real    dY
        readonly real    dZ
        readonly real    width
        readonly real    height
        readonly boolean suspended
        readonly boolean visible
        readonly string  text
        readonly ARGB    color
                 //*  Fields you may manipulate directly.
                 font    fontType
                 real    age
                 real    lifespan
                 real    fadepoint
                 boolean permanent
        
        private method clear takes nothing returns nothing
            local Char char = chars.first
            loop
                exitwhen (0 == char)
                if (char.img != null) then
                    call ReleaseImage(char.img)
                    set char.img = null
                endif
                set char = char.next
            endloop
            call chars.clear()
            set charCount = 0
        endmethod
        
        private method remove takes nothing returns nothing
            if (inList[this]) then
                set inList[this] = false
                set next[prev[this]] = next[this]
                set prev[next[this]] = prev[this]
                if (0 == next[0]) then
                    call PauseTimer(TMR)
                endif
            endif  
        endmethod
        
        method destroy takes nothing returns nothing
            call clear()
            call remove()     
            if (ref <= 0) then
                call chars.destroy()
                call deallocate()
            endif
        endmethod
        
        method lock takes nothing returns nothing
            set ref = ref + 1
        endmethod
        
        method unlock takes nothing returns nothing
            set ref = ref - 1
            if (ref <= 0) then
                call destroy()
            endif
        endmethod
        
        private static method onPeriodic takes nothing returns nothing
            local thistype this = next[0]
            local Char     char 
            local boolean  hasZ
            local real     val
            loop
                exitwhen (0 == this)
                set char = chars.first
                //*  Update alpha channel.
                set val  = 1.
                if not (permanent) then
                    set age = age + ACCURACY
                    if (age >= lifespan) then
                        call destroy()
                        set char = 0//*  Does not enter the loop.
                    elseif (age > fadepoint) then
                        set val = 1. - (age - fadepoint)/(lifespan - fadepoint)
                    endif
                endif
                if dX != 0 or dY != 0 or dZ != 0 then
                    //*  Update position.
                    set x    = x + dX
                    set y    = y + dY
                    set z    = z + dZ
                    set hasZ = (0. != dZ)
                    loop
                        exitwhen (0 == char)
                        set char.x = char.x + dX
                        set char.y = char.y + dY
                        //*  Unlike units, image handles may move out of WorldBounds without producing issues.
                        call SetImagePosition(char.img, char.x, char.y, 0.)
                        if (hasZ) then
                            set char.z = char.z + dZ
                            call SetImageConstantHeight(char.img, true, char.z + GetLocZ(char.x, char.y))
                        endif
                        call SetImageColor(char.img, char.red, char.green, char.blue, R2I(char.alpha*val))
                        set char = char.next
                    endloop
                endif
                set this = next[this]
            endloop
        endmethod
        
        private method enqueue takes nothing returns nothing
            if not (inList[this]) then
                set inList[this] = true
                set next[this] = 0
                set prev[this] = prev[0]
                set next[prev[0]] = this
                set prev[0] = this
                if (0 == prev[this]) then
                    call TimerStart(TMR, ACCURACY, true, function thistype.onPeriodic)
                endif
            endif
        endmethod
        
        method setText takes string s, real h, integer aligntype returns nothing
            set strLength = StringLength(s)
            set currentLine = 0
            set currentColor = color
            set defaultColor = true
            set maxLineWidth = 0
            call clear()//*  First clean the previous text.
            call SplitString(s)//*  Split string into single chars.
            //*  Tokenize.
            set lineWidth[0] = 0
            set currentLength = 0
            set TextToken.current = 0
            loop
                exitwhen (currentLength >= strLength) 
                call ForForce(bj_FORCE_PLAYER[0], function TokenizeText)
            endloop
            //*  Layout.
            set tokenAmount = TextToken.current
            set TextToken.current = 0
            loop
                exitwhen integer(TextToken.current) >= tokenAmount
                call LayoutText.evaluate(color, fontType, h)
            endloop
            if (currentLine == 0) or (lineWidth[currentLine] > maxLineWidth) then
                set maxLineWidth = lineWidth[currentLine]
            endif
            //*  Display.
            set sourceX = x
            set sourceY = y// - currentLine*h*TEXT_SIZE_TO_IMAGE_SIZE
            set currentLength = 0
            set TextToken.current = 0
            loop
                exitwhen integer(TextToken.current) >= tokenAmount
                call DisplayText.evaluate(h, aligntype*.5, z, visible, fontType, chars)
            endloop
            
            set charCount = currentLength
            set text = s
            set width = maxLineWidth
            set height = (currentLine + 1)*h*TEXT_SIZE_TO_IMAGE_SIZE
        endmethod
        
        method setVelocity takes real xvel, real yvel, real zvel returns nothing
            set dX = xvel*ACCURACY
            set dY = yvel*ACCURACY
            set dZ = zvel*ACCURACY
        endmethod
        
        method setColor takes integer red, integer green, integer blue, integer alpha returns nothing
            local Char char = chars.first
            local integer val = alpha 
            if (age > fadepoint) and (lifespan != fadepoint) and not (permanent) then
                set val = R2I((1 - (age - fadepoint)/(lifespan - fadepoint))*alpha)
            endif
            set color = ARGB.create(alpha, red, green, blue)
            loop
                exitwhen (0 == char)
                if (char.colorize) then
                    set char.red   = red
                    set char.green = green
                    set char.blue  = blue
                    set char.alpha = alpha
                    call SetImageColor(char.img, red, green, blue, val)
                endif
                set char = char.next
            endloop
        endmethod
        
        method setPosition takes real posX, real posY, real posZ returns nothing
            local real newX = posX - x
            local real newY = posY - y
            local real newZ = posZ - z
            local Char char = chars.first
            loop
                exitwhen (0 == char)
                set char.x = char.x + newX
                set char.y = char.y + newY
                set char.z = char.z + newZ
                call SetImagePosition(char.img, char.x, char.y, 0)
                call SetImageConstantHeight(char.img, true, char.z + GetLocZ(char.x, char.y))
                set char = char.next
            endloop
            set x = posX
            set y = posY
            set z = posZ
        endmethod
        
        method setPosUnit takes unit u, real z returns nothing
            call setPosition(GetUnitX(u), GetUnitY(u), z)
        endmethod
        
        method setSuspended takes boolean flag returns nothing
            set suspended = flag
            if (flag) then
                call remove()
            else
                call enqueue()
            endif
        endmethod
        
        method setVisible takes boolean flag returns nothing
            local Char char = chars.first
            set visible = flag
            loop
                exitwhen (0 == char)
                set char.show = flag
                call SetImageRenderAlways(char.img, flag)
                set char = char.next
            endloop
        endmethod
        
        static method create takes font f returns thistype
            local thistype this = thistype.allocate()
            set fontType  = f
            set color     = DEFAULT_COLOR
            set visible   = true
            set permanent = true
            set suspended = false
            set chars     = Char.create()//*  Queue.
            //*  Reset position and fading members.
            set dX        = 0.
            set dY        = 0.
            set dZ        = 0.
            set x         = 0.
            set y         = 0.
            set z         = 0.
            set age       = 0.
            set fadepoint = 0.
            set lifespan  = 0.
            set width     = 0.
            set height    = 0.
            set ref       = 0
            //*  Add to iterating textsplats.
            call enqueue()
            return this
        endmethod
    endstruct
    
    function CreateTextSplat takes font fontType returns textsplat
        return textsplat.create(fontType)
    endfunction
    function DestroyTextSplat takes textsplat t returns nothing
        call t.destroy()
    endfunction
    function SetTextSplatFont takes textsplat t, font new returns nothing
        set t.fontType = new
    endfunction
    function SetTextSplatAge takes textsplat t, real value returns nothing
        set t.age = value
    endfunction
    function SetTextSplatColor takes textsplat t, integer red, integer green, integer blue, integer alpha returns nothing
        call t.setColor(red, green, blue, alpha)
    endfunction
    function SetTextSplatFadepoint takes textsplat t, real value returns nothing
        set t.fadepoint = value
    endfunction
    function SetTextSplatLifespan takes textsplat t, real value returns nothing
        set t.lifespan = value
    endfunction
    function SetTextSplatPermanent takes textsplat t, boolean flag returns nothing
        set t.permanent = flag
    endfunction
    function SetTextSplatPos takes textsplat t, real x, real y, real heightOffset returns nothing
        call t.setPosition(x, y, heightOffset)
    endfunction
    function SetTextSplatPosUnit takes textsplat t, unit whichUnit, real heightOffset returns nothing
        call t.setPosUnit(whichUnit, heightOffset)
    endfunction
    function SetTextSplatSuspended takes textsplat t, boolean flag returns nothing
        call t.setSuspended(flag)
    endfunction
    function SetTextSplatText takes textsplat t, string s, real height returns nothing
        call t.setText(s, height, TEXTSPLAT_TEXT_ALIGN_CENTER)
    endfunction
    function SetTextSplatVelocity takes textsplat t, real xvel, real yvel returns nothing
        call t.setVelocity(xvel, yvel, 0)
    endfunction
    function SetTextSplatVisibility takes textsplat t, boolean flag returns nothing
        call t.setVisible(flag)
    endfunction
//**
//*  Hex to Dec:
//*  ===========
    //! textmacro Hex2DecUpper_Macro takes L
        set Hex2Dec[StringHash("$L$0")]=0x$L$0
        set Hex2Dec[StringHash("$L$1")]=0x$L$1
        set Hex2Dec[StringHash("$L$2")]=0x$L$2
        set Hex2Dec[StringHash("$L$3")]=0x$L$3
        set Hex2Dec[StringHash("$L$4")]=0x$L$4
        set Hex2Dec[StringHash("$L$5")]=0x$L$5
        set Hex2Dec[StringHash("$L$6")]=0x$L$6
        set Hex2Dec[StringHash("$L$7")]=0x$L$7
        set Hex2Dec[StringHash("$L$8")]=0x$L$8
        set Hex2Dec[StringHash("$L$9")]=0x$L$9
        set Hex2Dec[StringHash("$L$A")]=0x$L$A
        set Hex2Dec[StringHash("$L$B")]=0x$L$B
        set Hex2Dec[StringHash("$L$C")]=0x$L$C
        set Hex2Dec[StringHash("$L$D")]=0x$L$D
        set Hex2Dec[StringHash("$L$E")]=0x$L$E
        set Hex2Dec[StringHash("$L$F")]=0x$L$F
    //! endtextmacro
    
    private module InitHex2Dec
        private static method onInit takes nothing returns nothing
            set Hex2Dec = Table.create()
            set IsHex   = Table.create()
    
            //! runtextmacro Hex2DecUpper_Macro("0")
            //! runtextmacro Hex2DecUpper_Macro("1")
            //! runtextmacro Hex2DecUpper_Macro("2")
            //! runtextmacro Hex2DecUpper_Macro("3")
            //! runtextmacro Hex2DecUpper_Macro("4")
            //! runtextmacro Hex2DecUpper_Macro("5")
            //! runtextmacro Hex2DecUpper_Macro("6")
            //! runtextmacro Hex2DecUpper_Macro("7")
            //! runtextmacro Hex2DecUpper_Macro("8")
            //! runtextmacro Hex2DecUpper_Macro("9")
            //! runtextmacro Hex2DecUpper_Macro("A")
            //! runtextmacro Hex2DecUpper_Macro("B")
            //! runtextmacro Hex2DecUpper_Macro("C")
            //! runtextmacro Hex2DecUpper_Macro("D")
            //! runtextmacro Hex2DecUpper_Macro("E")
            //! runtextmacro Hex2DecUpper_Macro("F")
            set IsHex[StringHash("0")]=1
            set IsHex[StringHash("1")]=1
            set IsHex[StringHash("2")]=1
            set IsHex[StringHash("3")]=1
            set IsHex[StringHash("4")]=1
            set IsHex[StringHash("5")]=1
            set IsHex[StringHash("6")]=1
            set IsHex[StringHash("7")]=1
            set IsHex[StringHash("8")]=1
            set IsHex[StringHash("9")]=1
            set IsHex[StringHash("A")]=1
            set IsHex[StringHash("B")]=1
            set IsHex[StringHash("C")]=1
            set IsHex[StringHash("D")]=1
            set IsHex[StringHash("E")]=1
            set IsHex[StringHash("F")]=1
        endmethod
    endmodule
    
    private struct Inits extends array
        implement InitHex2Dec
    endstruct
    
endlibrary

library_once TextSplat uses TextSplat2 
endlibrary