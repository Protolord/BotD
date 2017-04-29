/*
    
    No triggers needed
    Use Locust Swarm

*/
scope LocustSwarm

    globals
        private constant integer SPELL_ID = 'A412'
        private constant integer UNIT_ID = 'uloc'
    endglobals

    struct LocustSwarm extends array
        implement Alloc

        private unit caster

        private static method onDamage takes nothing returns nothing
            if GetUnitTypeId(Damage.source) == UNIT_ID then
                call FloatingTextSplat(Element.string(DAMAGE_ELEMENT_NORMAL) + I2S(R2I(Damage.amount + 0.5)) + "|r", Damage.target, 1.0).setVisible(GetLocalPlayer() == GetOwningPlayer(Damage.source))
            endif
        endmethod

        private static method expires takes nothing returns nothing
            local thistype this = ReleaseTimer(GetExpiredTimer())
            call AddUnitAnimationProperties(this.caster, "alternate", false)
            set this.caster = null
            call this.deallocate()
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            set this.caster = GetTriggerUnit()
            call TimerStart(NewTimerEx(this), 0.0, false, function thistype.expires)
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call Damage.register(function thistype.onDamage)
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call PreloadUnit(UNIT_ID)
            call SystemTest.end()
        endmethod        

    endstruct

endscope