scope UnrestrainedDistress  
  
    //Configuration
    globals
        private constant integer SPELL_ID = 'A124'
        private constant integer DISTRESS_BUFF = 'a124'
        private constant integer DISTRESS_SLEEP_SPELL = 'D124'
        private constant integer DISTRESS_SLEEP_BUFF = 'd124'
        private constant string SLEEP_SFX = "Abilities\\Spells\\Undead\\Sleep\\SleepSpecialArt.mdl"
    endglobals
    
    //Damage per second on sleeping units
    private function DamagePerSecond takes integer level returns real
        return 0.0*level + 75.0
    endfunction
    
    //Damage per second on sleeping units
    private function SleepDuration takes integer level returns real
        if level == 11 then
            return 25.0
        endif
        return 1.0*level + 4.0
    endfunction
    
    private function BonusSpeed takes integer level returns real
        if level == 11 then
            return 0.3
        endif
        return 0.02*level
    endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction
    //End configuration
    
    private struct Sleep extends array
        implement Alloc
        
        private unit caster
        private unit target
        private unit u
        private real dmg
        private real duration
        private real time
        private boolean new
        
        private thistype next
        private thistype prev
        
        private static timer t
        private static Table tb
        
        private method destroy takes nothing returns nothing
            set this.next.prev = this.prev
            set this.prev.next = this.next
            if thistype(0).next == 0 then
                call ReleaseTimer(thistype.t)
                call PauseTimer(thistype.t)
                set thistype.t = null
            endif
            call thistype.tb.remove(GetHandleId(this.target))
            call UnitRemoveAbility(this.target, DISTRESS_SLEEP_BUFF)
            call UnitRemoveAbility(this.u, DISTRESS_SLEEP_SPELL)
            call RecycleDummy(this.u)
            set this.u = null
            set this.caster = null
            set this.target = null
            call this.deallocate()
        endmethod
        
        private method update takes nothing returns nothing
            local real hp
            set this.time = this.time - CTL_TIMEOUT
            set this.duration = this.duration - CTL_TIMEOUT
            if GetUnitAbilityLevel(this.target, DISTRESS_SLEEP_BUFF) > 0 and this.duration > 0 then
                if this.time <= 0 then
                    set this.time = this.time + 1.0
                    set hp = GetWidgetLife(this.target) - this.dmg
                    call FloatingTextSplat(Element.string(DAMAGE_ELEMENT_DARK) + I2S(R2I(this.dmg)) + "|r", this.target, 1.0).setVisible(GetLocalPlayer() == GetOwningPlayer(this.caster) and IsUnitVisible(this.target, GetLocalPlayer()))
                    if hp > 0.406 then
                        call SetWidgetLife(this.target, hp)
                    else
                        call Damage.kill(this.caster, this.target)
                    endif
                endif
            else
                call this.destroy()
            endif
        endmethod
        
        private static method pickAll takes nothing returns nothing
            local thistype this = thistype(0).next
            loop
                exitwhen this == 0
                call this.update()
                set this = this.next
            endloop
        endmethod
        
        private static method apply takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            if GetUnitAbilityLevel(this.target, DISTRESS_SLEEP_BUFF) > 0 then
                call ReleaseTimer(GetExpiredTimer())
                if this.new then
                    set this.next = thistype(0)
                    set this.prev = thistype(0).prev
                    set this.next.prev = this
                    set this.prev.next = this
                    if this.prev == 0 then
                        set thistype.t = NewTimer()
                        call TimerStart(thistype.t, CTL_TIMEOUT, true, function thistype.pickAll)
                    endif
                endif
            else
                call IssueImmediateOrderById(this.target, ORDER_stop)
                call IssueTargetOrderById(this.u, ORDER_sleep, this.target)
            endif
        endmethod
        
        static method add takes unit caster, unit target, integer level returns thistype
            local integer id = GetHandleId(target)
            local thistype this
            if thistype.tb.has(id) then
                set this = thistype.tb[id]
                set this.new = false
                call SetUnitX(this.u, GetUnitX(target))
                call SetUnitY(this.u, GetUnitY(target))
            else
                set this = thistype.allocate()
                set thistype.tb[id] = this
                set this.new = true
                set this.target = target
                set this.u = GetRecycledDummyAnyAngle(GetUnitX(target), GetUnitY(target), 0)
                call PauseUnit(this.u, false)
                call SetUnitOwner(this.u, GetOwningPlayer(target), true)
                call UnitAddAbility(this.u, DISTRESS_SLEEP_SPELL)
            endif
            set this.duration = SleepDuration(level)
            set this.dmg = DamagePerSecond(level)
            set this.time = 1.0
            set this.caster = caster
            call DestroyEffect(AddSpecialEffectTarget(SLEEP_SFX, this.target, "origin"))
            call IssueImmediateOrderById(this.target, ORDER_stop)
            call IssueTargetOrderById(this.u, ORDER_sleep, this.target)
            call TimerStart(NewTimerEx(this), 0.01, true, function thistype.apply)
            return this
        endmethod
        
        static method init takes nothing returns nothing
            set thistype.tb = Table.create()
        endmethod
        
    endstruct
    
    struct UnrestrainedDistress extends array
        
        private unit caster
		private integer lvl
        private Movespeed ms
        private Invisible inv
        
        private static Table tb
        
        private static method onDamage takes nothing returns nothing
            local integer id = GetHandleId(Damage.source)
            if Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.coded and thistype.tb.has(id) then
                if TargetFilter(Damage.target, GetOwningPlayer(Damage.source)) then
                    call Sleep.add(Damage.source, Damage.target, thistype(thistype.tb[id]).lvl)
                endif
                call UnitRemoveAbility(Damage.source, DISTRESS_BUFF)
            endif
        endmethod
        
        private method remove takes nothing returns nothing
            call thistype.tb.remove(GetHandleId(this.caster))
            call this.inv.destroy()
            call this.ms.destroy()
            set this.caster = null
            call this.destroy()
        endmethod
        
        implement CTLExpire
            if GetUnitAbilityLevel(this.caster, DISTRESS_BUFF) == 0 then
                call this.remove()
            endif
        implement CTLEnd
        
        private static method onCast takes nothing returns nothing
			local integer id = GetHandleId(GetTriggerUnit())
            local thistype this
            if thistype.tb.has(id) then
				set this = thistype.tb[id]
			else
                set this = thistype.create()
                set this.caster = GetTriggerUnit()
                set this.inv = Invisible.create(this.caster, 0)
                set thistype.tb[id] = this
            endif
			set this.lvl = GetUnitAbilityLevel(this.caster, SPELL_ID)
			set this.ms = Movespeed.create(this.caster, BonusSpeed(this.lvl), 0)
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call PreloadSpell(DISTRESS_SLEEP_SPELL)
            call Damage.register(function thistype.onDamage)
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
			set thistype.tb = Table.create()
            call Sleep.init()
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope