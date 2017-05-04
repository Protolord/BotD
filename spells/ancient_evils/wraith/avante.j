scope Avante    

    globals
        private constant integer SPELL_ID = 'A341'
        private constant string SFX = "Models\\Effects\\Avante.mdx"
        private constant string HEAL_SFX = "Abilities\\Spells\\Undead\\AnimateDead\\AnimateDeadTarget.mdl" 
    endglobals
    
    private function ChannelTime takes integer level returns real
        if level == 11 then
            return 3.50
        endif
        return 12.0 - 0.5*level
    endfunction
    
    struct Avante extends array
        implement Alloc
        
        private Castbar bar
        private effect sfx
        
        private static Table tb
        
        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            local unit u = GetTriggerUnit()
            local integer id = GetHandleId(u)
            local real x = GetUnitX(u)
            local real y = GetUnitY(u)
            local real timescale
            set this.sfx = AddSpecialEffect(SFX, x, y)
            set thistype.tb[id] = this
            set this.bar = Castbar.create(x, y, ChannelTime(GetUnitAbilityLevel(u, SPELL_ID)))
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        private static method onStop takes nothing returns nothing
            local integer id = GetHandleId(GetTriggerUnit())
            local thistype this
            if thistype.tb.has(id) then
                set this = thistype.tb[id]
                call thistype.tb.remove(id)
                call this.bar.destroy()
                call DestroyEffect(this.sfx)
                set this.sfx = null
                call this.deallocate()
            endif
        endmethod
        
        private static method onFinish takes nothing returns nothing
            local unit u = GetTriggerUnit()
            call Heal.unit(u, u, 0xFFFFFF, 1.0, true) 
            call DestroyEffect(AddSpecialEffectTarget(HEAL_SFX, u, "origin"))
            set u = null
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " finished casting thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            set thistype.tb = Table.create()
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call RegisterSpellEndcastEvent(SPELL_ID, function thistype.onStop)
            call RegisterSpellFinishEvent(SPELL_ID, function thistype.onFinish)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope