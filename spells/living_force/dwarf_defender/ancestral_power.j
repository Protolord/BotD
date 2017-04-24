scope AncestralPower

    globals
        private constant integer SPELL_ID = 'AH34'
        private constant string SFX = "Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl"
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
    endglobals
    
    //In Percent
    private function MaxHPDamage takes integer level returns real
        return 5.0*level
    endfunction
    
    private function StompInterval_Distance takes integer level returns real
        return 150.0 + 0.0*level
    endfunction

    private function StompInterval_Time takes integer level returns real
        return 0.25 + 0.0*level
    endfunction

    private function StompRadius takes integer level returns real
        return 150.0 + 0.0*level
    endfunction

    private function Range takes integer level returns real
        return 750.0 + 0.0*level
    endfunction
    
    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction
    
    struct AncestralPower extends array
        implement Alloc 
        
        private unit caster
        private player owner 
        private real x 
        private real y 
        private real dx
        private real dy
        private real dxy
        private real dist
        private real range
        private real radius
        private real dmgFactor
        private timer t

        private static group g

        private method destroy takes nothing returns nothing
            call ReleaseTimer(this.t)
            set this.t = null
            set this.caster = null
            set this.owner = null
            call this.deallocate()
        endmethod

        private method stomp takes nothing returns nothing
            local unit u
            call GroupUnitsInArea(thistype.g, this.x, this.y, this.radius)
            call DestroyEffect(AddSpecialEffect(SFX, this.x, this.y))
            loop
                set u = FirstOfGroup(thistype.g)
                exitwhen u == null
                call GroupRemoveUnit(thistype.g, u)
                if TargetFilter(u, this.owner) then
                    call Damage.element.apply(this.caster, u, this.dmgFactor*GetUnitState(u, UNIT_STATE_MAX_LIFE)/100.0, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_EARTH)
                endif
            endloop
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            set this.x = this.x + this.dx 
            set this.y = this.y + this.dy 
            set this.dist = this.dist + this.dxy
            if this.dist <= this.range then
                call this.stomp()
            else
                call this.destroy()
            endif
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            local real tx = GetSpellTargetX()
            local real ty = GetSpellTargetY()
            local real angle
            local integer lvl
            set this.caster = GetTriggerUnit()
            set this.owner = GetTriggerPlayer()
            set lvl = GetUnitAbilityLevel(this.caster, SPELL_ID)
            set this.dmgFactor = MaxHPDamage(lvl)
            set this.range = Range(lvl)
            set this.dist = 0
            set this.radius = StompRadius(lvl)
            set this.x = GetUnitX(this.caster)
            set this.y = GetUnitY(this.caster)
            set angle = Atan2(ty - this.y, tx - this.x)
            set this.dxy = StompInterval_Distance(lvl)
            set this.dx = this.dxy*Cos(angle)
            set this.dy = this.dxy*Sin(angle)
            set this.t = NewTimerEx(this)
            call this.stomp()
            call TimerStart(this.t, StompInterval_Time(lvl), true, function thistype.onPeriod)
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            set thistype.g = CreateGroup()
            call SystemTest.end()
        endmethod
        
    endstruct
endscope