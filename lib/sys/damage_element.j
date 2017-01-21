library DamageElement uses DamageEvent, FloatingText

/*
    Damage.element.apply(source, target, damageAmount, attackType, damageType, damageElement)
        - Applies damage that shows textsplat with element.
*/

    globals
        //Elements
        constant integer DAMAGE_ELEMENT_ARCANE = 1
        constant integer DAMAGE_ELEMENT_DARK = 2
        constant integer DAMAGE_ELEMENT_ELECTRIC = 3
        constant integer DAMAGE_ELEMENT_EARTH = 4
        constant integer DAMAGE_ELEMENT_FIRE = 5
        constant integer DAMAGE_ELEMENT_ICE = 6
        constant integer DAMAGE_ELEMENT_NORMAL = 7
        constant integer DAMAGE_ELEMENT_PLANT = 8
        constant integer DAMAGE_ELEMENT_POISON = 9
        constant integer DAMAGE_ELEMENT_SPIRIT = 10
        constant integer DAMAGE_ELEMENT_WATER = 11
    endglobals

    struct Element extends array
        
        private static unit source
        private static integer element
        private static string array path
        private static trigger trg
        readonly static boolean coded
        
        static method string takes integer element returns string
            return thistype.path[element]
        endmethod
            
        private static method onDamage takes nothing returns boolean
            if Damage.source == thistype.source then
                call FloatingTextSplat(thistype.path[thistype.element] + I2S(R2I(Damage.amount + 0.5)) + "|r", Damage.target, 1.0).setVisible(GetLocalPlayer() == GetOwningPlayer(Damage.source) and IsUnitVisible(Damage.target, GetLocalPlayer()))
            endif
            return false
        endmethod
            
        static method apply takes unit source, unit target, real damage, attacktype at, damagetype dt, integer element returns nothing
            set thistype.source = source
            set thistype.element = element
            set thistype.coded = true
            call EnableTrigger(thistype.trg)
            call UnitDamageTarget(source, target, damage, false, false, at, dt, null)
            call DisableTrigger(thistype.trg)
            set thistype.coded = false
            set thistype.source = null
            set thistype.element = 0
        endmethod
            
        private static method onInit takes nothing returns nothing
            set thistype.path[DAMAGE_ELEMENT_ARCANE] = "|iELEMENT_ARCANE|i|cfff85888"
            set thistype.path[DAMAGE_ELEMENT_DARK] = "|iELEMENT_DARK|i|cff9c2889"
            set thistype.path[DAMAGE_ELEMENT_EARTH] = "|iELEMENT_EARTH|i|cfff09140"
            set thistype.path[DAMAGE_ELEMENT_ELECTRIC] = "|iELEMENT_ELECTRIC|i|cff30ccf8"
            set thistype.path[DAMAGE_ELEMENT_FIRE] = "|iELEMENT_FIRE|i|cfff08030"
            set thistype.path[DAMAGE_ELEMENT_ICE] = "|iELEMENT_ICE|i|cff987e7e"
            set thistype.path[DAMAGE_ELEMENT_NORMAL] = "|iELEMENT_NORMAL|i|cffff0000"
            set thistype.path[DAMAGE_ELEMENT_PLANT] = "|iELEMENT_PLANT|i|cff50a43b"
            set thistype.path[DAMAGE_ELEMENT_POISON] = "|iELEMENT_POISON|i|cff7ca700"
            set thistype.path[DAMAGE_ELEMENT_SPIRIT] = "|iELEMENT_SPIRIT|i|cffe1e1e1"
            set thistype.path[DAMAGE_ELEMENT_WATER] = "|iELEMENT_WATER|i|cff5890f0"
            set thistype.trg = CreateTrigger()
            set thistype.coded = false
            call Damage.registerTrigger(thistype.trg)
            call TriggerAddCondition(thistype.trg, function thistype.onDamage)
            call DisableTrigger(thistype.trg)
        endmethod
    endstruct

    module DamageElement
        static Element element
        
        static method apply takes unit source, unit target, real amount, attacktype at, damagetype dt returns nothing
            call UnitDamageTarget(source, target, amount, true, false, at, dt, null)
        endmethod

        static method kill takes unit source, unit target returns nothing
            set Damage.enabled = false
            call SetWidgetLife(target, 0.406)
            call UnitDamageTarget(source, target, 0x0000FFFF, true, false, ATTACK_TYPE_CHAOS, DAMAGE_TYPE_UNIVERSAL, null)
            set Damage.enabled = true
        endmethod

    endmodule
    
endlibrary
