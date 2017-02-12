scope Bones
    
    globals
        private constant integer SPELL_ID = 'A7XX'
        private constant real CHANCE = 100.0
        private constant real DURATION = 300.0
        private constant real DAMAGE_PER_ARROW = 10.0
        private constant string ARROW_MODEL = "Abilities\\Weapons\\GuardTowerMissile\\GuardTowerMissile.mdl"
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
    endglobals
    
    private function TargetFilter takes unit u, player owner returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, owner) and IsUnitType(u, UNIT_TYPE_MELEE_ATTACKER)
    endfunction
    
    private function SourceFilter takes unit u returns boolean
        return GetUnitTypeId(u) == 'hgtw'
    endfunction
    
    private struct Arrow extends array
        
        private effect sfx
        private unit target
        private unit arrow
        
        private static Table tb
        
        static method count takes unit u returns integer 
            return thistype.tb[GetHandleId(u)]
        endmethod
        
        static method has takes unit u returns boolean
            return thistype.tb.has(GetHandleId(u))
        endmethod
        
        private static method expires takes nothing returns nothing
            local thistype this = ReleaseTimer(GetExpiredTimer())
            call DestroyEffect(this.sfx)
            call DummyAddRecycleTimer(this.arrow, 1.0)
            set this.arrow = null
            set this.target = null
            call this.destroy()
        endmethod
        
        implement CTLExpire
            call SetUnitX(this.arrow, GetUnitX(this.target))
            call SetUnitY(this.arrow, GetUnitY(this.target))
        implement CTLEnd
        
        static method add takes unit source, unit target returns nothing
            local thistype this = thistype.create()
            local integer id = GetHandleId(target)
            local real x1 = GetUnitX(source)
            local real y1 = GetUnitY(source)
            local real x2 = GetUnitX(target)
            local real y2 = GetUnitY(target)
            local real angleDeg = Atan2(y2 - y1, x2 - x1)*bj_RADTODEG
            set this.target = target
            set this.arrow = GetRecycledDummy(x2, y2, GetUnitFlyHeight(target) + GetRandomReal(20, 60), angleDeg + GetRandomReal(-10, 10))
            set this.sfx = AddSpecialEffectTarget(ARROW_MODEL, this.arrow, "origin")
            set thistype.tb[id] = thistype.tb[id] + 1
            call TimerStart(NewTimerEx(this), DURATION, false, function thistype.expires)
        endmethod
        
        private static method init takes nothing returns nothing
            set thistype.tb = Table.create()
        endmethod
        
    endstruct
    
    struct Bones extends array
        
        private static trigger trg
        
        private static method onDamage takes nothing returns boolean
            local integer level = GetUnitAbilityLevel(Damage.target, SPELL_ID)
            if level > 0 and Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.element.coded then
                //Attacked unit has arrows and attacker is melee
                if Arrow.has(Damage.target) and TargetFilter(Damage.source, GetOwningPlayer(Damage.target)) then
                    call DisableTrigger(thistype.trg)
                    call Damage.element.apply(Damage.target, Damage.source, DAMAGE_PER_ARROW*Arrow.count(Damage.target), ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_NORMAL)
                    call EnableTrigger(thistype.trg)
                endif
                //Add arrow
                if SourceFilter(Damage.source) and GetRandomReal(0, 100) <= CHANCE then
                    call Arrow.add(Damage.source, Damage.target)
                    call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " procs thistype")
                endif
            endif
            return false
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            set thistype.trg = CreateTrigger()
            call Damage.registerTrigger(thistype.trg)
            call TriggerAddCondition(thistype.trg, function thistype.onDamage)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope