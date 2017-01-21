scope ClawPierce
    
    globals
        private constant integer SPELL_ID = 'A213'
        private constant real ANGLE_TOLERANCE = 45  //(In degrees)
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_CHAOS
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_UNIVERSAL
        private constant string SFX = "Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl"//"Models\\Effects\\ClawPierce.mdx"
    endglobals
    
    //In percent
    private function Chance takes integer level returns real
        if level == 11 then
            return 75.0
        endif
        return 5.0*level
    endfunction
    
    private function TargetFilter takes unit u, player p returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE)
    endfunction
    
    private function SourceFilter takes unit u returns boolean
        return not IsUnitIllusion(u)
    endfunction
    
    struct ClawPierce extends array
        
        private static method onDamage takes nothing returns nothing
            local integer level = GetUnitAbilityLevel(Damage.source, SPELL_ID)
            local real angle
            local textsplat t
            if Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.element.coded and level > 0  then
                if GetRandomReal(0, 100) <= Chance(level) and Damage.amount < GetWidgetLife(Damage.target) then
                    if TargetFilter(Damage.target, GetOwningPlayer(Damage.source)) and SourceFilter(Damage.source) then
                        set angle = Atan2(GetUnitY(Damage.target) - GetUnitY(Damage.source), GetUnitX(Damage.target) - GetUnitX(Damage.source))*bj_RADTODEG
                        if angle < 0 then
                            set angle = angle + 360
                        endif
                        if RAbsBJ(GetUnitFacing(Damage.target) - angle) <= ANGLE_TOLERANCE then
                            set Damage.amount = GetWidgetLife(Damage.target) - 1.0
                            call DestroyEffect(AddSpecialEffect(SFX, GetUnitX(Damage.target), GetUnitY(Damage.target)))
                            set t = FloatingTextSplat(Element.string(DAMAGE_ELEMENT_NORMAL) + I2S(R2I(GetWidgetLife(Damage.target) - 1.0)) + "|r", Damage.target, 2.0)
                            call t.setVisible(GetLocalPlayer() == GetOwningPlayer(Damage.source))
                        endif
                        call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " procs thistype")
                    endif
                endif
            endif
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call Damage.registerModifier(function thistype.onDamage)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope