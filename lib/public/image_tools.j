// Written by BPower.
library ImageTools /*v2.0
*************************************************************************************
*
*   For your image needs.
*
*   Strictly speaking it provides two wrapper function for CreateImage & DestroyImage,
*   named function NewImage & function ReleaseImage.
*
*   You always want to use these wrapper functions! Why so? See required know-how. 
*  
*************************************************************************************
*
*   Required know-how [ Image extends handles for Dummies ]:
*   -----------------
*     
*       1. An invalid filepath crashes the game.
*       2. An invalid image type crashes the game.
*       3. DestroyImage native on an invalid image handle crashes the game.
*
*       ImageTools prevents you from these fatal errors
*       plus prints out debug messages, so you can quickly fix your code.
*
*       Hint: A very nice image tutorial link - [url]http://www.wc3c.net/showthread.php?t=107737[/url] 
*
*************************************************************************************
*      
*       To Deaod
*       -----------------------
*
*           For the original ImageUtils library ( [url]http://www.wc3c.net/showthread.php?t=107707[/url] )
*
*       To Bribe
*       -----------------------
*
*           For Table
*
*       To Vexorian 
*       -----------------------
*
*           For ARGB
*
*************************************************************************************
*
*   */ uses /*
*  
*       */ Table         /* [url]http://www.hiveworkshop.com/forums/jass-resources-412/snippet-new-table-188084/[/url]
*
************************************************************************************
*
*   1. Import instruction
*   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*       Copy the ImageTools script and library Table into your map.

*   2. API
*   ¯¯¯¯¯¯
*       function NewImage takes string file, real sizeX, real sizeY, real posX, real posY, real posZ, integer imageType returns image
*           - Wrapper to the CreateImage native.
*           - Does not crash the game, if the created image handle is invalid.
*
*       function ReleaseImage takes image whichImage retuns nothing
*           - Wrapper to the DestroyImage native
*           - Does not crash the game if whichImage is invalid.
*           - Does not crash the game if whichImage is the first ever created image in the map. 
*
*       function CreateImageCenter takes string file, real sizeX, real sizeY, real centerX, real centerY, real posZ, integer imageType returns image
*           - Wrapper to the NewImage. It creates the image centered at centerX, centerY equal to other handle objects ( i.e. units ).
*
*   3. Configuration
*   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*       You don't have to setup anything. 
*/

    globals
        /**
        *   The following are valid image types 
        *   sorted from highest to lowest layer:
        */
        constant integer IMAGE_TYPE_SELECTION      = 1// above all other image types.
        constant integer IMAGE_TYPE_OCCLUSION_MASK = 3// above image type 2 and 4
        constant integer IMAGE_TYPE_INDICATOR      = 2// above image type 4
        constant integer IMAGE_TYPE_UBERSPLAT      = 4// lowest layer. Tinting affected by time of day
                                                      // and is drawn below fog of war.
            
        /**
        *   Those two are image types options in GUI's "Image - Create" wrapper of CreateImageBJ.
        *   Both are invalid image types and should not be used in any case.
        *   While an image with IMAGE_TYPE_SHADOW instantly crashes the game,
        *   an image using IMAGE_TYPE_TOPMOST will simply not be render-able.
        *   The game season however will continue normally.
        */
        
        constant integer IMAGE_TYPE_SHADOW         = 0// Will create an invalid image handle with an handle id of -1.
        constant integer IMAGE_TYPE_TOPMOST        = 5// Will create an invalid image handle, which can't be rendered.
                
    
        /**
        *   If an image handle is invalid, it gets the handle id -1. 
        *   Once you are using this handle somewhere, Warcraft III crashes,
        *   hence ALWAYS create an image handle via function NewImage.
        */
        private constant integer INVALID_IMAGE_ID   = -1 
        
        /**
        *   When using ARGB, this is the default color set on Image.create()
        */
        
        
        private constant boolean SHOW_MSG = false
    endglobals

    static if DEBUG_MODE then
        private function DebugMsg takes string s returns nothing
            static if SHOW_MSG then
                call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "|cffff0000IMAGE UTILS ERROR:|r\n    " + "|cff99b4d1" + "[" + s + "]|r" ) 
            endif
        endfunction
    endif
    
    globals
        private Table table = 0
    endglobals
    
    function NewImage takes string file, real sizeX, real sizeY, real posX, real posY, real posZ, integer imageType returns image
        local image i = CreateImage(file, sizeX, sizeY, 0, posX - 0.5*sizeX, posY - 0.5*sizeY, posZ, 0, 0, 0, imageType)
        if (0 > GetHandleId(i)) then
            debug if (imageType < IMAGE_TYPE_SELECTION) or (imageType > IMAGE_TYPE_UBERSPLAT) then 
                debug call DebugMsg("function NewImage: Invalid image type [" + I2S(imageType) + "] for:  " + file)
            debug else
                debug call DebugMsg("function NewImage: Can't find string path in data: " + file) 
            debug endif
            return CreateImage("UI\\BlackImage.blp", sizeX, sizeY, 0, posX - 0.5*sizeX, posY - 0.5*sizeY, posZ, 0, 0, 0, imageType)
        else
            set table.boolean[GetHandleId(i)] = true
            return i
        endif
        return i
    endfunction
    
    function ReleaseImage takes image i returns nothing
        local integer id = GetHandleId(i)
        if (id > 0) and (table.boolean.has(id)) then
            call table.boolean.remove(id)
            call DestroyImage(i)
        debug elseif (id > 0) then
            debug call DebugMsg("function ReleaseImage: Attempt to double destroy an image handle: [" + I2S(id) + "]!" )
            debug call DebugMsg("function ReleaseImage: Or even worse, you created an image without using NewImage!" )
        debug else
            debug call DebugMsg("function ReleaseImage: Attempt to destroy an invalid image handle! ( null )")        
        endif
    endfunction
    
    function CreateImageCenter takes string file, real sizeX, real sizeY, real centerX, real centerY, real centerZ, integer imageType returns image
        return NewImage(file, sizeX, sizeY, centerX - sizeX*.5, centerY - sizeY*.5, centerZ, imageType)
    endfunction
    
    private module InitImageTools
        private static method onInit takes nothing returns nothing
            set table = Table.create()
        endmethod
    endmodule
    private struct I extends array
        implement InitImageTools
    endstruct 
    
    private struct F extends array
        private image img
        private integer r
        private integer g
        private integer b
        private real duration
        private real t
        
        implement CTLExpire
            set this.t = this.t - CTL_TIMEOUT
            if this.t > 0 then
                call SetImageColor(this.img, this.r, this.g, this.b, R2I(255*this.t/this.duration))
            else
                call ReleaseImage(this.img)
                set this.img = null
                call this.destroy()
            endif
        implement CTLEnd
        
        static method fade takes image i, integer red, integer green, integer blue, real duration returns nothing
            local thistype this = thistype.create()
            set this.img = i
            set this.r = red
            set this.g = green
            set this.b = blue
            set this.duration = duration
            set this.t = duration
        endmethod
    endstruct
    
    function FadeImage takes image i, integer red, integer green, integer blue, real duration returns nothing
        call F.fade(i, red, green, blue, duration)
    endfunction
    //! runtextmacro optional IMAGE_TOOLS_IMPORT_STRUCT_CODE()
    
endlibrary