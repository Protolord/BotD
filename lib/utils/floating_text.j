library FloatingText uses TextSplat2

/*
    function FloatingTextSplat(string, unit, time)
        - Display textsplat at a unit's position for a certain duration.

    function FloatingTextTag(string, unit, time)
        - Display texttag at a unit's position for a certain duration.
*/

    globals
        private constant real OFFSET = 10
        private constant real HEIGHT = 80
        private texttag temp_texttag
    endglobals

    struct FloatingText extends array
        public static real splatVelocity = 50.0
        public static real splatSize = 7.0
        public static real splatExtraHeight = 0.0
        public static real splatTime = 1.0

        public static real tagVelocity = 0.05
        public static real tagSize = 0.0225
        public static real tagExtraHeight = 0.0
        public static real tagTime = 1.0

        static method resetSplatProperties takes nothing returns nothing
            set thistype.splatTime = 1.0
            set thistype.splatVelocity = 50.0
            set thistype.splatSize = 7.0
            set thistype.splatExtraHeight = 0.0
        endmethod

        static method setSplatProperties takes real timeout returns nothing
            if timeout == 0.125 then
                set FloatingText.splatTime = 0.5
                set FloatingText.splatVelocity = 175.0
                set FloatingText.splatSize = 5.75
            elseif timeout == 0.25 then
                set FloatingText.splatTime = 0.75
                set FloatingText.splatVelocity = 125.0
                set FloatingText.splatSize = 6.0
            endif
        endmethod
    endstruct

    function FloatingTextTag takes string s, unit u returns texttag
        local texttag text = CreateTextTag()
        call SetTextTagPos(text, GetUnitX(u) + GetRandomReal(-OFFSET, OFFSET), GetUnitY(u) + GetRandomReal(-OFFSET, OFFSET), GetUnitFlyHeight(u) + HEIGHT)
        call SetTextTagText(text, s, FloatingText.tagSize)
        call SetTextTagVelocity(text, 0, FloatingText.tagVelocity)
        call SetTextTagPermanent(text, false)
        call SetTextTagFadepoint(text, FloatingText.tagTime)
        call SetTextTagLifespan(text, FloatingText.tagTime + 1.5)
        set temp_texttag = text
        set text = null
        return temp_texttag
    endfunction

    function FloatingTextSplat takes string s, unit u returns textsplat
        local textsplat text = textsplat.create(TREBUCHET_MS)
        call text.setPosition(GetUnitX(u) + GetRandomReal(-OFFSET, OFFSET), GetUnitY(u) + GetRandomReal(-OFFSET, OFFSET), GetUnitFlyHeight(u) + HEIGHT + FloatingText.splatExtraHeight)
        call text.setText(s, FloatingText.splatSize, TEXTSPLAT_TEXT_ALIGN_CENTER)
        call text.setVelocity(0, FloatingText.splatVelocity, 10)
        set text.fadepoint = FloatingText.splatTime
        set text.lifespan = FloatingText.splatTime + 1.5
        set text.permanent = false
        return text
    endfunction

endlibrary