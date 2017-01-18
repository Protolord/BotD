scope ForceOfLycan
    
    globals
        private constant integer SPELL_ID = 'A212'
        private constant integer SPELL_BUFF = 'S212'
        private constant string BUFF_SFX = "Models\\Effects\\ForceOfTheLycan.mdx"
        private constant string BUFF_SFX2 = "Abilities\\Spells\\Other\\HowlOfTerror\\HowlTarget.mdl"
        private constant player HOSTILE_PLAYER = Player(PLAYER_NEUTRAL_AGGRESSIVE)
    endglobals
    
    private function Duration takes integer level returns real
        if level == 11 then
            return 10.0
        endif
        return 0.5*level
    endfunction
    
    private struct SpellBuff extends Buff
    
        private player origOwner
        private effect sfx
        private effect sfx2
        
        method rawcode takes nothing returns integer
            return SPELL_BUFF
        endmethod
        
        method dispelType takes nothing returns integer
            return BUFF_NEGATIVE
        endmethod
        
        method stackType takes nothing returns integer
            return BUFF_STACK_NONE
        endmethod
        
        method onRemove takes nothing returns nothing
            call UnitRemoveAbility(this.target, 'd212')
            call SetUnitOwner(this.target, this.origOwner, true)
            call DestroyEffect(this.sfx)
            call DestroyEffect(this.sfx2)
            set this.sfx = null
            set this.sfx2 = null
            set this.origOwner = null
        endmethod
        
        method onApply takes nothing returns nothing
            local group g = CreateGroup()
            local unit u
            set this.origOwner = GetOwningPlayer(this.target)
            set this.sfx = AddSpecialEffectTarget(BUFF_SFX, this.target, "origin")
            set this.sfx2 = AddSpecialEffectTarget(BUFF_SFX2, this.target, "chest")
            call SetUnitOwner(this.target, HOSTILE_PLAYER, false)
            call GroupEnumUnitsInRange(g, GetUnitX(this.target), GetUnitY(this.target), 800, null)
            loop
                set u = FirstOfGroup(g)
                exitwhen u == null
                call GroupRemoveUnit(g, u)
                if u != this.source then
                    exitwhen true
                endif
            endloop
            call IssueTargetOrderById(this.target, ORDER_attack, u)
            call DestroyGroup(g)
            set u = null
            set g = null
        endmethod
        
        implement BuffApply
    endstruct
    
    struct ForceOfLycan extends array
        
        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local real x = GetUnitX(caster)
            local real y = GetUnitY(caster)
            local integer lvl = GetUnitAbilityLevel(caster, SPELL_ID)
            local SpellBuff b = SpellBuff.add(caster, GetSpellTargetUnit())
            set b.duration = Duration(lvl)
            if lvl == 11 then
                //call UnitRemoveAbility(GetSpellTargetUnit(), 'd212')
                call SetUnitAbilityLevel(GetSpellTargetUnit(), 'd212', 2)
                call SetUnitAbilityLevel(GetSpellTargetUnit(), 'D212', 2)
                //call IncUnitAbilityLevel(GetSpellTargetUnit(), 'D212')
            endif
            call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Other\\HowlOfTerror\\HowlCaster.mdl", x, y))
            set caster = null
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype on " + GetUnitName(GetSpellTargetUnit()))
        endmethod
        
        static method init takes nothing returns nothing
            local integer i = 0
            call SystemTest.start("Initializing thistype: ")
            loop
                exitwhen i == bj_MAX_PLAYER_SLOTS
                call SetPlayerAbilityAvailable(Player(i), SPELL_BUFF, false)
                //call SetPlayerAbilityAvailable(Player(i), SPELL_BUFF_ULT, false)
                set i = i + 1
            endloop
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call PreloadSpell(SPELL_BUFF)
            //call PreloadSpell(SPELL_BUFF_ULT)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope