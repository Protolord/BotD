//**
//*    Credits:
//*        - Nestharus  ( Ascii, ErrorMessage )
//*        - Bribe      ( Ascii, Table )
//*        - PitzerMike ( original TextSplat system )
//*        - Deaod      ( TextSplat system of the second generation, Font )
//**
//* Written by BPower
library Font/*v1.0
*************************************************************************************
*
*   Creates custom fonts in Warcraft III. 
*   Fonts are used to translate strings into a sequence of images.
*
*   A custom fonts may contain every character of the Ascii chart, 
*   as well as file paths to textures inside your map. 
*
*   Has full backwards compatibility to Deaods Font library.
*
*************************************************************************************
*          
*   Creating custom fonts: 
*   ======================
*       Refer to wc3c.net/showthread.php?t=87798
*       You can change the file paths to your needs, but don't forget to copy
*       the width of each individual chars from the .j file that the program creates.
*
*************************************************************************************
*
*   */ requires /*
*  
*       */ Ascii /*                 hiveworkshop.com/forums/jass-resources-412/snippet-ascii-190746/
*       */ Table /*                 hiveworkshop.com/forums/jass-resources-412/snippet-new-table-188084/
*       */ optional ErrorMessage /* github.com/nestharus/JASS/tree/master/jass/Systems/ErrorMessage
*
************************************************************************************ 
*
*   Import instruction:
*   ===================
*       Copy & paste library Font into your map.
*       Make sure your map also has library Table and library Ascii.
*       Otherwise copy those two required libraries aswell.
*
*   API:
*   ====
*   struct Font extends array    
*   
*       static method create takes Font parentFont returns Font
*          - A parent font is accessed, if a char or file is not available in this font.
*
*       method addChar takes string char, real widthInPixel, string filePath returns nothing
*          - adds a new char to the font. The char must be part of the Ascii chart.
*       
*       method getChar takes string char returns FontChar
*           - FontChar fields are "width" and "path".
*
*       method addImage takes string tag, real widthInPixel, string filePath returns nothing
*           - adds an image to the font. Images are fully compatible with parents.
*           - to access an image you have to use myFont.getImage(tag)
*           - tags are case-insensitive ( myTag is equal to MYtAg ) 
*
*       method getImage takes string tag returns FontImage
*           - pass in the tag defined in addImage() to access a FontImage
*           - FontImage fields are "width" and "path"
*/
    globals
        //*  Struct font has an instance limit of 31. 
        //* Only if you need more than 31 fonts in your map set MORE to true.
        private constant boolean MORE = false
    endglobals
    
    //**
    //*  Naming convention:
    //*  ==================
    //*  Due to backwards compatibility to Deaods Font library
    //* I didn't use medial capitalization. 
    //* Personally I prefer struct names using PascalCase.
    private struct fontchar extends array
        private static integer alloc = 0
        string path
        real   width
        
        static method create takes string strPath, real strWidth returns thistype
            local thistype this = thistype.alloc + 1
            set thistype.alloc  = integer(this)
            set path            = strPath
            set width           = strWidth
            return this
        endmethod
    endstruct
    
    private struct fontimage extends array
        private static integer alloc = 0
        string path
        real   width
        
        static method create takes string strPath, real strWidth returns thistype
            local thistype this = thistype.alloc + 1
            set thistype.alloc  = integer(this)
            set path            = strPath
            set width           = strWidth
            return this
        endmethod
    endstruct
    
    static if MORE then
        private module InitFontTable
            private static method onInit takes nothing returns nothing
                set thistype.chars = Table.create()
            endmethod
        endmodule
    endif
    
    struct font extends array
        private static integer alloc = 0
        static if MORE then
            private static Table chars 
            implement optional InitFontTable
        else
            private static integer array chars//* (this - 1)*256
        endif
        
        private thistype parent 
        private Table    imgs
        
        method getChar takes string char returns fontchar
            local integer fc = chars[(this - 1)*256 + Char2Ascii(char)] 
            if (fc != 0) then
                return fc
            elseif (0 != parent) then
                return parent.getChar(char)
            endif
            
            static if LIBRARY_ErrorMessage then
                debug call ThrowWarning(true, "Font", "getChar", "char", this, "Char [" + char + "] is not available in this font!")
            endif
            return 0
        endmethod
        
        static method charWidth takes string char returns real
            local fontchar fc = chars[(TREBUCHET_MS - 1)*256 + Char2Ascii(char)] 
            if (fc != 0) then
                return fc.width
            elseif (0 != TREBUCHET_MS.parent) then
                return TREBUCHET_MS.parent.getChar(char).width
            endif
            return 0.0
        endmethod
        
        method addChar takes string char, real width, string path returns nothing
            local integer index = (this - 1)*256 + Char2Ascii(char)
            local fontchar fc   = chars[index]
            //*
            static if LIBRARY_ErrorMessage then
                debug call ThrowError((index - ((this - 1)*256) <= 0), "Font", "addChar", "ascii", this, "Char [" + char + "] is not part of the Ascii chart!")
            endif
            
            if (fc == 0) then
                set chars[index] = fontchar.create(path, width)
            else
                set fc.path  = path
                set fc.width = width
            endif
        endmethod
        
        method getImage takes string file returns fontimage
            local integer fi = imgs[StringHash(file)]
            if (0 != fi) then
                return fi
            elseif (0 != parent) then
                return parent.getImage(file)
            endif
            
            static if LIBRARY_ErrorMessage then
                debug call ThrowWarning(true, "Font", "getImage", "file", this, "File [" + file + "] is not available in this font!")
            endif
            return 0
        endmethod
        
        //*  To works with both Tables I didn't use t.exists(index) nor t.has(index).
        //* Luckily hashtables return 0 for not existant entries.
        method addImage takes string file, real width, string path returns nothing
            local integer index = StringHash(file)
            local fontimage img 
            if (imgs[index] == 0) then
                set imgs[index] = fontimage.create(path, width)
            else
                set img       = imgs[index]
                set img.path  = path
                set img.width = width
            endif
        endmethod
        
        static method create takes thistype parentFont returns thistype
            local thistype this = thistype.alloc + 1
            static if LIBRARY_ErrorMessage and not MORE then
                debug call ThrowError((this == 32), "Font", "create", "thistype", this, "Overflow. Go to library Font and set boolean MORE to true!")
            endif
            set thistype.alloc = integer(this)
            set parent         = parentFont
            set imgs           = Table.create()
            return this
        endmethod
        
        //*  Backwards compatibility to Deaods Font.
        method operator [] takes string char returns fontchar
            return getChar(char)
        endmethod
        
    endstruct
    
endlibrary