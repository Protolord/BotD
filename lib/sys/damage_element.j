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
        constant integer DAMAGE_ELEMENT_LIGHT = 7
        constant integer DAMAGE_ELEMENT_NORMAL = 8
        constant integer DAMAGE_ELEMENT_PLANT = 9
        constant integer DAMAGE_ELEMENT_POISON = 10
        constant integer DAMAGE_ELEMENT_SPIRIT = 11
        constant integer DAMAGE_ELEMENT_WATER = 12
    endglobals

    struct Element extends array

        private static unit source
        private static integer element
        private static string array path
        private static trigger trg

        static method string takes integer element returns string
            return thistype.path[element]
        endmethod

        private static method onDamage takes nothing returns boolean
            local integer dmg = R2I(Damage.amount + 0.5)
            if Damage.source == thistype.source and dmg > 0 then
                call FloatingTextSplat(thistype.path[thistype.element] + I2S(dmg) + "|r", Damage.target).setVisible(GetLocalPlayer() == GetOwningPlayer(Damage.source) and IsUnitVisible(Damage.target, GetLocalPlayer()))
            endif
            return false
        endmethod

        static method apply takes unit source, unit target, real damage, attacktype at, damagetype dt, integer element returns nothing
            set thistype.source = source
            set thistype.element = element
            set s__Damage_coded = true
            call EnableTrigger(thistype.trg)
            call UnitDamageTarget(source, target, damage, false, false, at, dt, null)
            call DisableTrigger(thistype.trg)
            set s__Damage_coded = false
            set thistype.source = null
            set thistype.element = 0
        endmethod

        private static method onInit takes nothing returns nothing
            set thistype.path[DAMAGE_ELEMENT_ARCANE] = "|iELEMENT_ARCANE|i|cfff85888"
            set thistype.path[DAMAGE_ELEMENT_DARK] = "|iELEMENT_DARK|i|cff9c2889"
            set thistype.path[DAMAGE_ELEMENT_EARTH] = "|iELEMENT_EARTH|i|cfff09140"
            set thistype.path[DAMAGE_ELEMENT_ELECTRIC] = "|iELEMENT_ELECTRIC|i|cff30ccf8"
            set thistype.path[DAMAGE_ELEMENT_FIRE] = "|iELEMENT_FIRE|i|cfff08030"
            set thistype.path[DAMAGE_ELEMENT_ICE] = "|iELEMENT_ICE|i|cff96c8ff"
            set thistype.path[DAMAGE_ELEMENT_LIGHT] = "|iELEMENT_LIGHT|i|cffffcf00"
            set thistype.path[DAMAGE_ELEMENT_NORMAL] = "|iELEMENT_NORMAL|i|cffff0000"
            set thistype.path[DAMAGE_ELEMENT_PLANT] = "|iELEMENT_PLANT|i|cff50a43b"
            set thistype.path[DAMAGE_ELEMENT_POISON] = "|iELEMENT_POISON|i|cff7ca700"
            set thistype.path[DAMAGE_ELEMENT_SPIRIT] = "|iELEMENT_SPIRIT|i|cffe1e1e1"
            set thistype.path[DAMAGE_ELEMENT_WATER] = "|iELEMENT_WATER|i|cff5890f0"
            set thistype.trg = CreateTrigger()
            set s__Damage_coded = false
            call Damage.registerTrigger(thistype.trg)
            call TriggerAddCondition(thistype.trg, function thistype.onDamage)
            call DisableTrigger(thistype.trg)
        endmethod
    endstruct

    module DamageElement
        public static Element element
        readonly static boolean coded

        static method apply takes unit source, unit target, real amount, attacktype at, damagetype dt returns nothing
            set thistype.coded = true
            call UnitDamageTarget(source, target, amount, true, false, at, dt, null)
            set thistype.coded = false
        endmethod

        static method kill takes unit source, unit target returns nothing
            if source != null and target != null then
                set Damage.enabled = false
                call SetWidgetLife(target, 0.406)
                call UnitDamageTarget(source, target, 0x0000FFFF, true, false, ATTACK_TYPE_CHAOS, DAMAGE_TYPE_UNIVERSAL, null)
                call UnitDamageTarget(source, target, 0x0000FFFF, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
                set Damage.enabled = true
            endif
        endmethod

    endmodule

endlibrary
