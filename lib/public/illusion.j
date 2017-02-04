library Illusion /*

                         Illusion v1.32
                            by Flux
           
            Allows easy creation of Illusion with any damage factor.
   
    */ requires DamageEvent, DamageModify/*
    http://www.hiveworkshop.com/threads/damagepackage.287101/
    Required to manipulate damage given and damage taken by illusions.
   
   
    */ optional Table /*
    If not found, the system will create a hashtable. You cannot create more than 256 hashtable
    per map.

   
    ********************************************************************************
    *************************************** API ************************************
    ********************************************************************************
   
    Illusion.create(player, unitSource, x, y)
        - Create an Illusion based on <unitSource>, owned by <player>, positioned at (<x>, <y>) 
       
    this.duration = <timedLife>
        - Add a timer to an illusion.
        - Cannot be overwritten once set.
       
    Illusion.get(unit)
        - Return the 'Illusion instance' based on <unit> parameter.
         
    this.unit
        - Refers to the actual illusion unit
       
    this.damageGiven
        - Determines damage dealt factor.
       
    this.damageTaken
        - Determines damage received factor.  
   
   
    CREDITS:
        Bribe         - Table
        Flux          - DamageEvent and DamageModify
       
*/
    //===================================================================
    //========================= CONFIGURATION ===========================
    //===================================================================
    globals
        //Rawcode of Illusion Ability based on "Item Illusions"
        private constant integer ILLUSION_SPELL = 'AILS'
       
        private constant integer DUMMY_ID = 'dumi'
       
        private constant integer REFRESH_COUNT = 30
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
        private static integer count = 0
        private static unit dummy
        private static unit illu
       
        static method get takes unit u returns thistype
            static if LIBRARY_Table then
                return thistype.tb[GetHandleId(u)]
            else
                return LoadInteger(thistype.hash, GetHandleId(u), 0)
            endif
        endmethod
       
        private static method reAdd takes nothing returns nothing
            call TriggerRegisterUnitEvent(thistype.deathTrg, GetEnumUnit(), EVENT_UNIT_DEATH)
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
            //Death trigger refresh
            set thistype.count = thistype.count + 1
            if thistype.count >= REFRESH_COUNT then
                call DestroyTrigger(thistype.deathTrg)
                set thistype.deathTrg = CreateTrigger()
                call TriggerAddCondition(thistype.deathTrg, Condition(function thistype.onDeath))
                call ForGroup(thistype.g, function thistype.reAdd)
                set thistype.count = 0
            endif
            set this.unit = null
            call this.deallocate()
        endmethod
       
       
        private static method onDamage takes nothing returns nothing
            //If source is illusion
            if IsUnitInGroup(Damage.source, thistype.g) then
                set Damage.amount = Damage.amount*thistype.get(Damage.source).damageGiven
            endif
            //If target is illusion
            if IsUnitInGroup(Damage.target, thistype.g) then
                set Damage.amount = Damage.amount*thistype.get(Damage.target).damageTaken
            endif
        endmethod
       
        private static method onDeath takes nothing returns boolean
            call thistype(thistype.get(GetTriggerUnit())).destroy()
            return false
        endmethod
       
        private static method entered takes nothing returns boolean
            if GetSummoningUnit() == thistype.dummy then
                set thistype.illu = GetSummonedUnit()
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
                    else
                        debug call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "[Illusion] No illusion created")
                        return 0
                    endif
                else
                    debug call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "[Illusion] Issued order failed")
                    return 0
                endif
                call SetUnitOwner(thistype.dummy, DUMMY_OWNER, false)
            else
                debug call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "[Illusion] Source unit is null")
                return 0
            endif
            //Initialize struct
            set this = thistype.allocate()
            set this.unit = thistype.illu
            set this.damageTaken = 1.0
            set this.damageGiven = 1.0
            call SetUnitAnimation(thistype.illu, "stand")
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
            local trigger t = CreateTrigger()
            set thistype.dummy = CreateUnit(DUMMY_OWNER, DUMMY_ID, 0, 0, 0)
            call TriggerRegisterUnitEvent(t, thistype.dummy, EVENT_UNIT_SUMMON)
            call TriggerAddCondition(t, Condition(function thistype.entered))
            call TriggerAddCondition(thistype.deathTrg, Condition(function thistype.onDeath))
            call UnitAddAbility(thistype.dummy, ILLUSION_SPELL)
            static if LIBRARY_Table then
                set thistype.tb = Table.create()
            endif
            call Damage.registerModifier(function thistype.onDamage)
        endmethod
       
    endstruct
   
endlibrary