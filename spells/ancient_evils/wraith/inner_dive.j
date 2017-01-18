scope InnerDive
    
    globals
        private constant integer SPELL_ID = 'A323'
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
        private constant real RADIUS = 150.0
        private constant real SPEED = 2000.0
        private constant real IMAGE_DURATION = 0.50
        private constant string SFX = "Models\\Effects\\InnerDive.mdx"
    endglobals
    
    private function DamageAmount takes integer level returns real
        if level == 11 then
            return 600.0
        endif
        return 30.0*level
    endfunction
    
    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE)
    endfunction
    
    private struct Image
        
        private real duration
        private unit dummy
        private effect sfx
    
        implement CTLExpire
            set this.duration = this.duration - CTL_TIMEOUT
            if this.duration > 0 then
                call SetUnitVertexColor(this.dummy, 255, 255, 255, R2I(255*this.duration/IMAGE_DURATION))
            else
                call DestroyEffect(this.sfx)
                call RecycleDummy(this.dummy)
                set this.sfx = null
                set this.dummy = null
                call this.destroy()
            endif
        implement CTLEnd
        
        static method add takes string model, real x, real y, real z, real angle, real duration returns thistype
            local thistype this = thistype.create()
            set this.dummy = GetRecycledDummy(x, y, z, angle)
            set this.sfx = AddSpecialEffectTarget(model, this.dummy, "origin")
            set this.duration = duration
            return this
        endmethod
        
    endstruct
    
    struct InnerDive extends array
        
        private unit caster
        private unit dummy
        private effect sfx
        private player owner
        private group affected
        private real dmg
        private real dx
        private real dy
        private real dist
        private real facing
        private string model
        private Phase phase
        
        private static group g
        
        private method remove takes nothing returns nothing
            call this.phase.destroy()
            call ReleaseGroup(this.affected)
            call DestroyEffect(this.sfx)
            call DummyAddRecycleTimer(this.dummy, 1.0)
            set this.caster = null
            set this.sfx = null
            set this.dummy = null
            set this.affected = null
            set this.owner = null
            call this.destroy()
        endmethod
        
        implement CTL
            local real x
            local real y
            local unit u
        implement CTLExpire
            set this.dist = this.dist - SPEED*CTL_TIMEOUT
            if this.dist > 0 then
                set x = GetUnitX(this.caster) + this.dx
                set y = GetUnitY(this.caster) + this.dy
                call SetUnitX(this.dummy, x)
                call SetUnitY(this.dummy, y)
                call SetUnitPosition(this.caster, x, y)
                if x == GetUnitX(this.caster) and y == GetUnitY(this.caster) then
                    call GroupEnumUnitsInRange(thistype.g, x, y, RADIUS, null)
                    loop
                        set u = FirstOfGroup(thistype.g)
                        exitwhen u == null
                        call GroupRemoveUnit(thistype.g, u)
                        if TargetFilter(u, this.owner) and not IsUnitInGroup(u, this.affected) then
                            call Damage.element.apply(this.caster, u, this.dmg, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_SPIRIT)
                            call GroupAddUnit(this.affected, u)
                        endif
                    endloop
                    //Create imagery
                    call Image.add(this.model, x, y, GetUnitFlyHeight(this.caster), this.facing, IMAGE_DURATION)
                else
                    call SetUnitPosition(this.caster, x - this.dx, y - this.dy)
                    call this.remove()
                endif
            else
                call this.remove()
            endif
        implement CTLEnd
        
        private static method onCast takes nothing returns nothing
            local thistype this = thistype.create()
            local real x2 = GetSpellTargetX()
            local real y2 = GetSpellTargetY()
            local real angle
            local real x1
            local real y1
            set this.caster = GetTriggerUnit()
            set this.owner = GetTriggerPlayer()
            set this.model = PlayerStat.get(this.owner).hero.modelPath
            set this.affected = NewGroup()
            set this.dmg = DamageAmount(GetUnitAbilityLevel(this.caster, SPELL_ID))
            set x1 = GetUnitX(this.caster)
            set y1 = GetUnitY(this.caster)
            set angle = Atan2(y2 - y1, x2 - x1)
            set this.dx = SPEED*Cos(angle)*CTL_TIMEOUT
            set this.dy = SPEED*Sin(angle)*CTL_TIMEOUT
            set this.dist = SquareRoot((y2 - y1)*(y2 - y1) + (x2 - x1)*(x2 - x1))
            set this.facing = angle*bj_RADTODEG
            set this.dummy = GetRecycledDummy(x1, y1, GetUnitFlyHeight(this.caster) + 50, this.facing)
            set this.sfx = AddSpecialEffectTarget(SFX, this.dummy, "origin")
            set this.phase = Phase.create(this.caster)
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            set thistype.g = CreateGroup()
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope