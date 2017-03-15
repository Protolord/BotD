scope StoneForm
 
    globals
        private constant integer SPELL_ID = 'A642'
        private constant real TIMEOUT = 1.0
        private constant string SFX = "Models\\Effects\\StoneForm.mdx"
    endglobals

    private function FormDelay takes integer level returns real
        return 3.0 + 0.0*level
    endfunction

    private function HealPerSecond takes integer level returns real
        if level == 11 then
            return 2000.0
        endif
        return 100.0*level
    endfunction

    private struct SpellBuff extends Buff

        private real hps
        private timer t

        private static constant integer RAWCODE = 'D642'
        private static constant integer DISPEL_TYPE = BUFF_NONE
        private static constant integer STACK_TYPE = BUFF_STACK_NONE
        
        method onRemove takes nothing returns nothing
            call ReleaseTimer(this.t)
            set this.t = null
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            call Heal.unit(this.target, this.hps, 4.0)
        endmethod
        
        method onApply takes nothing returns nothing
            set this.t = NewTimerEx(this)
            set this.hps = HealPerSecond(GetUnitAbilityLevel(this.target, SPELL_ID))*TIMEOUT
            call TimerStart(this.t, TIMEOUT, true, function thistype.onPeriod)
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod
        
        implement BuffApply
    endstruct
    
    struct StoneForm extends array
        implement Alloc

        private unit caster
        private timer t
        private effect sfx
        private SpellBuff b
        private VertexColor color
        private TimeScale ts
        
        private static Table tb

        private static method onStop takes nothing returns nothing
            local integer id = GetHandleId(GetTriggerUnit())
            local thistype this
            if thistype.tb.has(id) then
                set this = thistype.tb[id]
                call thistype.tb.remove(id)
                if Buff.has(this.caster, this.caster, SpellBuff.typeid) then
                    call this.b.remove()
                endif
                if this.sfx != null then
                    call DestroyEffect(this.sfx)
                    set this.sfx = null
                endif
                call this.color.destroy()
                call this.ts.destroy()
                call ReleaseTimer(this.t)
                set this.caster = null
                set this.t = null
                call this.deallocate()
            endif
        endmethod

        private static method stoneForm takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            set this.b = SpellBuff.add(this.caster, this.caster)
            if this.sfx != null then
                call DestroyEffect(this.sfx)
                set this.sfx = null
            endif
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            local real delay
            set this.caster = GetTriggerUnit()
            set delay = FormDelay(GetUnitAbilityLevel(this.caster, SPELL_ID))
            set this.t = NewTimerEx(this)
            set this.color = VertexColor.create(this.caster, -230, -230, -230, 0)
            set this.color.speed = 230/delay
            set this.ts = TimeScale.create(this.caster, -1.0)
            set this.ts.speed = 2/delay
            set this.sfx = AddSpecialEffectTarget(SFX, this.caster, "origin")
            set thistype.tb[GetHandleId(this.caster)] = this
            call TimerStart(this.t, delay, false, function thistype.stoneForm)
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            set thistype.tb = Table.create()
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call RegisterSpellEndcastEvent(SPELL_ID, function thistype.onStop)
            call SpellBuff.initialize()
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope