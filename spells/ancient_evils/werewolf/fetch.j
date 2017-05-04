scope Fetch

    globals
        private constant integer SPELL_ID = 'A233'
        private constant integer BUFF_ID = 'B233'
        private constant string SFX = ""
        private constant string SFX_TARGET = "Models\\Effects\\FetchTarget.mdx"
        private constant real NODE_RADIUS = 400
        private constant real TIMEOUT = 0.05
    endglobals
    
    private function Radius takes integer level returns real
        return 1000.0*level
    endfunction
    
    private function Duration takes integer level returns real
        if level == 11 then
            return 15.0
        endif
        return 5.00
    endfunction
    
    private function TargetFilter takes unit u, player owner returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, owner) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE) and not IsUnitType(u, UNIT_TYPE_STRUCTURE)
    endfunction
    
    private struct SightSource
        
        readonly unit u
        readonly unit target
        private effect sfx
        
        readonly thistype next
        readonly thistype prev
        
        method destroy takes nothing returns nothing
            set this.prev.next = this.next
            set this.next.prev = this.prev
            if this.u != null then
                call UnitClearBonus(this.u, BONUS_SIGHT_RANGE)
                call UnitRemoveAbility(this.u, 'ATSS')
                call RecycleDummy(this.u)
                set this.u = null
            endif
            if this.sfx != null then
                call DestroyEffect(this.sfx)
            endif
            set this.target = null
            call this.deallocate()
        endmethod
        
        static method create takes thistype head, unit target, player owner returns thistype
            local thistype this = thistype.allocate()
            local string s = SFX_TARGET
            set this.target = target
            set this.u = GetRecycledDummyAnyAngle(GetUnitX(target), GetUnitY(target), 0)
            call PauseUnit(this.u, false)
            call SetUnitOwner(this.u, owner, false)
            call UnitSetBonus(this.u, BONUS_SIGHT_RANGE, R2I(NODE_RADIUS))
            call UnitAddAbility(this.u, 'ATSS')
            if IsPlayerEnemy(owner, GetLocalPlayer()) then
                set s = ""
            endif
            set this.sfx = AddSpecialEffectTarget(s, target, "origin")
            set this.next = head.next
            set this.prev = head
            set this.next.prev = this
            set this.prev.next = this
            return this
        endmethod
        
        static method head takes nothing returns thistype
            local thistype this = thistype.allocate()
            set this.next = this
            set this.prev = this
            return this
        endmethod
        
    endstruct
    
    private struct SpellBuff extends Buff

        public SightSource ss
        public FlySight fs
        public real radius
        private player owner
        private group visible
        private effect sfx

        private static group g

        private static constant integer RAWCODE = 'B233'
        private static constant integer DISPEL_TYPE = BUFF_POSITIVE
        private static constant integer STACK_TYPE = BUFF_STACK_NONE
        
        method onRemove takes nothing returns nothing
            local SightSource sight = this.ss.next
            call this.pop()
            if this.ss > 0 then
                //Destroy all SightSource
                loop
                    exitwhen sight == this.ss
                    call sight.destroy()
                    set sight = sight.next
                endloop
                call this.ss.destroy()
                set this.ss = 0
            endif
            if this.fs > 0 then
                call this.fs.destroy()
                set this.fs = 0
            endif
            call ReleaseGroup(this.visible)
            call DestroyEffect(this.sfx)
            set this.sfx = null
            set this.visible = null
            set this.owner = null
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this = thistype(0).next
            local unit u
            local SightSource ss
            local boolean b
            loop
                exitwhen this == 0
                if this.ss > 0 then
                    call GroupUnitsInArea(thistype.g, GetUnitX(this.target), GetUnitY(this.target), this.radius)
                    set b = this.owner != GetOwningPlayer(this.target)
                    if b then
                        set this.owner = GetOwningPlayer(this.target)
                    endif
                    loop
                        set u = FirstOfGroup(thistype.g)
                        exitwhen u == null
                        call GroupRemoveUnit(thistype.g, u)
                        if not IsUnitInGroup(u, this.visible) and TargetFilter(u, this.owner) then
                            call GroupAddUnit(this.visible, u)
                            call SightSource.create(this.ss, u, this.owner)
                        endif
                    endloop
                    //Update SightSources
                    set ss = this.ss.next
                    loop
                        exitwhen ss == this.ss
                        if IsUnitInRange(this.target, ss.target, this.radius) and TargetFilter(ss.target, this.owner) then
                            call SetUnitX(ss.u, GetUnitX(ss.target))
                            call SetUnitY(ss.u, GetUnitY(ss.target))
                            if b then
                                call SetUnitOwner(ss.u, this.owner, false)
                            endif
                        else
                            call GroupRemoveUnit(this.visible, ss.target)
                            call ss.destroy()
                        endif
                        set ss = ss.next
                    endloop
                endif
                set this = this.next
            endloop
        endmethod

        implement List
        
        method onApply takes nothing returns nothing
            set this.sfx = AddSpecialEffectTarget(SFX, this.target, "overhead")
            set this.owner = GetOwningPlayer(this.target)
            set this.visible = NewGroup()
            if GetUnitAbilityLevel(this.source, SPELL_ID) < 11 then
                set this.ss = SightSource.head()
            endif
            call this.push(TIMEOUT)
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
            set thistype.g = CreateGroup()
        endmethod
        
        implement BuffApply
    endstruct

    struct Fetch extends array
        
        private static method onCast takes nothing returns nothing
            local unit u = GetTriggerUnit()
            local integer lvl = GetUnitAbilityLevel(u, SPELL_ID)
            local SpellBuff b = SpellBuff.add(u, u)
            local SightSource sight
            set b.duration = Duration(lvl)
            set b.radius = Radius(lvl)
            if lvl == 11 then
                if b.ss > 0 then
                    set sight = b.ss.next
                    //Destroy all SightSource
                    loop
                        exitwhen sight == b.ss
                        call sight.destroy()
                        set sight = sight.next
                    endloop
                    call b.ss.destroy()
                    set b.ss = 0
                endif
                set b.fs = FlySight.create(u, GLOBAL_SIGHT)
            endif
            set u = null
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call SpellBuff.initialize()
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope