library Heal uses FloatingText

/*
    Heal.unit(unit, amount, etherealFactor)
        - Heals the units with texttag displayed and ethereal status considered.     
*/

    struct Heal extends array
        
        static method unit takes unit u, real amount, real factor returns nothing
            local real max = GetUnitState(u, UNIT_STATE_MAX_LIFE)
            local texttag text
            local real hp
            if IsUnitType(u, UNIT_TYPE_ETHEREAL) then
                set amount = factor*amount
            endif
            set hp = GetWidgetLife(u)
            if hp + amount >= max then
                set amount = max - hp
            endif
            call SetWidgetLife(u, hp + amount)
            if R2I(amount) > 0 then
                set text = FloatingTextTag("|cff00ff00+" + I2S(R2I(amount)), u, 1.5)
                if IsUnitEnemy(u, GetLocalPlayer()) or not IsUnitVisible(u, GetLocalPlayer()) then
                    call SetTextTagVisibility(text, false)
                endif
            endif
        endmethod
        
    endstruct
    
endlibrary