scope Pitfall

    globals
        private constant integer SPELL_ID = 'A512'
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
        private constant string SFX = "Models\\Effects\\Pitfall.mdx"
        private constant string SFX_BUFF = "Abilities\\Spells\\Human\\FlameStrike\\FlameStrikeDamageTarget.mdl"
        private constant real TIMEOUT = 1.0
        private constant real SPACING = 100.0
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

    private struct Flame extends array
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
            set this.next = head
            set this.prev = head.prev
            set this.next.prev = this
            set this.prev.next = this
            set this.sfx = AddSpecialEffect(SFX_BUFF, x, y)
        endmethod

        static method head takes nothing returns thistype
            local thistype this = thistype.allocate()
            set this.next = this
            set this.prev = this
            return this
        endmethod

    endstruct

    private struct SpellBuff extends Buff

        readonly Movespeed ms
        readonly Atkspeed as
        private effect sfx
        private timer t
        public real dmg

        private static constant integer RAWCODE = 'D512'
        private static constant integer DISPEL_TYPE = BUFF_NONE
        private static constant integer STACK_TYPE = BUFF_STACK_FULL

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

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod
        implement BuffApply
    endstruct

    struct Pitfall extends array

        private unit caster
        private Flame sfxHead
        private Effect pit
        private real x
        private real y
        private real dmg
        private group g
        private real duration
        private real radius
        private real moveSlow
        private real atkSlow
        private Table tb

        private static group enumG

        private method remove takes nothing returns nothing
            local unit u
            local Flame f = this.sfxHead.next
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
            call this.pit.destroy()
            call this.tb.destroy()
            call ReleaseGroup(this.g)
            set this.g = null
            set this.caster = null
            call this.destroy()
        endmethod

        private static method picked takes nothing returns nothing
            local unit u = GetEnumUnit()
            local SpellBuff b
            local integer id
            if not TargetFilter(u, GetOwningPlayer(global.caster)) or not IsUnitInRangeXY(u, global.x, global.y, global.radius) then
                call GroupRemoveUnit(global.g, u)
                set id = GetHandleId(u)
                if Buff.has(global.caster, u, SpellBuff.typeid) then
                    call Buff(global.tb[id]).remove()
                endif
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
                call GroupEnumUnitsInRange(thistype.enumG, this.x, this.y, this.radius + MAX_COLLISION_SIZE, null)
                set thistype.global = this
                set owner = GetOwningPlayer(this.caster)
                loop
                    set u = FirstOfGroup(thistype.enumG)
                    exitwhen u == null
                    call GroupRemoveUnit(thistype.enumG, u)
                    if IsUnitInRangeXY(u, this.x, this.y, this.radius) and TargetFilter(u, owner) and not IsUnitInGroup(u, this.g) then
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
            local real da
            local real angle
            local real endAngle
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
            set this.pit = Effect.createAnyAngle(SFX, this.x, this.y, 0)
            set this.pit.scale = this.radius/115.0
            set this.sfxHead = Flame.head()
            set da = 2*bj_PI/R2I(2*bj_PI*radius/SPACING)
            if da > bj_PI/3 then
                set da = bj_PI/3
            endif
            set angle = da
            set endAngle = da + 2*bj_PI - 0.0001
            loop
                exitwhen angle >= endAngle
                call Flame.add(this.sfxHead, this.x + this.radius*Cos(angle), this.y + this.radius*Sin(angle))
                set angle = angle + da
            endloop
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod

        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            set thistype.enumG = CreateGroup()
            call SpellBuff.initialize()
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SystemTest.end()
        endmethod

    endstruct

endscope