scope Meteor

    globals
        private constant integer SPELL_ID = 'AH54'
        private constant string MISSILE_MODEL = "Models\\Effects\\Meteor.mdx"
        private constant string SFX_EXPLODE = "Models\\Effects\\MeteorExplosion.mdx"
        private constant real HEIGHT = 1500.0
        private constant real SOURCE_OFFSET = 500.0
        private constant real SPEED = 1000.0
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
    endglobals
    
    //In Percent
    private function MaxHPDamage takes integer level returns real
        return 10.0 + 0.0*level
    endfunction
    
    //In Percent
    private function ExtraMaxHPDamage takes integer level returns real
        return 0.4*level - 0.3
    endfunction

    private function Radius takes integer level returns real
        return 250.0 + 0.0*level
    endfunction
    
    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction
    
    struct Meteor extends array

        private unit caster
        private player owner
        private Missile m
        private integer lvl

        private static group g

        private method destroy takes nothing returns nothing
            set this.caster = null
            set this.owner = null
            call this.m.destroy()
        endmethod

        private static method onHit takes nothing returns nothing
            local thistype this = thistype(Missile.getHit())
            local real dmgFactor = MaxHPDamage(this.lvl)
            local real extraDmgFactor = ExtraMaxHPDamage(this.lvl)
            local Burn b
            local unit u
            call GroupUnitsInArea(thistype.g, this.m.x, this.m.y, Radius(this.lvl))
            call DestroyEffect(AddSpecialEffect(SFX_EXPLODE, this.m.x, this.m.y))
            loop
                set u = FirstOfGroup(thistype.g)
                exitwhen u == null 
                call GroupRemoveUnit(thistype.g, u)
                if TargetFilter(u, this.owner) then
                    set b = Buff.get(null, u, Burn.typeid)
                    if b > 0 then
                        call BJDebugMsg("extraDmgFactor = " + R2S(extraDmgFactor))
                        call BJDebugMsg("duration left = " + R2S(b.duration))
                        call BJDebugMsg("extraDmg% = " + R2S(extraDmgFactor*b.duration))
                        call Damage.element.apply(this.caster, u, (dmgFactor + extraDmgFactor*b.duration)*GetUnitState(u, UNIT_STATE_MAX_LIFE)/100.0, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_FIRE)
                    else
                        call Damage.element.apply(this.caster, u, dmgFactor*GetUnitState(u, UNIT_STATE_MAX_LIFE)/100.0, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_FIRE)
                    endif
                endif
            endloop
            call this.destroy()
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype(Missile.create())
            local real tx = GetSpellTargetX()
            local real ty = GetSpellTargetY()
            local real a
            set this.caster = GetTriggerUnit()
            set this.owner = GetTriggerPlayer()
            set this.lvl = GetUnitAbilityLevel(this.caster, SPELL_ID)
            set a = Atan2(GetUnitY(this.caster) - ty, GetUnitX(this.caster) - tx)
            set this.m = Missile(this)
            set this.m.autohide = false
            call this.m.sourceXYZ(tx + SOURCE_OFFSET*Cos(a), ty + SOURCE_OFFSET*Sin(a), HEIGHT + GetRandomReal(-300, 300))
            call this.m.targetXYZ(tx, ty, GetPointZ(tx, ty))
            set this.m.speed = SPEED
            set this.m.model = MISSILE_MODEL
            call this.m.registerOnHit(function thistype.onHit)
            call this.m.launch()
            set this.m.scale = 0.75
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