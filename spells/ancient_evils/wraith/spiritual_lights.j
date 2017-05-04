scope SpiritualLights

    globals
        private constant integer SPELL_ID = 'A342'
        private constant integer UNIT_ID = 'uSpL'
        private constant integer PURE_RED_COUNT = 15
        private constant string HEAL_SFX = "Abilities\\Spells\\Human\\Heal\\HealTarget.mdl"
        private constant real TIMEOUT = 0.1
        private constant real INTERVAL = 1.0
    endglobals
    
    private function HealRadius takes integer level returns real
        return 500.0 + 0.0*level
    endfunction
    
    private function SearchRadius takes integer level  returns real
        return 2000.0 + 0.0*level
    endfunction
    
    private function HealPercentBonus takes integer level  returns real
        return 5.0 + 0.0*level
    endfunction
    
    private function HealPerSecond takes integer level  returns real
        if level == 11 then
            return 800.0
        endif
        return 40.0*level
    endfunction
    
    private function Duration takes integer level returns real
        return 10.0 + 0.0*level
    endfunction
    
    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitAlly(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE)
    endfunction
    
    private function SearchFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE)
    endfunction
    
    struct SpiritualLights extends array
        implement Alloc
        
        private unit caster
        private group lights
        private real heal
        private real healBonus
        private real duration
        private real ctr
        private real search
        private real radius
        
        private static group g
        private static Table tb
        
        private method destroy takes nothing returns nothing
            call this.pop()
            call thistype.tb.remove(GetHandleId(this.caster))
            call DestroyGroup(this.lights)
            set this.caster = null
            set this.lights = null
            call this.deallocate()
        endmethod
        
        private static real count
        
        private static method changeColor takes nothing returns nothing
            call SetUnitVertexColor(GetEnumUnit(), 255, R2I(255*(1.0 - thistype.count/PURE_RED_COUNT)), R2I(255*(1.0 - thistype.count/PURE_RED_COUNT)), 255)
        endmethod
        
        private static method onPeriod takes nothing returns nothing
            local thistype this = thistype(0).next
            local unit u
            local real healAmount
            local real healFactor
            local real x
            local real y
            local player owner
            loop
                exitwhen this == 0
                set this.duration = this.duration - TIMEOUT
                set this.ctr = this.ctr - TIMEOUT
                if this.ctr <= 0 then
                    set this.ctr = INTERVAL
                endif
                if FirstOfGroup(this.lights) == null then
                    call this.destroy()
                elseif this.duration > 0 then
                    set healFactor = 1.0
                    set x = GetUnitX(this.caster)
                    set y = GetUnitY(this.caster)
                    call GroupEnumUnitsInRange(thistype.g, x, y, this.search, null)
                    set owner = GetOwningPlayer(this.caster)
                    set thistype.count = 0.0
                    loop
                        set u = FirstOfGroup(thistype.g)
                        exitwhen u == null
                        call GroupRemoveUnit(thistype.g, u)
                        if SearchFilter(u, owner) then
                            set thistype.count = thistype.count + 1.0
                            if this.ctr == INTERVAL then
                                set healFactor = healFactor + this.healBonus
                            endif
                        endif
                    endloop
                    call ForGroup(this.lights, function thistype.changeColor)
                    if this.ctr == INTERVAL then
                        set healAmount = this.heal*healFactor
                        call GroupEnumUnitsInRange(thistype.g, x, y, this.radius, null)
                        loop
                            set u = FirstOfGroup(thistype.g)
                            exitwhen u == null
                            call GroupRemoveUnit(thistype.g, u)
                            if TargetFilter(u, owner) then
                                call AddSpecialEffectTimer(AddSpecialEffectTarget(HEAL_SFX, u, "origin"), 1.25)
                                call Heal.unit(this.caster, u, healAmount, 4.0, true)
                            endif
                        endloop
                    endif
                    set owner = null
                endif
                set this = this.next
            endloop
        endmethod

        implement List
        
        private static method onSummon takes nothing returns boolean
            if GetUnitTypeId(GetTriggerUnit()) == UNIT_ID then
                call GroupAddUnit(thistype(thistype.tb[GetHandleId(thistype.tb.unit[GetHandleId(GetTriggeringTrigger())])]).lights, GetTriggerUnit())
            endif
            return false
        endmethod
        
        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            local integer lvl
            set this.caster = GetTriggerUnit()
            set lvl = GetUnitAbilityLevel(this.caster, SPELL_ID)
            set this.ctr = INTERVAL
            set this.heal = HealPerSecond(lvl)*INTERVAL
            set this.healBonus = HealPercentBonus(lvl)*0.01
            set this.duration = Duration(lvl)
            set this.radius = HealRadius(lvl)
            set this.search = SearchRadius(lvl)
            set this.lights = NewGroup()
            set thistype.tb[GetHandleId(this.caster)] = this
            call this.push(TIMEOUT)
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method register takes unit u returns nothing
            local trigger t = CreateTrigger()
            local region r = CreateRegion()
            call RegionAddRect(r, WorldBounds.world)
            call TriggerRegisterEnterRegion(t, r, null)
            call TriggerAddCondition(t, function thistype.onSummon)
            set thistype.tb.unit[GetHandleId(t)] = u
        endmethod
        
        static method init takes nothing returns nothing
            local trigger t
            local region r
            call SystemTest.start("Initializing thistype: ")
            set thistype.g = CreateGroup()
            set thistype.tb = Table.create()
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call thistype.register(PlayerStat.initializer.unit)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope