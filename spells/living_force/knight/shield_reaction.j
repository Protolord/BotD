scope ShieldReaction

    globals
        private constant integer    SPELL_ID            = 'AHB3'

        private constant real       SILENCE_DURATION    = 2.0

        //angle determines how "wide" is the rear angle of the unit
        private constant real       REAR_ANGLE          = 30.
    endglobals

    private function Chance takes integer level returns real
        return 0.05*level
    endfunction

    //unit u : attacking unit
    //player p : owner of attacked unit
    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and /*
        */     not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE) and IsUnitType(u, UNIT_TYPE_MELEE_ATTACKER)
    endfunction

    private function FromRear takes unit target, unit unitToCheck returns boolean
        local real angle = bj_RADTODEG*Atan2(GetUnitY(target) - GetUnitY(unitToCheck), GetUnitX(target) - GetUnitX(unitToCheck))
        local real start = ModuloReal(RAbsBJ(GetUnitFacing(target) - angle), 360.)

        return (start <= 90+REAR_ANGLE and start >= 90-REAR_ANGLE) or (start >= 270-REAR_ANGLE and start <= 270+REAR_ANGLE)
    endfunction

    struct ShieldReaction extends array
        implement Alloc

        private static Table tb

        private unit u
        private real triggerChance

        private static method onDamage takes nothing returns nothing
            local integer id = GetHandleId(Damage.target)
            local thistype this = thistype.tb[id]

            if this != 0 and FromRear(Damage.target, Damage.source) and GetRandomReal(0., 1.) <= this.triggerChance and TargetFilter(Damage.source, GetOwningPlayer(Damage.target)) then
                //knockback unit

                call Silence.create(Damage.source, SILENCE_DURATION)
            endif
        endmethod

        private static method ultimates takes nothing returns boolean
            local unit u = GetTriggerUnit()
            local integer id = GetHandleId(u)
            local thistype this

            if thistype.tb.has(id) then
                set this = thistype.tb[id]
                set this.triggerChance = Chance(11)
            endif

            set u = null
            return false
        endmethod

        private static method learn takes nothing returns nothing
            local thistype this
            local unit u
            local integer id
            local integer lvl

            if GetLearnedSkill() == SPELL_ID then
                set u = GetTriggerUnit()
                set id = GetHandleId(u)
                if not thistype.tb.has(id) then
                    set this = thistype.allocate()
                    set this.u = u
                    set thistype.tb[id] = this
                else
                    set this = thistype.tb[id]
                endif
                set lvl = GetUnitAbilityLevel(u, SPELL_ID)

                set this.triggerChance = Chance(lvl)

                set u = null
            endif
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_SKILL, function thistype.learn)
            call PlayerStat.ultimateEvent(function thistype.ultimates)
            call Damage.register(function thistype.onDamage)
            set thistype.tb = Table.create()
            call SystemTest.end()
        endmethod
    endstruct
endscope