scope Web  
 
    globals
        private constant integer SPELL_ID = 'A424'
        private constant integer SPELL_BUFF = 'D424'
        private constant string MISSILE_MODEL = "Models\\Effects\\WebMissile.mdx"
        private constant string SFX = "Models\\Effects\\Web.mdx"
    endglobals
    
    private function Duration takes integer level returns real
        if level == 11 then
            return 10.0
        endif
        return 0.5*level
    endfunction
    
    private function Speed takes integer level returns real
        return 0.0*level + 900.0
    endfunction
    
    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction
    
    private struct SpellBuff extends Buff
        
        private effect sfx
        private Root r
        
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
            call DestroyEffect(this.sfx)
            call this.r.destroy()
            set this.sfx = null
        endmethod
        
        method onApply takes nothing returns nothing
            set this.sfx = AddSpecialEffectTarget(SFX, this.target, "chest")
            set this.r = Root.create(this.target)
        endmethod
        
        implement BuffApply
    endstruct
    
    struct Web extends array
        
        private unit caster
        private unit target
        private integer lvl
        private player owner
        private Missile m
        
        private method destroy takes nothing returns nothing
            call this.m.destroy()
            set this.caster = null
            set this.target = null
            set this.owner = null
        endmethod
        
        private static method onHit takes nothing returns nothing
            local thistype this = Missile.getHit()
            local SpellBuff b
            if not SpellBlock.has(this.target) and TargetFilter(this.target, this.owner) then
                set b = SpellBuff.add(this.caster, this.target)
                set b.duration = Duration(this.lvl)
            endif
            call this.destroy()
        endmethod
        
         private static method onCast takes nothing returns nothing
            local thistype this = thistype(Missile.create())
            set this.caster = GetTriggerUnit()
            set this.owner = GetTriggerPlayer()
            set this.target = GetSpellTargetUnit()
            set this.lvl = GetUnitAbilityLevel(this.caster, SPELL_ID)
            set this.m = Missile(this)
            set this.m.sourceUnit = this.caster
            set this.m.targetUnit = this.target
            set this.m.speed = Speed(this.lvl)
            set this.m.model = MISSILE_MODEL
            call this.m.registerOnHit(function thistype.onHit)
            call this.m.launch()
            call SetUnitScale(this.m.u, 1.5, 0, 0)
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype on " + GetUnitName(GetSpellTargetUnit()))
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call PreloadSpell(SPELL_BUFF)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope