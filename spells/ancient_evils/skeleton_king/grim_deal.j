scope GrimDeal
    
    globals
        private constant integer SPELL_ID = 'A743'
        private constant real DELAY = 1.5
        private constant string SFX_DEATH = "Abilities\\Spells\\Undead\\AnimateDead\\AnimateDeadTarget.mdl"
        private constant string SFX_HEAL = "Models\\Effects\\GrimDeal.mdx"
        private constant string SFX = "Objects\\Spawnmodels\\Undead\\UndeadDissipate\\UndeadDissipate.mdl"
    endglobals
    
    private function Chance takes integer level returns real
        if level == 11 then
            return 50.0
        endif
        return 100.0//11.0 + 2.0*level
    endfunction
    
    struct GrimDeal extends array
        implement Alloc 

        private unit u
        private TimeScale ts

        private static Table tb

        private static method expires takes nothing returns nothing
            local thistype this = ReleaseTimer(GetExpiredTimer())
            local integer id = GetHandleId(this.u)
            call PauseUnit(this.u, false)
            call SetUnitAnimation(Damage.target, "stand")
            call Heal.unit(this.u, 0xFFFFFF, 1.0)
            call DestroyEffect(AddSpecialEffectTarget(SFX_HEAL, this.u, "origin"))
            call DestroyEffect(AddSpecialEffect(SFX, GetUnitX(this.u), GetUnitY(this.u)))
            call thistype.tb.remove(id)
            set this.u = null
            call this.deallocate()
        endmethod

        private static method onDamage takes nothing returns nothing
            local integer level = GetUnitAbilityLevel(Damage.target, SPELL_ID)
            local integer id = GetHandleId(Damage.target)
            local thistype this
            if level > 0 then
                if thistype.tb.has(id) then
                    set Damage.amount = 0
                elseif Damage.amount >= GetWidgetLife(Damage.target) and GetRandomReal(0, 100) <= Chance(level) then
                    set Damage.amount = 0
                    set this = thistype.allocate()
                    set this.u = Damage.target
                    call PauseUnit(Damage.target, true)
                    call SetUnitAnimation(Damage.target, "death")
                    call DestroyEffect(AddSpecialEffectTarget(SFX_DEATH, Damage.target, "origin"))
                    call TimerStart(NewTimerEx(this), DELAY, false, function thistype.expires)
                    set thistype.tb[id] = this
                endif
            endif
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call Damage.registerModifier(function thistype.onDamage)
            set thistype.tb = Table.create()
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope