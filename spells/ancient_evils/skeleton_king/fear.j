scope Fear
    
    globals
        private constant integer SPELL_ID = 'A724'
        private constant integer BUFF_ID = 'B724'
        private constant real TIMEOUT = 0.125
		private constant real ANGLE_TOLERANCE = 30.0 //In degrees
        private constant string BUFF_SFX = "Models\\Effects\\FearTarget.mdx"
    endglobals

    private function Range takes integer level returns real
        return 0.0*level + 500.0
    endfunction
	
	private function DamageReduction takes integer level returns real
		if level == 11 then
			return 60.0
		endif
		return 3.0*level
	endfunction

    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction
	
	private struct SpellBuff extends Buff
	
		private effect sfx
        private AtkDamagePercent adp

        private static constant integer RAWCODE = 'D724'
        private static constant integer DISPEL_TYPE = BUFF_NEGATIVE
        private static constant integer STACK_TYPE = BUFF_STACK_FULL
        
        method onRemove takes nothing returns nothing
            call DestroyEffect(this.sfx)
            call this.adp.destroy()
            set this.sfx = null
        endmethod
        
        method onApply takes nothing returns nothing
            set this.adp = AtkDamagePercent.create(this.target, -DamageReduction(GetUnitAbilityLevel(this.source, SPELL_ID))/100)
            set this.sfx = AddSpecialEffectTarget(BUFF_SFX, this.target, "origin")
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod
        
        implement BuffApply
	endstruct
    
    struct Fear extends array
        implement Alloc
        
        private unit u
        private real range
		private group affected
        
        private static Table tb
        private static group g
		private static thistype global
		private static real tempX
		private static real tempY
        
		private static method picked takes nothing returns nothing
			local thistype this = thistype.global
			local unit u = GetEnumUnit()
			local SpellBuff b = Buff.get(this.u, u, SpellBuff.typeid)
			local real angle
			if b > 0  then
				set angle = Atan2(GetUnitY(u) - tempY, GetUnitX(u) - tempX)*bj_RADTODEG
				if angle < 0 then
					set angle = angle + 360
				endif
				if RAbsBJ(GetUnitFacing(u) - angle) > ANGLE_TOLERANCE or not UnitAlive(this.u) then
					call b.remove()
					call GroupRemoveUnit(this.affected, u)
				endif
			endif
			set u = null
		endmethod
		
        private static method onPeriod takes nothing returns nothing
            local thistype this = thistype.top
            local player p
            local real angle
            local unit u
            loop
                exitwhen this == 0
                set tempX = GetUnitX(this.u)
                set tempY = GetUnitY(this.u)
                set thistype.global = this
                call ForGroup(this.affected, function thistype.picked)
                if UnitAlive(this.u) then
                    call GroupEnumUnitsInRange(thistype.g, tempX, tempY, this.range, null)
                    set p = GetOwningPlayer(this.u)
                    loop
                        set u = FirstOfGroup(thistype.g)
                        exitwhen u == null
                        call GroupRemoveUnit(thistype.g, u)
                        if TargetFilter(u, p) and not Buff.has(this.u, u, SpellBuff.typeid) and IsUnitVisible(this.u, GetOwningPlayer(u)) then
                            set angle = Atan2(tempY - GetUnitY(u), tempX - GetUnitX(u))*bj_RADTODEG
                            if angle < 0 then
                                set angle = angle + 360
                            endif
                            if RAbsBJ(GetUnitFacing(u) - angle) <= ANGLE_TOLERANCE then
                                call SpellBuff.add(this.u, u)
                                call GroupAddUnit(this.affected, u)
                            endif
                        endif
                    endloop
                endif
                set this = this.next
            endloop
        endmethod

        implement Stack
        
        private static method ultimates takes nothing returns boolean
            local unit u = GetTriggerUnit()
            local integer id = GetHandleId(u)
            local thistype this
            if thistype.tb.has(id) then
                set this = thistype.tb[id]
                set this.range = Range(11)
            endif
            set u = null
            return false
        endmethod
        
        private static method learn takes nothing returns nothing   
            local thistype this
            local unit u
            local integer id
            local integer lvl
            if GetLearnedSkill() == SPELL_ID then
                set u = GetTriggerUnit()
                set id = GetHandleId(u)
                if not thistype.tb.has(id) then
                    set this = thistype.allocate()
                    set this.u = u
					set this.affected = CreateGroup()
                    set thistype.tb[id] = this
                    call this.push(TIMEOUT)
                    call UnitAddAbility(u, BUFF_ID)
                    call UnitMakeAbilityPermanent(u, true, BUFF_ID)
                else
                    set this = thistype.tb[id]
                endif
                set lvl = GetUnitAbilityLevel(u, SPELL_ID)
                set this.range = Range(lvl)
                set u = null
            endif
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_SKILL, function thistype.learn)
            call PlayerStat.ultimateEvent(function thistype.ultimates)
            set thistype.tb = Table.create
            set thistype.g = CreateGroup()
            call SpellBuff.initialize()
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope