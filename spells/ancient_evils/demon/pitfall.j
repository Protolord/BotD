scope Pitfall
 
    globals
        private constant integer SPELL_ID = 'A512'
        private constant integer SPELL_BUFF = 'D512'
        private constant integer PITFALL_ID = 0 //None as of now
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
        private constant string SFX_FIRE = "Abilities\\Spells\\Human\\FlameStrike\\FlameStrikeEmbers.mdl"
        private constant string SFX_BUFF = "Abilities\\Spells\\Human\\FlameStrike\\FlameStrikeDamageTarget.mdl"
        private constant real FIRE_SPACING = 60
        private constant real TIMEOUT = 1.0
    endglobals
    
    private function AttackSlow takes integer level returns real
        return 0.0*level + 0.50
    endfunction
    
    private function MoveSlow takes integer level returns real
        return 0.0*level + 0.50
    endfunction
    
    private function DamagePerSecond takes integer level returns real
        return 30.0*level
    endfunction
    
    private function Duration takes integer level returns real
        return 0.0*level + 10.0
    endfunction
    
    private function Radius takes integer level returns real
        return 0.0*level + 300.0
    endfunction
    
    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction
    
    private struct SpellBuff extends Buff
        
        readonly Movespeed ms
        readonly Atkspeed as
        private effect sfx
        private timer t
        public real dmg
        
        method rawcode takes nothing returns integer
            return SPELL_BUFF
        endmethod
        
        method dispelType takes nothing returns integer
            return BUFF_NEGATIVE
        endmethod
        
        method stackType takes nothing returns integer
            return BUFF_STACK_FULL
        endmethod
        
        method onRemove takes nothing returns nothing
            call this.ms.destroy()
            call this.as.destroy()
            call DestroyEffect(this.sfx)
            call ReleaseTimer(this.t)
            set this.sfx = null
            set this.t = null
        endmethod
        
        private static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            if TargetFilter(this.target, GetOwningPlayer(this.source)) then
                call Damage.element.apply(this.source, this.target, this.dmg, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_FIRE)
            else
                call this.remove()
            endif
        endmethod
        
        method onApply takes nothing returns nothing
            set this.ms = Movespeed.create(this.target, 0, 0)
            set this.as = Atkspeed.create(this.target, 0)
            set this.sfx = AddSpecialEffectTarget(SFX_BUFF, this.target, "chest")
            set this.t = NewTimerEx(this)
            call TimerStart(this.t, TIMEOUT, true, function thistype.onPeriod)
        endmethod
        
        implement BuffApply
    endstruct
    
    private struct Fire extends array
        implement Alloc
        
        private effect sfx
        
        readonly thistype next
        readonly thistype prev
        
        method destroy takes nothing returns nothing
            set this.prev.next = this.next
            set this.next.prev = this.prev
            if this.sfx != null then
                call DestroyEffect(this.sfx)
                set this.sfx = null
            endif
            call this.deallocate()
        endmethod
        
        static method add takes thistype head, real x, real y returns nothing
            local thistype this = thistype.allocate()
            set this.sfx = AddSpecialEffect(SFX_FIRE, x, y)
            set this.next = head
            set this.prev = head.prev
            set this.prev.next = this
            set this.next.prev = this
        endmethod
        
        static method head takes nothing returns thistype
            local thistype this = thistype.allocate()
            set this.next = this
            set this.prev = this
            return this
        endmethod
    endstruct
    
    struct Pitfall extends array
        
        private unit caster
        private destructable volc
        private real x
        private real y
        private real dmg
        private group g
        private real duration
        private real radius
        private real moveSlow
        private real atkSlow
        private Table tb
        private Fire sfxHead
        
        private static group enumG
        
        private method remove takes nothing returns nothing
            local Fire f = this.sfxHead.next
            local unit u
            loop
                set u = FirstOfGroup(this.g)
                exitwhen u == null
                call GroupRemoveUnit(this.g, u)
                call Buff(this.tb[GetHandleId(u)]).remove()
            endloop
            loop
                exitwhen f == this.sfxHead
                call f.destroy()
                set f = f.next
            endloop
            call this.sfxHead.destroy()
            call KillDestructable(this.volc)
            call this.tb.destroy()
            call ReleaseGroup(this.g)
            set this.volc = null
            set this.g = null
            set this.caster = null
            call this.destroy()
        endmethod
        
        private static method picked takes nothing returns nothing
            local unit u = GetEnumUnit()
            local SpellBuff b
            if not TargetFilter(u, GetOwningPlayer(global.caster)) or not IsUnitInRangeXY(u, global.x, global.y, global.radius) then
                call GroupRemoveUnit(global.g, u)
                call Buff(global.tb[GetHandleId(u)]).remove()
            endif
            set u = null
        endmethod
        
        private static thistype global
        
        implement CTL
            local unit u
            local SpellBuff b
            local player owner
        implement CTLExpire
            set this.duration = this.duration - CTL_TIMEOUT
            if this.duration > 0 then
                call GroupUnitsInArea(thistype.enumG, this.x, this.y, this.radius)
                set thistype.global = this
                set owner = GetOwningPlayer(this.caster)
                loop
                    set u = FirstOfGroup(thistype.enumG)
                    exitwhen u == null
                    call GroupRemoveUnit(thistype.enumG, u)
                    if TargetFilter(u, owner) and not IsUnitInGroup(u, this.g) then
                        set b = SpellBuff.add(this.caster, u)
                        set b.dmg = this.dmg
                        call b.ms.change(this.moveSlow, 0)
                        call b.as.change(this.atkSlow)
                        set this.tb[GetHandleId(u)] = b
                        call GroupAddUnit(this.g, u)
                    endif
                endloop
                call ForGroup(this.g, function thistype.picked)
            else
                call this.remove()
            endif
        implement CTLNull
            set owner = null
        implement CTLEnd
        
        
        private static method onCast takes nothing returns nothing
            local thistype this = thistype.create()
            local integer lvl
            local real angle
            local real endAngle
            local real da
            set this.caster = GetTriggerUnit()
            set this.g = NewGroup()
            set lvl = GetUnitAbilityLevel(this.caster, SPELL_ID)
            set this.x = GetUnitX(this.caster)
            set this.y = GetUnitY(this.caster)
            set this.duration = Duration(lvl)
            set this.radius = Radius(lvl)
            set this.atkSlow = -AttackSlow(lvl)
            set this.moveSlow = -MoveSlow(lvl)
            set this.dmg = DamagePerSecond(lvl)*TIMEOUT
            set this.tb = Table.create()
            set this.volc = CreateDestructable(PITFALL_ID, this.x, this.y, GetRandomReal(0, 360), this.radius/260, 0)
            call SetDestructableAnimation(this.volc, "birth")
            //Create SFX
            set this.sfxHead = Fire.head()
            set da = 2*bj_PI/R2I(2*bj_PI*this.radius/FIRE_SPACING)
            if da > bj_PI/3 then
                set da = bj_PI/3
            endif
            set angle = da
            set endAngle = da + 2*bj_PI - 0.0001
            loop
                exitwhen angle >= endAngle
                call Fire.add(this.sfxHead, this.x + this.radius*Cos(angle), this.y + this.radius*Sin(angle))
                set angle = angle + da
            endloop
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            set thistype.enumG = CreateGroup()
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope