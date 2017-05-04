library Heal uses FloatingText

/*
    Heal.unit(unit, amount, etherealFactor)
        - Heals the units with texttag displayed and ethereal status considered.     
*/

    struct Heal extends array
        
        private static Table self
        private static Table other

        static method unit takes unit source, unit target, real amount, real factor, boolean show returns nothing
            local real max = GetUnitState(target, UNIT_STATE_MAX_LIFE)
            local integer id = GetHandleId(source)
            local texttag text
            local real hp
            if IsUnitType(target, UNIT_TYPE_ETHEREAL) then
                set amount = factor*amount
            endif
            set hp = GetWidgetLife(target)
            if hp + amount >= max then
                set amount = max - hp
            endif
            call SetWidgetLife(target, hp + amount)
            if R2I(amount) > 0 and show then
                set text = FloatingTextTag("|cff00ff00+" + I2S(R2I(amount)), target, 1.5)
                if IsUnitEnemy(target, GetLocalPlayer()) or not IsUnitVisible(target, GetLocalPlayer()) then
                    call SetTextTagVisibility(text, false)
                endif
            endif
            if source == target then
                set thistype.self.real[id] = thistype.self.real[id] + amount
            else
                set thistype.other.real[id] = thistype.other.real[id] + amount
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            set thistype.self = Table.create()
            set thistype.other = Table.create()
        endmethod
        
    endstruct
    
endlibrary