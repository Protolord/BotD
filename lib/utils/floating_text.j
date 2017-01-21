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
    
    function FloatingTextTag takes string s, unit u, real time returns texttag
        local texttag text = CreateTextTag()
        call SetTextTagPos(text, GetUnitX(u) + GetRandomReal(-OFFSET, OFFSET), GetUnitY(u) + GetRandomReal(-OFFSET, OFFSET), GetUnitFlyHeight(u) + HEIGHT)
        call SetTextTagText(text, s, 0.0225)
        call SetTextTagVelocity(text, 0, 0.05)
        call SetTextTagPermanent(text, false)
        call SetTextTagFadepoint(text, time)
        call SetTextTagLifespan(text, time + 1.5)
        set temp_texttag = text
        set text = null
        return temp_texttag
    endfunction

    function FloatingTextSplatEx takes string s, unit u, real time, real extraHeight returns textsplat
        local textsplat text = textsplat.create(TREBUCHET_MS)
        call text.setPosition(GetUnitX(u) + GetRandomReal(-OFFSET, OFFSET), GetUnitY(u) + GetRandomReal(-OFFSET, OFFSET), GetUnitFlyHeight(u) + HEIGHT + extraHeight)
        call text.setText(s, 8.0, TEXTSPLAT_TEXT_ALIGN_CENTER)
        call text.setVelocity(0, 50, 10)
        set text.fadepoint = time
        set text.lifespan = time + 1.5
        set text.permanent = false
        return text
    endfunction
    
    function FloatingTextSplat takes string s, unit u, real time returns textsplat
        local textsplat text = textsplat.create(TREBUCHET_MS)
        call text.setPosition(GetUnitX(u) + GetRandomReal(-OFFSET, OFFSET), GetUnitY(u) + GetRandomReal(-OFFSET, OFFSET), GetUnitFlyHeight(u) + HEIGHT)
        call text.setText(s, 8.0, TEXTSPLAT_TEXT_ALIGN_CENTER)
        call text.setVelocity(0, 50, 10)
        set text.fadepoint = time
        set text.lifespan = time + 1.5
        set text.permanent = false
        return text
    endfunction
    
endlibrary