scope SpectralTrack
    
    globals
        private constant integer SPELL_ID = 'A133'
        private constant integer SPELL_BUFF = 'B133'
        private constant string MODEL = "Models\\Effects\\SpectralTrack.mdx"
    endglobals
    
    private function Duration takes integer level returns real
        if level == 11 then
            return 10.0
        endif
        return 20.0 + 0.0*level
    endfunction
    
    private function Radius takes integer level returns real
        if level == 11 then
            return GLOBAL_SIGHT
        endif
        return 250.0*level
    endfunction
    
    private struct SpellBuff extends Buff
        
        private integer ctr
        private effect sfx
        readonly TrueSight ts
        readonly FlySight sight
        
        method rawcode takes nothing returns integer
            return SPELL_BUFF
        endmethod
        
        method dispelType takes nothing returns integer
            return BUFF_POSITIVE
        endmethod
        
        method stackType takes nothing returns integer
            return BUFF_STACK_NONE
        endmethod
        
        method onRemove takes nothing returns nothing
            call this.ts.destroy()
            call this.sight.destroy()
            call DestroyEffect(this.sfx)
            set this.duration = 0
            set this.sfx = null
        endmethod
        
        method onApply takes nothing returns nothing
            set this.sfx = AddSpecialEffectTarget(MODEL, this.target, "origin")
            set this.sight = FlySight.create(this.target, 0)
            set this.ts = TrueSight.create(this.target, 0)
        endmethod
        
        implement BuffApply
    endstruct
    
    struct SpectralTrack extends array
        
        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local integer level = GetUnitAbilityLevel(caster, SPELL_ID)
            local real radius = Radius(level)
            local SpellBuff b = SpellBuff.add(caster, caster)
            set b.duration = Duration(level)
            set b.ts.radius = radius
            set b.sight.radius = radius
            set caster = null
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call PreloadSpell(SPELL_BUFF)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope