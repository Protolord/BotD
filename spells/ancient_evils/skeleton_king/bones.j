scope Bones
    
    globals
        private constant integer SPELL_ID = 'A7XX'
        private constant integer BUFF_ID = 'B7XX'
        private constant real CHANCE = 10.0
        private constant real DURATION = 300.0
        private constant real DAMAGE_PER_ARROW = 10.0
        private constant integer MAX_ARROW = 25
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
    endglobals
    
    private function TargetFilter takes unit u, player owner returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, owner) and IsUnitType(u, UNIT_TYPE_MELEE_ATTACKER)
    endfunction
    
    private function SourceFilter takes unit u returns boolean
        return GetUnitTypeId(u) == 'hgtw' or GetUnitTypeId(u) == 'hTes'
    endfunction
    
    private struct SpellBuff extends Buff

        private effect sfx

        private static string array arrow
        private static string array attach

        private static Table tb

        private static constant integer RAWCODE = 'B7XX'
        private static constant integer DISPEL_TYPE = BUFF_POSITIVE
        private static constant integer STACK_TYPE = BUFF_STACK_FULL

        static method count takes unit u returns integer 
            return thistype.tb[GetHandleId(u)]
        endmethod

        method onRemove takes nothing returns nothing
            local integer id = GetHandleId(this.target)
            set thistype.tb[id] = thistype.tb[id] - 1
            call DestroyEffect(this.sfx)
        endmethod

        method onApply takes nothing returns nothing
            local integer id = GetHandleId(this.target)
            local real x1 = GetUnitX(this.source)
            local real y1 = GetUnitY(this.source)
            local real x2 = GetUnitX(this.target)
            local real y2 = GetUnitY(this.target)
            set thistype.tb[id] = thistype.tb[id] + 1
            set this.sfx = AddSpecialEffectTarget(thistype.arrow[ModuloInteger(thistype.tb[id], 6)], this.target, thistype.attach[(thistype.tb[id] - 1)/6])
        endmethod

        private static method init takes nothing returns nothing
            call PreloadSpell(thistype.RAWCODE)
            set thistype.tb = Table.create()
            set thistype.arrow[0] = "Models\\Effects\\BoneArrow1.mdx"
            set thistype.arrow[1] = "Models\\Effects\\BoneArrow2.mdx"
            set thistype.arrow[2] = "Models\\Effects\\BoneArrow3.mdx"
            set thistype.arrow[3] = "Models\\Effects\\BoneArrow4.mdx"
            set thistype.arrow[4] = "Models\\Effects\\BoneArrow5.mdx"
            set thistype.arrow[5] = "Models\\Effects\\BoneArrow6.mdx"
            set thistype.attach[0] = "medium"
            set thistype.attach[1] = "rear"
            set thistype.attach[2] = "chest"
            set thistype.attach[3] = "medium"
            set thistype.attach[4] = "rear"
        endmethod
        
        implement BuffApply
    endstruct
    
    struct Bones extends array
        
        private static trigger trg
        
        private static method onDamage takes nothing returns boolean
            local integer level = GetUnitAbilityLevel(Damage.target, SPELL_ID)
            local SpellBuff b
            if level > 0 and Damage.type == DAMAGE_TYPE_PHYSICAL and not Damage.element.coded then
                //Attacked unit has arrows and attacker is melee
                if SpellBuff.has(null, Damage.target, SpellBuff.typeid) and TargetFilter(Damage.source, GetOwningPlayer(Damage.target)) then
                    call DisableTrigger(thistype.trg)
                    call Damage.element.apply(Damage.target, Damage.source, DAMAGE_PER_ARROW*SpellBuff.count(Damage.target), ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_ELEMENT_NORMAL)
                    call EnableTrigger(thistype.trg)
                endif
                //Add arrow
                if SourceFilter(Damage.source) and GetRandomReal(0, 100) <= CHANCE and SpellBuff.count(Damage.target) < MAX_ARROW then
                    set b = SpellBuff.add(Damage.source, Damage.target)
                    set b.duration = DURATION
                    call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " procs thistype")
                endif
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