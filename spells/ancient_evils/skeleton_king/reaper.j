scope Reaper
    
    globals
        private constant integer SPELL_ID = 'A712'
        private constant string BUFF_SFX = "Models\\Effects\\Reaper.mdx"
        private constant real LIMIT = 500.0
    endglobals

    private function Duration takes integer level returns real
        if level == 11 then
            return 30.0
        endif
        return 10.0 + 2.0*level
    endfunction
    
    private function DamageGrowth takes integer level returns real
        if level == 11 then
            return 20.0
        endif
        return 10.0 + 0.0*level
    endfunction
    
    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE)
    endfunction
    
    private struct SpellBuff extends Buff
        
        private effect sfx
        public real bonus
        readonly AtkDamage ad

        private static constant integer RAWCODE = 'B712'
        private static constant integer DISPEL_TYPE = BUFF_POSITIVE
        private static constant integer STACK_TYPE = BUFF_STACK_NONE
        
        method onRemove takes nothing returns nothing
            call DestroyEffect(this.sfx)
            call this.ad.destroy()
            set this.sfx = null
        endmethod
        
        method onApply takes nothing returns nothing
            set this.bonus = 0
            set this.ad = AtkDamage.create(this.target, 0)
            set this.sfx = AddSpecialEffectTarget(BUFF_SFX, this.target, "weapon right")
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
        endmethod
        
        implement BuffApply
    endstruct
    
    struct Reaper extends array
    
        private static trigger trg

        private static method onDamage takes nothing returns boolean
            local integer level = GetUnitAbilityLevel(Damage.source, SPELL_ID)
            local SpellBuff b
            if Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.element.coded and level > 0 and TargetFilter(Damage.target, GetOwningPlayer(Damage.source)) then
                set b = SpellBuff.add(Damage.source, Damage.source)
                set b.duration = Duration(level)
                set b.bonus = b.bonus + DamageGrowth(level)
                if b.bonus > LIMIT then
                    set b.bonus = LIMIT
                endif
                call b.ad.change(b.bonus)
            endif
            return false
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            set thistype.trg = CreateTrigger()
            call Damage.registerTrigger(thistype.trg)
            call TriggerAddCondition(thistype.trg, function thistype.onDamage)
            call SpellBuff.initialize()
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope