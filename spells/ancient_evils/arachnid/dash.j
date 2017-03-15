scope Dash
    
    globals
        private constant integer SPELL_ID = 'A411'
        private constant real SPEED = 2000.0
        private constant real HIT_DISTANCE = SPEED*CTL_TIMEOUT
        private constant string MISSILE_MODEL = "Models\\Effects\\Dash.mdx"
        private constant string SFX = "Abilities\\Spells\\Orc\\StasisTrap\\StasisTotemTarget.mdl"
    endglobals
    
    private function SlowDuration takes integer level returns real
        if level == 11 then
            return 20.0
        endif
        return 1.0*level
    endfunction
    
    private function Slow takes integer level returns real
        if level == 11 then
            return 0.5
        endif
        return 0.0*level + 0.5
    endfunction
    
    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE)
    endfunction
    
    //If false, dashing will immedietly stop
    private function ChaseFilter takes unit u returns boolean
        return true
    endfunction
    
    private struct SpellBuff extends Buff
    
        private effect sfx
        private Movespeed ms

        private static constant integer RAWCODE = 'D411'
        private static constant integer DISPEL_TYPE = BUFF_NEGATIVE
        private static constant integer STACK_TYPE = BUFF_STACK_PARTIAL
        
        method onRemove takes nothing returns nothing
            call DestroyEffect(this.sfx)
            call this.ms.destroy()
            set this.sfx = null
        endmethod
        
        
        method onApply takes nothing returns nothing
            set this.sfx = AddSpecialEffectTarget(SFX, this.target, "overhead")
            set this.ms = Movespeed.create(this.target, -Slow(GetUnitAbilityLevel(this.source, SPELL_ID)), 0)
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod
        
        implement BuffApply
    endstruct
    
    struct Dash extends array
        
        private unit caster
        private unit target
        private unit dummy
        private integer lvl
        private effect sfx
        private Phase phase
        
        private method remove takes nothing returns nothing
            call this.phase.destroy()
            call DestroyEffect(this.sfx)
            call DummyAddRecycleTimer(this.dummy, 1.0)
            set this.caster = null
            set this.sfx = null
            set this.dummy = null
            call this.destroy()
        endmethod
        
        implement CTL
            local real x1
            local real y1
            local real x2
            local real y2
            local real angle
            local unit u
            local SpellBuff b
        implement CTLExpire
            if ChaseFilter(this.target) then
                if IsUnitInRange(this.caster, this.target, HIT_DISTANCE) then
                    if not SpellBlock.has(this.target) and TargetFilter(this.target, GetOwningPlayer(this.caster)) then
                        set b = SpellBuff.add(this.caster, this.target)
                        set b.duration = SlowDuration(this.lvl)
                    endif
                    call this.remove()
                else
                    set x1 = GetUnitX(this.caster)
                    set y1 = GetUnitY(this.caster)
                    set x2 = GetUnitX(this.target)
                    set y2 = GetUnitY(this.target)
                    set angle = Atan2(y2 - y1, x2 - x1)
                    set x1 = x1 + CTL_TIMEOUT*SPEED*Cos(angle)
                    set y1 = y1 + CTL_TIMEOUT*SPEED*Sin(angle)
                    call SetUnitX(this.dummy, x1)
                    call SetUnitY(this.dummy, y1)
                    call SetUnitFacing(this.dummy, GetUnitFacing(this.caster))
                    call SetUnitPosition(this.caster, x1, y1)
                    if not(x1 == GetUnitX(this.caster) and y1 == GetUnitY(this.caster)) then
                        call this.remove()
                    endif
                endif
            else
                call this.remove()
            endif
        implement CTLEnd
        
        private static method onCast takes nothing returns nothing
            local thistype this = thistype.create()
            set this.caster = GetTriggerUnit()
            set this.target = GetSpellTargetUnit()
            set this.lvl = GetUnitAbilityLevel(this.caster, SPELL_ID)
            set this.dummy = GetRecycledDummy(GetUnitX(this.caster), GetUnitY(this.caster), GetUnitFlyHeight(this.caster) + 50, GetUnitFacing(this.caster))
            set this.sfx = AddSpecialEffectTarget(MISSILE_MODEL, this.dummy, "origin")
            set this.phase = Phase.create(this.caster)
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype on " + GetUnitName(GetSpellTargetUnit()))
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope