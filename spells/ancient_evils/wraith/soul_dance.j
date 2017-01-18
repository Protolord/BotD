scope SoulDance  
 
    globals
        private constant integer SPELL_ID = 'A333'
        private constant integer SPELL_RELEASE = 'T333'
        private constant real DISTANCE = 100.0
        private constant real ANGULAR_SPEED = 120  //In degrees per second
        private constant string SFX = "Models\\Effects\\SoulDance.mdx"
    endglobals
    
    private function Speed takes integer level returns real
        return 0.0*level + 522.0
    endfunction
    
    private function NumberOfSouls takes integer level returns integer
        if level == 11 then
            return 1
        endif
        return 0*level + 4
    endfunction
    
    private function Duration takes integer level returns real
        return 0.0*level + 20.0
    endfunction
    
    private function SightRadius takes integer level returns real
        if level == 11 then
            return GLOBAL_SIGHT
        endif
        return 150.0*level
    endfunction
    
    private struct Soul extends array
        implement Alloc
        
        public boolean released
        public real angle
        readonly Missile m
        
        private TrueSight ts
        private FlySight fs
        
        readonly thistype next
        readonly thistype prev
        
        method destroy takes nothing returns nothing
            set this.prev.next = this.next
            set this.next.prev = this.prev
            if this.ts != 0 then
                call this.ts.destroy()
                set this.ts = 0
            endif
            if this.fs != 0 then
                call this.fs.destroy()
                set this.fs = 0
            endif
            if this.m != 0 then
                call this.m.destroy()
                set this.m = 0
            endif
            call this.deallocate()
        endmethod
        
        static method create takes SoulDance sd, thistype head returns thistype
            local thistype this = thistype.allocate()
            local real radius = SightRadius(sd.lvl)
            set this.released = false
            set this.m = Missile.create()
            set this.m.model = SFX
            call this.m.render()
            call SetUnitScale(this.m.u, 0.5 + I2R(sd.lvl)/10, 0, 0)
            call SetUnitOwner(this.m.u, sd.owner, false)
            set this.ts = TrueSight.create(this.m.u, radius)
            set this.fs = FlySight.create(this.m.u, radius)
            set this.next = head
            set this.prev = head.prev
            set this.prev.next = this
            set this.next.prev = this
            return this
        endmethod
        
        static method head takes nothing returns thistype
            local thistype this = thistype.allocate()
            set this.next = this
            set this.prev = this
            set this.released = false
            return this
        endmethod
        
    endstruct
    
    struct SoulDance extends array
        
        private unit caster
        private integer num
        private real diff   //in radians
        readonly player owner
        readonly real duration
        readonly integer lvl
        
        private Soul head
        
        private static Table tb
        
        private static constant real OFFSET_SPEED = ANGULAR_SPEED*bj_DEGTORAD*CTL_TIMEOUT
        
        method remove takes nothing returns nothing
            local Soul s = this.head.next
            loop
                exitwhen s == this.head
                call s.destroy()
                set s = s.next
            endloop
            call this.head.destroy()
            call thistype.tb.remove(GetHandleId(this.caster))
            if GetUnitAbilityLevel(this.caster, SPELL_RELEASE) > 0 then
                call UnitRemoveAbility(this.caster, SPELL_RELEASE)
                call SetPlayerAbilityAvailable(this.owner, SPELL_ID, true)
            endif
            set this.caster = null
            set this.owner = null
            call this.destroy()
        endmethod
        
        implement CTL
            local real x
            local real y
            local real z
            local Soul s
        implement CTLExpire
            set this.duration = this.duration - CTL_TIMEOUT
            if this.duration > 0 then
                set x = GetUnitX(this.caster)
                set y = GetUnitY(this.caster)
                set z = GetUnitZ(this.caster)
                set s = this.head.next
                loop
                    exitwhen s == this.head
                    if not s.released then
                        set s.angle = s.angle + thistype.OFFSET_SPEED
                        call s.m.move(x + DISTANCE*Cos(s.angle), y + DISTANCE*Sin(s.angle), z)
                    endif
                    set s = s.next
                endloop
            else
                call this.remove()
            endif
        implement CTLEnd
        
        private static method onRelease takes nothing returns nothing
            local thistype this = thistype.tb[GetHandleId(GetTriggerUnit())]
            local Soul s = this.head.next
            local real x2 = GetSpellTargetX()
            local real y2 = GetSpellTargetY()
            loop
                exitwhen not s.released or s == this.head
                set s = s.next
            endloop
            if s != this.head then
                call s.m.targetXYZ(x2, y2, GetPointZ(x2, y2))
                set s.m.speed = Speed(this.lvl)
                call s.m.launch()
                set s.released = true
                set this.num = this.num - 1
                if this.num == 0 then
                    call UnitRemoveAbility(this.caster, SPELL_RELEASE)
                    call SetPlayerAbilityAvailable(this.owner, SPELL_ID, true)
                endif
            endif
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " released a thistype")
        endmethod
        
        private static method onCast takes nothing returns nothing
            local integer id = GetHandleId(GetTriggerUnit())
            local thistype this
            local Soul soul
            local integer i
            if thistype.tb.has(id) then
                call thistype(thistype.tb[id]).remove()
            endif
            set this = thistype.create()
            set this.caster = GetTriggerUnit()
            set this.owner = GetTriggerPlayer()
            set this.head = Soul.head()
            set this.lvl = GetUnitAbilityLevel(this.caster, SPELL_ID)
            set this.num = NumberOfSouls(this.lvl)
            set this.duration = Duration(this.lvl)
            set i = this.num
            loop
                exitwhen i == 0
                set soul = Soul.create(this, this.head)
                set soul.angle = 0.5*bj_PI*i
                set i = i - 1
            endloop
            //Change ability
            set thistype.tb[id] = this
            call SetPlayerAbilityAvailable(this.owner, SPELL_ID, false)
            call UnitAddAbility(this.caster, SPELL_RELEASE)
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call RegisterSpellEffectEvent(SPELL_RELEASE, function thistype.onRelease)
            set thistype.tb = Table.create()
            call PreloadSpell(SPELL_RELEASE)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope