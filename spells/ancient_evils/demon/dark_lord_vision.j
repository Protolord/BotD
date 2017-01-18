scope DarkLordVision

    globals
        private constant integer SPELL_ID = 'A532'
        private constant string SFX = ""
        private constant real NODE_RADIUS = 250
        private constant real TIMEOUT = 0.05
    endglobals
    
    private function RevealThreshold takes integer level returns real
        return 0.05*level + 0.25
    endfunction
    
    private function Duration takes integer level returns real
        return 0.0*level + 30.00
    endfunction
    
    private function TargetFilter takes unit u, player owner returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, owner) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE) and not IsUnitType(u, UNIT_TYPE_STRUCTURE)
    endfunction
    
    private struct SightSource
        
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
            set this.target = null
            call this.deallocate()
        endmethod
        
        static method create takes thistype head, unit target, player owner returns thistype
            local thistype this = thistype.allocate()
            set this.target = target
            set this.u = GetRecycledDummyAnyAngle(GetUnitX(target), GetUnitY(target), 0)
            call PauseUnit(this.u, false)
            call SetUnitOwner(this.u, owner, false)
            call UnitSetBonus(this.u, BONUS_SIGHT_RANGE, R2I(NODE_RADIUS))
            call UnitAddAbility(this.u, 'ATSS')
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
    
    struct DarkLordVision extends array
        implement Alloc
        implement List
        
        private SightSource source
        private real duration
        private real threshold
        private unit u
        private player owner
        private group visible
        private fogmodifier fm
        private TrueSight ts
        private effect sfx
        
        private static group g
        private static timer t
        
        private method destroy takes nothing returns nothing
            local SightSource sight = this.source.next
            call this.pop()
            //Destroy all SightSource
            loop
                exitwhen sight == this.source
                call sight.destroy()
                set sight = sight.next
            endloop
            call this.source.destroy()
            call DestroyGroup(this.visible)
            call DestroyEffect(this.sfx)
            set this.u = null
            set this.sfx = null
            set this.visible = null
            call this.deallocate()
        endmethod
        
        private method update takes nothing returns nothing
            local unit u
            local SightSource ss
            local boolean b
            set this.duration = this.duration - TIMEOUT
            if this.duration > 0 then
                call GroupEnumUnitsInRect(thistype.g, WorldBounds.world, null)
                set b = this.owner != GetOwningPlayer(this.u)
                if b then
                    set this.owner = GetOwningPlayer(this.u)
                endif
                loop
                    set u = FirstOfGroup(thistype.g)
                    exitwhen u == null
                    call GroupRemoveUnit(thistype.g, u)
                    if not IsUnitInGroup(u, this.visible) and GetWidgetLife(u)/GetUnitState(u, UNIT_STATE_MAX_LIFE) < this.threshold and TargetFilter(u, this.owner) then
                        call GroupAddUnit(this.visible, u)
                        call SightSource.create(this.source, u, this.owner)
                    endif
                endloop
                //Update SightSources
                set ss = this.source.next
                loop
                    exitwhen ss == this.source
                    if GetWidgetLife(ss.u)/GetUnitState(ss.u, UNIT_STATE_MAX_LIFE) < this.threshold and TargetFilter(ss.target, this.owner) then
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
            else
                call this.destroy()
            endif
            set u = null
        endmethod
        
        private static method onPeriod takes nothing returns nothing
            local thistype this = thistype(0).next
            loop
                exitwhen this == 0
                call this.update()
                set this = this.next
            endloop
        endmethod
        
        private static method expires takes nothing returns nothing
            local thistype this = ReleaseTimer(GetExpiredTimer())
            call DestroyFogModifier(this.fm)
            call DestroyEffect(this.sfx)
            call this.ts.destroy()
            set this.fm = null
            set this.sfx = null
            set this.u = null
            call this.deallocate()
        endmethod
        
        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            local integer lvl
            set this.u = GetTriggerUnit()
            set this.owner = GetTriggerPlayer()
            set lvl = GetUnitAbilityLevel(u, SPELL_ID)
            if lvl < 11 then
                set this.duration = Duration(lvl)
                set this.threshold = RevealThreshold(lvl)
                set this.visible = CreateGroup()
                set this.source = SightSource.head()
                call this.push(TIMEOUT)
            else
                set this.fm = CreateFogModifierRect(this.owner, FOG_OF_WAR_VISIBLE, WorldBounds.world, true, false)
                set this.ts = TrueSight.create(this.u, GLOBAL_SIGHT)
                call FogModifierStart(this.fm)
                call TimerStart(NewTimerEx(this), Duration(lvl), false, function thistype.expires)
                set this.owner = null
            endif
            set this.sfx = AddSpecialEffectTarget(SFX, this.u, "overhead")
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            set thistype.g = CreateGroup()
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope