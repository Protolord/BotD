scope Companion

    globals
        private constant integer SPELL_ID = 'AH83'

        private constant integer OWL = 1
        private constant integer EAGLE = 2
        private constant integer FALCON = 3
        private integer array UNIT_ID
    endglobals

    //In Percent
    private function DamagePercent takes integer level returns real
        return 10.0*level
    endfunction

    struct Companion extends array
        implement Alloc

        private real dmg
        private unit caster
        private unit u

        private static Table tb
        private static group g

        private static method onDamage takes nothing returns nothing
            local thistype this
            if Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.coded then
                if IsUnitInGroup(Damage.source, thistype.g) then
                    set this = GetHandleId(Damage.source)
                    set Damage.amount = this.dmg*Damage.amount
                endif
            endif
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            local integer lvl
            local integer id
            set this.caster = GetTriggerUnit()
            set lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            set id = thistype.tb[GetHandleId(this.caster)]
            set this.dmg = 0.01*DamagePercent(lvl)
            set this.u = CreateUnit(GetTriggerPlayer(), UNIT_ID[id], GetUnitX(this.caster), GetUnitY(this.caster), GetUnitFacing(this.caster))
            call GroupAddUnit(thistype.g, this.u)
            set thistype.tb[GetHandleId(this.u)] = this
            //Make next summon different
            set id = id + 1
            if id > FALCON then
                set id = OWL
            endif
            set thistype.tb[GetHandleId(this.caster)] = id
            call SystemMsg.create(GetUnitName(this.caster) + " cast thistype")
        endmethod

        private static method add takes unit u returns nothing
            set thistype.tb[GetHandleId(u)] = OWL
        endmethod

        private static method initUnits takes nothing returns nothing
            set UNIT_ID[OWL] = 'hOwl'
            set UNIT_ID[EAGLE] = 'hEag'
            set UNIT_ID[FALCON] = 'hFal'
            call PreloadUnit(UNIT_ID[OWL])
            call PreloadUnit(UNIT_ID[EAGLE])
            call PreloadUnit(UNIT_ID[FALCON])
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            set thistype.tb = Table.create()
            set thistype.g = CreateGroup()
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call thistype.add(PlayerStat.initializer.unit)
            call thistype.initUnits()
            call SystemTest.end()
        endmethod

    endstruct

endscope