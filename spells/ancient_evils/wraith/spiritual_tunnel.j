scope SpiritualTunnel
    
    globals
        private constant integer SPELL_ID = 'A324'
        private constant string SOURCE_SFX = "Models\\Effects\\SpiritualTunnelSource.mdx"
        private constant string TARGET_SFX = "Models\\Effects\\SpiritualTunnelTarget.mdx"
        private constant string SFX = "Models\\Effects\\SpiritualTunnelArrive.mdx"
        private constant real X = 0.0
        private constant real Y = 0.0
    endglobals
    
    private function ChannelTime takes integer level returns real
        if level == 11 then
            return 1.50
        endif
        return 8.0 - 0.5*level 
    endfunction
    
    struct SpiritualTunnel extends array
        implement Alloc
        
        private Castbar bar
        private unit imagery
        private effect sourceSfx
        private effect targetSfx
        
        private static Table tb
        
        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            local unit u = GetTriggerUnit()
            local real x = GetUnitX(u)
            local real y = GetUnitY(u)
            set thistype.tb[GetHandleId(u)] = this
            set this.imagery = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), GetUnitTypeId(u), X, Y, GetUnitFacing(u))
            set this.bar = Castbar.create(x, y, ChannelTime(GetUnitAbilityLevel(u, SPELL_ID)))
            call SetUnitColor(this.imagery, GetPlayerColor(GetTriggerPlayer()))
            call UnitAddAbility(this.imagery, 'Aloc')
            call SetUnitX(this.imagery, X)
            call SetUnitY(this.imagery, Y)
            call PauseUnit(this.imagery, true)
            call SetUnitAnimation(this.imagery, "spell channel")
            call SetUnitVertexColor(this.imagery, 255, 255, 255, 80)
            set this.sourceSfx = AddSpecialEffect(SOURCE_SFX, x, y)
            set this.targetSfx = AddSpecialEffect(TARGET_SFX, X, Y)
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        private static method onStop takes nothing returns nothing
            local integer id = GetHandleId(GetTriggerUnit())
            local thistype this = thistype.tb[id]
            call thistype.tb.remove(id)
            call this.bar.destroy()
            call RemoveUnit(this.imagery)
            call DestroyEffect(this.sourceSfx)
            call DestroyEffect(this.targetSfx)
            set this.sourceSfx = null
            set this.targetSfx = null
            call this.deallocate()
        endmethod
        
        private static method onFinish takes nothing returns nothing
            call SetUnitPosition(GetTriggerUnit(), X, Y)
            call DestroyEffect(AddSpecialEffect(SFX, X, Y))
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