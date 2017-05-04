scope Feed
 
    globals
        private constant integer SPELL_ID = 'A442'
        private constant integer SACRIFICE_ID = 'A4X1'        
        private constant integer UNIT_ID = 'uSca'
        private constant real PERIMETER = 100.0
        private constant real ANGLE_TOLERANCE = 10.0
        private constant string SFX = "Objects\\Spawnmodels\\Undead\\ImpaleTargetDust\\ImpaleTargetDust.mdl"
        private constant string FEED_SFX1 = "Abilities\\Spells\\Orc\\Devour\\DevourEffectArt.mdl"
        private constant string FEED_SFX2 = "Objects\\Spawnmodels\\Undead\\UndeadBlood\\UndeadBloodCryptFiend.mdl"
    endglobals
    
    private function HealFactor takes integer level returns real
        if level == 11 then
            return 20.0
        endif
        return 1.0*level
    endfunction
    
    private function UnitHP takes integer level returns real
        return 0.0*level + 150.0
    endfunction
    
    private function Duration takes integer level returns real
        return 0.0*level + 10.0
    endfunction
    
    private function NumberOfUnits takes integer level returns integer
        return 0*level + 5
    endfunction
    
    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitAlly(u, p) and GetUnitTypeId(u) != 'uCoc'
    endfunction
    
    struct FeedSacrifice extends array
        
        private unit caster
        private unit target
        
        public static Table tb
        
        private method remove takes nothing returns nothing
            set this.caster = null
            set this.target = null
            call this.destroy()
        endmethod
        
        private static method angleDiff takes real a, real b returns real
            local real c = ModuloReal(RAbsBJ(b - a), 360)
            if c > 180 then
                return 360 - c
            endif
            return c
        endmethod
        
        implement CTL
            local real angle
            local integer id
            local real x1
            local real y1
            local real x2
            local real y2
        implement CTLExpire
            if IsUnitInRange(this.caster, this.target, 128) then
                set x1 = GetUnitX(this.caster)
                set y1 = GetUnitY(this.caster)
                set x2 = GetUnitX(this.target)
                set y2 = GetUnitY(this.target)
                set angle = Atan2(y1 - y2, x1 - x2)*bj_RADTODEG 
                if thistype.angleDiff(GetUnitFacing(this.target), angle) <= ANGLE_TOLERANCE then
                    set id = GetHandleId(this.caster)
                    call Heal.unit(this.caster, this.target, GetWidgetLife(this.caster)*HealFactor(thistype.tb[id]), 1.0, true)
                    call DestroyEffect(AddSpecialEffect(FEED_SFX1, x1, y1))
                    call DestroyEffect(AddSpecialEffect(FEED_SFX2, x2, y2))
                    call thistype.tb.remove(id)
                    call RemoveUnit(this.caster)
                    call this.remove()
                else
                    call IssueImmediateOrderById(this.target, ORDER_stop)
                    call SetUnitFacing(this.target, angle)
                endif
            else
                call IssueTargetOrderById(this.caster, ORDER_healingwave, this.target)
                call this.remove()
            endif
        implement CTLEnd
        
        private static method onCast takes nothing returns nothing
            local thistype this
            if TargetFilter(GetSpellTargetUnit(), GetTriggerPlayer()) then
                set this = thistype.create()
                set this.caster = GetTriggerUnit()
                set this.target = GetSpellTargetUnit()
            endif
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype on " + GetUnitName(GetSpellTargetUnit()))
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SACRIFICE_ID, function thistype.onCast)
            call PreloadSpell(SACRIFICE_ID)
            set thistype.tb = Table.create()
            call SystemTest.end()
        endmethod
        
    endstruct
    
    struct Feed extends array
        
        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local player owner = GetTriggerPlayer()
            local real angle = GetUnitFacing(caster)*bj_DEGTORAD
            local real x = GetUnitX(caster) + 100*Cos(angle)
            local real y = GetUnitY(caster) + 100*Sin(angle)
            local integer lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            local integer i = NumberOfUnits (lvl)
            local real duration = Duration(lvl)
            local real hp = UnitHP(lvl)
            local real scale = 0.85 + lvl/15
            local unit u
            loop
                exitwhen i == 0
                set u = CreateUnit(owner, UNIT_ID, x + GetRandomReal(-PERIMETER, PERIMETER), y + GetRandomReal(-PERIMETER, PERIMETER), GetRandomReal(0, 360))
                call SetUnitAnimation(u, "birth")
                call UnitApplyTimedLife(u, 'BTLF', duration)
                call SetUnitMaxState(u, UNIT_STATE_MAX_LIFE, hp)
                call SetUnitScale(u, scale, 0, 0)
                set FeedSacrifice.tb[GetHandleId(u)] = lvl
                set i = i - 1
            endloop
            call DestroyEffect(AddSpecialEffect(SFX, x, y))
            set u = null
            set caster = null
            set owner = null
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call PreloadUnit(UNIT_ID)
            call FeedSacrifice.init()
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope