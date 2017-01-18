scope EssenceOfEvil
    
    globals
        private constant integer SPELL_ID = 'A314'
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
        private constant real SPEED = 1000.0
        private constant string SFX = "Models\\Effects\\EssenceOfEvil.mdx"
        private constant real MINISTUN = 0.1
        private constant real BREAK_DISTANCE = 150.0
    endglobals
    
    private function DamageAmount takes integer level returns real
        if level == 11 then
            return 800.0
        endif
        return 40.0*level
    endfunction
    
    struct EssenceOfEvil extends array
        
        private unit target
        private real dist
        private real angle
        private real x
        private real y
        private real dx
        private real dy
        private unit dummy
        private effect sfx
        private PathingOff pathing
        
        implement CTLExpire
            set this.dist = this.dist - SPEED*CTL_TIMEOUT
            if this.dist > 0 and IsUnitInRangeXY(this.target, this.x, this.y, BREAK_DISTANCE) then
                set this.x = this.x + this.dx
                set this.y = this.y + this.dy
                call SetUnitX(this.target, this.x)
                call SetUnitY(this.target, this.y)
                call SetUnitX(this.dummy, this.x)
                call SetUnitY(this.dummy, this.y)
            else
                call this.pathing.destroy()
                call DestroyEffect(this.sfx)
                call DummyAddRecycleTimer(this.dummy, 1.0)
                set this.sfx = null
                set this.dummy = null
                set this.target = null
                call this.destroy()
            endif
        implement CTLEnd
        
        private static method onCast takes nothing returns nothing
            local thistype this = thistype.create()
            local unit caster = GetTriggerUnit()
            local real angle
            local real x1
            local real y1
            set this.target = GetSpellTargetUnit()
            set this.pathing = PathingOff.create(this.target)
            call Damage.element.apply(caster, this.target, DamageAmount(GetUnitAbilityLevel(caster, SPELL_ID)), ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_SPIRIT)
            call Stun.create(this.target, MINISTUN, false)
            set x1 = GetUnitX(caster)
            set y1 = GetUnitY(caster)
            set this.x = GetUnitX(this.target)
            set this.y = GetUnitY(this.target)
            set this.dist = 0.5*SquareRoot((this.x - x1)*(this.x - x1) + (this.y - y1)*(this.y - y1)) 
            set angle = Atan2(y1 - this.y, x1 - this.x)
            set this.dx = SPEED*Cos(angle)*CTL_TIMEOUT
            set this.dy = SPEED*Sin(angle)*CTL_TIMEOUT
            set this.dummy = GetRecycledDummy(this.x, this.y, 5, angle*bj_RADTODEG + 180.0)
            set this.sfx = AddSpecialEffectTarget(SFX, this.dummy, "origin")
            set caster = null
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype on " + GetUnitName(GetSpellTargetUnit()))
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope