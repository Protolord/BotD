scope Heartbeat
    
    globals
        private constant integer SPELL_ID = 'A731'
        private constant integer BUFF_ID = 'B731'
        private constant real TIMEOUT = 0.2
        private constant string SFX_TARGET = "Abilities\\Spells\\Orc\\Bloodlust\\BloodlustTarget.mdl"
		private constant real RADIUS = 200.0
    endglobals

    private function Range takes integer level returns real
        if level == 11 then
            return GLOBAL_SIGHT
        endif
        return 250.0*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction

    private struct SightSource extends array 
        implement Alloc
        
        private effect sfx
        readonly unit u
        readonly unit target
        
        readonly thistype next
        readonly thistype prev
        
        method destroy takes nothing returns nothing
            set this.prev.next = this.next
            set this.next.prev = this.prev
            if this.u != null then
                call UnitClearBonus(this.u, BONUS_SIGHT_RANGE)
                call UnitRemoveAbility(this.u, 'ATSS')
                call RecycleDummy(this.u)
                set this.u = null
            endif
            if this.sfx != null then
                call DestroyEffect(this.sfx)
            endif
            set this.target = null
            call this.deallocate()
        endmethod
        
        static method create takes thistype head, unit target, player owner returns thistype
            local thistype this = thistype.allocate()
            local string s = SFX_TARGET
            set this.target = target
            set this.u = GetRecycledDummyAnyAngle(GetUnitX(target), GetUnitY(target), 0)
            call PauseUnit(this.u, false)
            call SetUnitOwner(this.u, owner, false)
			call UnitSetBonus(this.u, BONUS_SIGHT_RANGE, R2I(RADIUS))
            call UnitAddAbility(this.u, 'ATSS')
            if IsPlayerEnemy(owner, GetLocalPlayer()) then
                set s = ""
            endif
            set this.sfx = AddSpecialEffectTarget(s, target, "chest")
            set this.next = head.next
            set this.prev = head
            set this.next.prev = this
            set this.prev.next = this
            return this
        endmethod
        
        static method head takes nothing returns thistype
            local thistype this = thistype.allocate()
            set this.next = this
            set this.prev = this
            return this
        endmethod
        
    endstruct
    
    struct Heartbeat extends array
        implement Alloc
        
        private unit caster
        private player owner
        private group visible
        private real range
        private SightSource ss
        
        private static Table tb
        private static group g
        
        private static method onPeriod takes nothing returns nothing
            local thistype this = thistype.top
            local SightSource ss
            local player p
			local boolean b
			local unit u
            loop
                exitwhen this == 0
                if this.range == GLOBAL_SIGHT then 
                    call GroupEnumUnitsInRect(thistype.g, WorldBounds.world, null)
                else
                    call GroupUnitsInArea(thistype.g, GetUnitX(this.caster), GetUnitY(this.caster), this.range)
                endif
                set b = this.owner != GetOwningPlayer(this.caster)
                if b then
                    set this.owner = GetOwningPlayer(this.caster)
                endif
                loop
                    set u = FirstOfGroup(thistype.g)
                    exitwhen u == null
                    call GroupRemoveUnit(thistype.g, u)
                    if not IsUnitInGroup(u, this.visible) and TargetFilter(u, this.owner) then
                        call GroupAddUnit(this.visible, u)
                        call SightSource.create(this.ss, u, this.owner)
                    endif
                endloop
                //Update SightSources
                set ss = this.ss.next
                loop
                    exitwhen ss == this.ss
                    if IsUnitInRange(this.caster, ss.target, this.range) and TargetFilter(ss.target, this.owner) then
                        call SetUnitX(ss.u, GetUnitX(ss.target))
                        call SetUnitY(ss.u, GetUnitY(ss.target))
                        if b then
                            call SetUnitOwner(ss.u, this.owner, false)
                        endif
                    else
                        call GroupRemoveUnit(this.visible, ss.target)
                        call ss.destroy()
                    endif
                    set ss = ss.next
                endloop
                set this = this.next
            endloop
        endmethod

        implement Stack
        
        private static method ultimates takes nothing returns boolean
            local unit u = GetTriggerUnit()
            local integer id = GetHandleId(u)
            local thistype this
            if thistype.tb.has(id) then
                set this = thistype.tb[id]
                set this.range = Range(11)
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
                    set this.caster = u
                    set this.owner = GetTriggerPlayer()
                    set this.ss = SightSource.head()
                    set this.visible = NewGroup()
                    set thistype.tb[id] = this
                    call this.push(TIMEOUT)
                    call UnitAddAbility(u, BUFF_ID)
                    call UnitMakeAbilityPermanent(u, true, BUFF_ID)
                else
                    set this = thistype.tb[id]
                endif
                set lvl = GetUnitAbilityLevel(u, SPELL_ID)
                set this.range = Range(lvl)
                set u = null
            endif
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_SKILL, function thistype.learn)
            call PlayerStat.ultimateEvent(function thistype.ultimates)
            set thistype.tb = Table.create()
            set thistype.g = CreateGroup()
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope