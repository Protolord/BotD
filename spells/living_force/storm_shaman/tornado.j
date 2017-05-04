scope Tornado
 
    globals
        private constant integer SPELL_ID = 'AH11'
        private constant integer TORNADO_EVASION_ID = 'EH11'
        private constant string SFX = "Abilities\\Spells\\Other\\Tornado\\TornadoElemental.mdl"
    endglobals
    
    private function Duration takes integer level returns real
        if level == 11 then
            return 10.0
        endif
        return 1.0*level
    endfunction
    
    private struct SpellBuff extends Buff
        implement List

        private Effect e
        private VertexColor vc

        private static constant integer RAWCODE = 'BH11'
        private static constant integer DISPEL_TYPE = BUFF_POSITIVE
        private static constant integer STACK_TYPE = BUFF_STACK_NONE
        
        method onRemove takes nothing returns nothing
            call this.pop()
            call this.e.destroy()
            call this.vc.destroy()
            call UnitRemoveAbility(this.target, TORNADO_EVASION_ID)
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this = thistype(0).next
            loop
                exitwhen this == 0
                call this.e.setXY(GetUnitX(this.target), GetUnitY(this.target))
                set this = this.next
            endloop
        endmethod
        
        method onApply takes nothing returns nothing
            set this.e = Effect.createAnyAngle(SFX, GetUnitX(this.target), GetUnitY(this.target), 0)
            set this.e.scale = 0.75
            set this.vc = VertexColor.create(this.target, 0, 0, 0, -200)
            set this.vc.speed = 400
            call UnitAddAbility(this.target, TORNADO_EVASION_ID)
            call this.push(0.03125)
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod
        
        implement BuffApply
    endstruct
    
    struct Tornado extends array
        implement Alloc
        
        private unit u
        
        private static method expires takes nothing returns nothing
            local thistype this = ReleaseTimer(GetExpiredTimer())
            call UnitRemoveAbility(this.u, 'BOwk')
            set this.u = null
            call this.deallocate()
        endmethod
        
        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            local unit caster = GetTriggerUnit()
            local integer lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            local SpellBuff b = SpellBuff.add(caster, caster)
            set b.duration = Duration(lvl)
            set this.u = caster
            call TimerStart(NewTimerEx(this), 0.00, false, function thistype.expires)
            set caster = null
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SpellBuff.initialize()
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope