library Illusion /*

                         Illusion v1.31
                            by Flux
            
            Allows easy creation of Illusion with any damage factor.
    
    */ requires DamageEvent, DamageModify/*
    http://www.hiveworkshop.com/threads/damagepackage.287101/
    Required to manipulate damage given and damage taken by illusions.
    
    
    */ optional Table /*
    If not found, the system will create a hashtable. Hashtables are limited to 255 per map.
    
    */ optional RegisterPlayerUnitEvent /*
    If not found, an extra trigger will be created for a "Unit is summoned" event.

    
    ********************************************************************************
    *************************************** API ************************************
    ********************************************************************************
    struct Illusion
    
        static method create takes player owner, unit source, real x, real y returns thistype
        - Create an Illusion based on <unit source>, owned by <player owner>, positioned at (<x>, <y>) 
        
        method operator duration= takes real time returns nothing
        - Add a timer to an illusion.
        - Cannot be overwritten once set.
        
        static method get takes unit u returns thistype
        - Return the 'Illusion instance' based on unit parameter.
          
        readonly unit unit
        - Refers to the actual illusion unit
        
        public real damageGiven
        - Determines damage dealt factor.
        
        public real damageTaken
        - Determines damage received factor.  
    
    
    CREDITS:
        Bribe         - Table
        Flux          - DamageEvent and DamageModify
        Magtheridon96 - RegisterPlayerUnitEvent
        
*/
    //===================================================================
    //========================= CONFIGURATION ===========================
    //===================================================================
    globals
        //Rawcode of Illusion Ability based on "Item Illusions"
        private constant integer ILLUSION_SPELL = 'AILS'
        
        private constant integer DUMMY_ID = 'dumi'
        
        //Refresh Rate of triggers
        private constant real REFRESH_RATE = 120     
        
        //Dummy unit owner
        private constant player DUMMY_OWNER = Player(PLAYER_NEUTRAL_PASSIVE)
    endglobals
    //===================================================================
    //======================= END CONFIGURATION =========================
    //===================================================================
    
    native UnitAlive takes unit u returns boolean
    
    struct Illusion 
        
        readonly unit unit
        public real damageTaken
        public real damageGiven
        
        static if LIBRARY_Table then
            private static Table tb
        else
            private static hashtable hash = InitHashtable()
        endif
        
        private static trigger deathTrg = CreateTrigger()
        private static group g = CreateGroup()
        private static timer t = CreateTimer()
        private static unit dummy
        private static unit illu
        
        static method get takes unit u returns thistype
            static if LIBRARY_Table then
                return thistype.tb[GetHandleId(u)]
            else
                return LoadInteger(thistype.hash, GetHandleId(u), 0)
            endif
        endmethod
        
        private static method recreate takes nothing returns nothing
            call DestroyTrigger(thistype.deathTrg)
            set thistype.deathTrg = CreateTrigger()
            call TriggerAddCondition(thistype.deathTrg, Condition(function thistype.onDeath))
        endmethod
        
        method destroy takes nothing returns nothing
            if UnitAlive(this.unit) then
                call KillUnit(this.unit)
            endif
            static if LIBRARY_Table then
                call thistype.tb.remove(GetHandleId(this.unit))
            else
                call RemoveSavedInteger(thistype.hash, GetHandleId(this.unit), 0)
            endif
            call GroupRemoveUnit(thistype.g, this.unit)
            if FirstOfGroup(thistype.g) == null then
                call PauseTimer(thistype.t)
                call thistype.recreate()
            endif
            set this.unit = null
            call this.deallocate()
        endmethod
        
        private static method reAdd takes nothing returns nothing
            call TriggerRegisterUnitEvent(thistype.deathTrg, GetEnumUnit(), EVENT_UNIT_DEATH)
        endmethod
        
        private static method refresh takes nothing returns nothing
            call thistype.recreate()
            call ForGroup(thistype.g, function thistype.reAdd)
        endmethod
    
        private static method onDamage takes nothing returns nothing
            local thistype this
            //If source is illusion
            if IsUnitInGroup(Damage.source, thistype.g) then
                set this = thistype.get(Damage.source)
                set Damage.amount = Damage.amount*this.damageGiven
            endif
            //If target is illusion
            if IsUnitInGroup(Damage.target, thistype.g) then
                set this = thistype.get(Damage.target)
                set Damage.amount = Damage.amount*this.damageTaken
            endif
        endmethod
        
        
        private static method onDeath takes nothing returns boolean
            call thistype(thistype.get(GetTriggerUnit())).destroy()
            return false
        endmethod
        
        private static method entered takes nothing returns boolean
            if GetSummoningUnit() == thistype.dummy then
                set thistype.illu = GetTriggerUnit()
            endif
            return false
        endmethod
        
        method operator duration= takes real time returns nothing
            call UnitApplyTimedLife(this.unit, 'BTLF', time)
        endmethod
        
        static method create takes player owner, unit source, real x, real y returns thistype
            local thistype this
            set thistype.illu = null
            //Create the Illusion Unit
            if source != null then
                call SetUnitX(thistype.dummy, GetUnitX(source))
                call SetUnitY(thistype.dummy, GetUnitY(source))
                call SetUnitOwner(thistype.dummy, GetOwningPlayer(source), false)
                if IssueTargetOrderById(thistype.dummy, 852274, source) then
                    if thistype.illu != null then
                        call SetUnitOwner(thistype.illu, owner, true)
                        if IsUnitType(source, UNIT_TYPE_STRUCTURE) then
                            call SetUnitPosition(thistype.illu, x, y)
                        else
                            call SetUnitX(thistype.illu, x)
                            call SetUnitY(thistype.illu, y)
                        endif
                    endif
                endif
                call SetUnitOwner(thistype.dummy, DUMMY_OWNER, false)
            endif
            //Initialize struct
            set this = thistype.allocate()
            set this.unit = thistype.illu
            set this.damageTaken = 1.0
            set this.damageGiven = 1.0
            if FirstOfGroup(thistype.g) == null then
                call TimerStart(thistype.t, REFRESH_RATE, true, function thistype.refresh)
            endif
            call GroupAddUnit(thistype.g, this.unit)
            call TriggerRegisterUnitEvent(thistype.deathTrg, this.unit, EVENT_UNIT_DEATH)
            static if LIBRARY_Table then
                set thistype.tb[GetHandleId(this.unit)] = this  
            else
                call SaveInteger(thistype.hash, GetHandleId(this.unit), 0, this)
            endif
            return this
        endmethod
        
        private static method onInit takes nothing returns nothing
            static if LIBRARY_RegisterPlayerUnitEvent then
                call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SUMMON, function thistype.entered)
            else
                local trigger t = CreateTrigger()
                call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SUMMON)
                call TriggerAddCondition(t, Condition(function thistype.entered))
            endif
            call TriggerAddCondition(thistype.deathTrg, Condition(function thistype.onDeath))
            set thistype.dummy = CreateUnit(DUMMY_OWNER, DUMMY_ID, 0, 0, 0)
            call UnitAddAbility(thistype.dummy, ILLUSION_SPELL)
            static if LIBRARY_Table then
                set thistype.tb = Table.create()
            endif
            call Damage.registerModifier(function thistype.onDamage)
        endmethod
        
    endstruct
    
endlibrary