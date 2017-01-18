library StringSize /* v2.1.0.0 
********************************************************************
*
*  This library can calculate the width of a string in pixels.
*  Useful for word wrapping in multiboards and texttags. 
*
*  The sizes might not be 100% accurate but are far more reliable
*  than using just StringLength().
*  Note that actual sizes may very depending on resolution.
*
*********************************************************************
*
*   */uses/*
*   
*       */ Ascii /*       http://www.hiveworkshop.com/forums/jass-functions-413/snippet-ascii-190746/
*
*********************************************************************
*
*  function MeasureString takes string source returns real
*
*      - Measures the string and returns the calculated width.
*
*  function MeasureCharacter takes string char returns real
*
*      - Returns the width of an individual character.
*
*********************************************************************
*
*  struct StringSize
*
*      static method measure takes string source returns real
*
*       static method measureChar takes string char returns real
*
*********************************************************************
*
*  Credits
*    - Bob666 aka N-a-z-g-u-l for the character widths.
*    - Tukki for pointing out an error in the system.    
*
*********************************************************************/ 

    globals
        private real array size
    endglobals

    private module StringSizeModule

        static method onInit takes nothing returns nothing
            set size[124]  =  3
            set size[39]   =  4
            set size[58]   =  4
            set size[59]   =  4
            set size[46]   =  4
            set size[44]   =  4
            set size[49]   =  5
            set size[105]  =  5
            set size[33]   =  5
            set size[108]  =  6
            set size[73]   =  6
            set size[106]  =  6
            set size[40]   =  6
            set size[91]   =  6
            set size[93]   =  6
            set size[123]  =  6
            set size[125]  =  6
            set size[32]   =  7
            set size[34]   =  7
            set size[41]   =  7
            set size[74]   =  7
            set size[114]  =  8
            set size[102]  =  8
            set size[96]   =  8
            set size[116]  =  9
            set size[45]   =  9
            set size[92]   =  9
            set size[42]   =  9
            set size[70]   = 10
            set size[115]  = 11
            set size[47]   = 11
            set size[63]   = 11
            set size[69]   = 12
            set size[76]   = 12
            set size[55]   = 12
            set size[43]   = 12
            set size[61]   = 12
            set size[60]   = 12
            set size[62]   = 12
            set size[36]   = 12
            set size[97]   = 12
            set size[107]  = 13
            set size[84]   = 13
            set size[99]   = 13
            set size[83]   = 13
            set size[110]  = 13
            set size[122]  = 13
            set size[80]   = 13
            set size[51]   = 13
            set size[53]   = 13
            set size[95]   = 13
            set size[126]  = 13
            set size[94]   = 13
            set size[98]   = 14
            set size[66]   = 14
            set size[54]   = 14
            set size[118]  = 14
            set size[101]  = 14
            set size[120]  = 14
            set size[121]  = 14
            set size[50]   = 14
            set size[57]   = 14
            set size[104]  = 14
            set size[117]  = 14
            set size[111]  = 15
            set size[100]  = 15
            set size[48]   = 15
            set size[103]  = 15
            set size[56]   = 15
            set size[52]   = 15
            set size[113]  = 15
            set size[112]  = 15
            set size[115]  = 15
            set size[67]   = 16
            set size[82]   = 16
            set size[90]   = 16
            set size[86]   = 16
            set size[89]   = 16
            set size[68]   = 16
            set size[75]   = 16
            set size[85]   = 16
            set size[35]   = 16
            set size[78]   = 17
            set size[72]   = 17
            set size[37]   = 17
            set size[71]   = 18
            set size[88]   = 18
            set size[64]   = 18
            set size[65]   = 19
            set size[119]  = 20
            set size[79]   = 20
            set size[109]  = 21
            set size[81]   = 21
            set size[38]   = 21
            set size[77]   = 25
            set size[87]   = 26
        endmethod

    endmodule

    struct StringSize extends array

        static method measureChar takes string char returns real
            return size[Char2Ascii(char)]
        endmethod

        static method measure takes string s returns real
            local integer i = 0
            local integer l = StringLength(s)
            local real result = 0
            local string sub = ""
            if l == 0 then
                return 0.
            elseif l == 1 then
                return size[Char2Ascii(s)]
            endif
            loop
                exitwhen i >= l 
                set sub = SubString(s, i, i+1)
                if sub == "|" then
                    set sub = SubString(s, i+1, i+2)
                    if sub == "c" then
                        set i = i + 9
                    elseif sub == "r" then
                        set i = i + 1
                    else
                        set result = result + size[124]
                    endif
                else
                    set result = result + size[Char2Ascii(sub)]
                endif
                set i = i + 1
            endloop
            return result
        endmethod
        
        implement StringSizeModule
        
    endstruct 

    function MeasureString takes string s returns real
        return StringSize.measure(s)
    endfunction
 

    function MeasureCharacter takes string s returns real
        return StringSize.measureChar(s)
    endfunction

endlibrary
 


