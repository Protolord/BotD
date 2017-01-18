scope AncestralRift
    
    globals
        private constant integer SPELL_ID = 'A343'
        private constant real MAX_TIMING = 15.0
        private constant real TIMEOUT = 0.2
        private constant string SFX = "Models\\Effects\\AncestralRift.mdx"
        private constant real SFX_DURATION = 1.5
        private constant real SFX_TIMEOUT = 0.03125
    endglobals
    
    private function Timing takes integer level returns real
        if level == 11 then
            return 15.0
        endif
        return 1.0*level + 5.0
    endfunction

    struct AncestralRift extends array
        implement Alloc
        
        private Table hp
        private unit u
        private integer oldest
        private unit dummy
        private real sfxDuration
        private effect sfx
        
        private thistype next
        private thistype prev
        private thistype nextSfx
        private thistype prevSfx
        
        private static integer ctr
        private static timer t
        private static timer sfxTimer
        private static Table tb
        
        private static constant integer INDEX_REMOVE_OFFSET = R2I(MAX_TIMING/TIMEOUT)
        
        method destroy takes nothing returns nothing
            call thistype.tb.remove(GetHandleId(this.u))
            set this.prev.next = this.next
            set this.next.prev = this.prev
            if thistype(0).next == 0 then
                call PauseTimer(thistype.t)
            endif
            set this.u = null
            call this.hp.flush()
            call this.hp.destroy()
            call this.deallocate()
        endmethod
        
        private static method onPeriod takes nothing returns nothing
            local thistype this = thistype(0).next
            local integer oldIndex = thistype.ctr - thistype.INDEX_REMOVE_OFFSET
            loop
                exitwhen this == 0
                set this.hp.real[thistype.ctr] = GetWidgetLife(this.u)
                if oldIndex > 0 then
                    call this.hp.real.remove(oldIndex)
                    set this.oldest = oldIndex + 1
                endif
                set this = this.next
            endloop            
            set thistype.ctr = thistype.ctr + 1
        endmethod
        
        
        static method unlearn takes unit u returns nothing
            local integer id = GetHandleId(u)
            local thistype this
            if thistype.tb.has(id) then
                set this = thistype.tb[id]
                call this.destroy()
            endif
        endmethod
        
        private static method learn takes nothing returns nothing
            local unit u 
            local integer id 
            local thistype this
            if GetLearnedSkill() == SPELL_ID then
                set u = GetTriggerUnit()
                set id = GetHandleId(u)
                if thistype.tb.has(id) then
                    set this = thistype.tb[id]
                else
                    set this = thistype.allocate()
                    set this.u = u
                    set this.hp = Table.create()
                    set this.oldest = thistype.ctr
                    set this.next = thistype(0)
                    set this.prev = thistype(0).prev
                    set this.next.prev = this
                    set this.prev.next = this
                    if this.prev == 0 then
                        call TimerStart(thistype.t, TIMEOUT, true, function thistype.onPeriod)
                    endif
                    set thistype.tb[id] = this
                endif
                set u = null
            endif
        endmethod
        
        private static method debuff takes nothing returns nothing
            local thistype this = ReleaseTimer(GetExpiredTimer())
            call UnitRemoveAbility(this.u, 'Bbsk')
        endmethod
        
        private static method onSfxPeriod takes nothing returns nothing
            local thistype this = thistype(0).nextSfx
            loop
                exitwhen this == 0
                set this.sfxDuration = this.sfxDuration - SFX_TIMEOUT
                if this.sfxDuration > 0 then
                    call SetUnitX(this.dummy, GetUnitX(this.u))
                    call SetUnitY(this.dummy, GetUnitY(this.u))
                else
                    set this.prevSfx.nextSfx = this.nextSfx
                    set this.nextSfx.prevSfx = this.prevSfx
                    if thistype(0).nextSfx == 0 then
                        call PauseTimer(thistype.sfxTimer)
                    endif
                    call DestroyEffect(this.sfx)
                    call DummyAddRecycleTimer(this.dummy, 0.5)
                    set this.dummy = null
                endif
                set this = this.nextSfx
            endloop
        endmethod
        
        private static method onCast takes nothing returns nothing
            local thistype this = thistype.tb[GetHandleId(GetTriggerUnit())]
            local integer index = thistype.ctr - R2I(Timing(GetUnitAbilityLevel(this.u, SPELL_ID))/TIMEOUT)
            if this.hp.real.has(index) then
                call SetWidgetLife(this.u, this.hp.real[index])
            else
                call SetWidgetLife(this.u, this.hp.real[this.oldest])
            endif
            set this.dummy = GetRecycledDummy(GetUnitX(this.u), GetUnitY(this.u), 0, 90)
            set this.sfx = AddSpecialEffectTarget(SFX, this.dummy, "origin")
            set this.sfxDuration = SFX_DURATION
            set this.nextSfx = 0
            set this.prevSfx = thistype(0).prevSfx
            set this.nextSfx.prevSfx = this
            set this.prevSfx.nextSfx = this
            if this.prevSfx == 0 then
                call TimerStart(thistype.sfxTimer, SFX_TIMEOUT, true, function thistype.onSfxPeriod)
            endif
            call TimerStart(NewTimerEx(this), 0.00, false, function thistype.debuff)
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            set thistype.tb = Table.create()
            set thistype.t = CreateTimer()
            set thistype.sfxTimer = CreateTimer()
            set thistype.ctr = 0
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_SKILL, function thistype.learn)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope