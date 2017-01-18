scope Rabies
    
    globals
        private constant integer SPELL_ID = 'A222'
        private constant integer RABIES_BUFF = 'B222'
        private constant real TIMEOUT = 0.10
        //When movespeed exceeds THRESHOLD, Werewolf will use a different animation
        private constant real THRESHOLD = 400
        private constant string SFX = "Models\\Effects\\RabiesEffect.mdx"
    endglobals
    
    private function BonusCap takes integer level returns real
        if level == 11 then
            return 2.0
        endif
        return 0.1*level
    endfunction
    
    struct Rabies extends array
        implement Alloc
        
        private unit u
        private real limit
        private boolean running
        private effect sfx
        private Movespeed ms
        
        private static Table tb
        private static timer t
        
        private thistype next
        private thistype prev
        
        private static method pickAll takes nothing returns nothing
            local thistype this = thistype(0).next
            local real percent
            loop
                exitwhen this == 0
                set percent = 1.0 - GetWidgetLife(this.u)/GetUnitState(this.u, UNIT_STATE_MAX_LIFE)
                if percent > this.limit then
                    set percent = this.limit
                endif
                call this.ms.change(percent, 0)
                if this.running then
                    if GetUnitMoveSpeed(this.u) < THRESHOLD then
                        set this.running = false
                        call AddUnitAnimationProperties(this.u, "fast", false)
                        call DestroyEffect(this.sfx)
                        set this.sfx = null
                    endif
                else
                    if GetUnitMoveSpeed(this.u) >= THRESHOLD then
                        set this.running = true
                        call AddUnitAnimationProperties(this.u, "fast", true)
                        set this.sfx = AddSpecialEffectTarget(SFX, this.u, "chest")
                    endif
                endif
                set this = this.next
            endloop
        endmethod
        
        private static method ultimates takes nothing returns boolean
            local unit u = GetTriggerUnit()
            local integer id = GetHandleId(u)
            local thistype this
            if thistype.tb.has(id) then
                set this = thistype.tb[id]
                set this.limit = BonusCap(11)
            endif
            set u = null
            return false
        endmethod
        
        private static method learn takes nothing returns nothing  
            local thistype this
            local unit u
            local integer id
            if GetLearnedSkill() == SPELL_ID then
                set u = GetTriggerUnit()
                set id = GetHandleId(u)
                if not thistype.tb.has(id) then
                    set this = thistype.allocate()
                    set this.u = u
                    set this.ms = Movespeed.create(this.u, 0.0, 0)
                    set this.running = false
                    set thistype.tb[id] = this
                    set this.prev = thistype(0).prev
                    set this.next = thistype(0)
                    set this.prev.next = this
                    set this.next.prev = this
                    if thistype(0).next == this then
                        call TimerStart(thistype.t, TIMEOUT, true, function thistype.pickAll)
                    endif
                    call UnitAddAbility(u, RABIES_BUFF)
                    call UnitMakeAbilityPermanent(u, true, RABIES_BUFF)
                else
                    set this = thistype.tb[id]
                endif
                set this.limit = BonusCap(GetUnitAbilityLevel(this.u, SPELL_ID))
                set u = null
            endif
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_SKILL, function thistype.learn)
            call PlayerStat.ultimateEvent(function thistype.ultimates)
            set thistype.tb = Table.create()
            set thistype.t = CreateTimer()
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope