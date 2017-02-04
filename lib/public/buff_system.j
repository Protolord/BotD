library Buff /*
                        Buff System v1.11
                            by Flux
               
            Handles all interactions of self-defined buffs.
           
            Features:
                - Can dispel positive/negative/both/all buffs.
                - Supports 3 types of buff stacking.
                - Buffs with duration.
                - Pick all Buffs of a unit easily.
           
        */ requires Ascii/*
           (nothing)
       
        */ optional TimerUtils /*  
        */ optional RegisterPlayerUnitEvent /*

   
    ******************
         CREDITS
    ******************
       
        muzzel          - For BuffHandler which this resource is heavily based upon.
        Vexorian        - For the optional TimerUtils.
        Magtheridon96   - For the optional RegisterPlayerUnitEvent

    */
   
    globals        
        //-----------------------------//
        //--------- BUFF TYPES --------//
        //-----------------------------//
        constant integer BUFF_NONE = 0    
        constant integer BUFF_POSITIVE = 1      
        constant integer BUFF_NEGATIVE = 2
       
        //-----------------------------//
        //------ BUFF STACK TYPES -----//
        //-----------------------------//
        //Applying the same buff only refreshes the duration
        //If the buff is reapplied but from a different source, the Buff unit source gets replaced.
        constant integer BUFF_STACK_NONE = 0
       
        //Each buff from different source stacks.
        //Re-applying the same buff from the same source only refreshes the duration
        constant integer BUFF_STACK_PARTIAL = 1
       
        //Each buff applied fully stacks.
        constant integer BUFF_STACK_FULL = 2
       
        //Automatically Preloads all Buff abilities defined in "method rawcode"
        //but will generate a lot of scripts in the process
        private constant boolean PRELOAD_BUFFS = false
    endglobals
   
    struct Buff
       
        readonly boolean exist
        readonly unit target
        readonly unit source
       
        readonly thistype bnext
        readonly thistype bprev
       
        //To avoid multiple TriggerEvaluates when these
        //data are needed
        private integer spellId
        private integer buffId
        private integer stackId
        private integer dispelId
       
        private timer t
       
       
        private static hashtable hash = InitHashtable()
       
        stub method rawcode takes nothing returns integer
            return 0
        endmethod
       
        stub method dispelType takes nothing returns integer
            return BUFF_NONE
        endmethod
       
        stub method stackType takes nothing returns integer
            return BUFF_STACK_NONE
        endmethod
       
        stub method onRemove takes nothing returns nothing
        endmethod
       
        stub method onApply takes nothing returns nothing
        endmethod
       
        method operator name takes nothing returns string
            return GetObjectName(this.rawcode())
        endmethod
       
        method remove takes nothing returns nothing
            local boolean remove = false
            local integer ids
            local integer idt
            local thistype head
            local integer count
           
            if this.exist then
                set ids = GetHandleId(this.source)
                set idt = GetHandleId(this.target)
                set head = LoadInteger(thistype.hash, idt, 0)
               
                call this.onRemove()
               
                if this.t != null then
                    static if LIBRARY_TimerUtils then
                        call ReleaseTimer(this.t)
                    else
                        call RemoveSavedInteger(thistype.hash, GetHandleId(this.t), 0)
                        call DestroyTimer(this.t)
                    endif
                    set this.t = null
                endif
               
                if this.stackId == BUFF_STACK_FULL then
                    //Update Buff count
                    set count = LoadInteger(thistype.hash, this.getType(), idt) - 1
                    call SaveInteger(thistype.hash, this.getType(), idt, count)
                    if count == 0 then
                        set remove = true
                    endif
                   
                elseif this.stackId == BUFF_STACK_PARTIAL then
                    //Update Buff count
                    set count = LoadInteger(thistype.hash, this.getType(), idt) - 1
                    call SaveInteger(thistype.hash, this.getType(), idt, count)
                    if count == 0 then
                        set remove = true
                    endif
                    //Remove saved Buff instance bound to [source id][target id][this.getType()]
                    call RemoveSavedInteger(thistype.hash, ids, idt*this.getType())
                   
                elseif this.stackId == BUFF_STACK_NONE then
                    set remove = true
                    //Remove saved Buff instance bound to [target id][this.getType()]
                    call RemoveSavedInteger(thistype.hash, idt, this.getType())
                   
                endif
               
                if remove then
                    call UnitRemoveAbility(this.target, this.spellId)
                    call UnitRemoveAbility(this.target, this.buffId)
                endif
               
                //Remove from the BuffList
                //If this is the only Buff of the unit
                if this == head and this.bnext == head then
                    call RemoveSavedInteger(thistype.hash, idt, 0)
                else
                    //If this is the head of the BuffList
                    if this == head then
                        //Change this unit's BuffList head
                        call SaveInteger(thistype.hash, idt, 0, this.bnext)
                    endif
                    set this.bnext.bprev = this.bprev
                    set this.bprev.bnext = this.bnext
                endif
               
                set this.exist = false
                set this.target = null
                set this.source = null
                call this.destroy()
            endif
        endmethod
       
        private static method expires takes nothing returns nothing
            static if LIBRARY_TimerUtils then
                local thistype this = GetTimerData(GetExpiredTimer())
                call ReleaseTimer(GetExpiredTimer())
            else
                local integer id = GetHandleId(GetExpiredTimer())
                local thistype this = LoadInteger(thistype.hash, id, 0)
                call RemoveSavedInteger(thistype.hash, id, 0)
                call DestroyTimer(GetExpiredTimer())
            endif
            if this.t != null then
                set this.t = null
                call this.remove()
            endif
        endmethod
       
        method operator duration= takes real time returns nothing
            if this.t == null then
                static if LIBRARY_TimerUtils then
                    set this.t = NewTimerEx(this)
                else
                    set this.t = CreateTimer()
                    call SaveInteger(thistype.hash, GetHandleId(this.t), 0, this)
                endif
            endif
            call TimerStart(this.t, time, false, function thistype.expires)
        endmethod
       
        static method dispel takes unit u, integer dispelType returns nothing
            local integer id = GetHandleId(u)
            local thistype head
            local thistype this
            if HaveSavedInteger(thistype.hash, id, 0) then
                set head = LoadInteger(thistype.hash, id, 0)
                set this = head.bnext
                loop
                    if this.dispelId == dispelType then
                        call this.remove()
                    endif
                    exitwhen this == head
                    set this = this.bnext
                endloop
            endif
        endmethod
       
        readonly static thistype buffHead
        public static thistype picked
       
        static method pickBuffs takes unit u returns nothing
            local integer id = GetHandleId(u)
            if HaveSavedInteger(thistype.hash, id, 0) then
                set thistype.buffHead = LoadInteger(thistype.hash, id, 0)
            else
                set thistype.buffHead = 0
            endif
        endmethod

       
        static method dispelBoth takes unit u returns nothing
            local integer id = GetHandleId(u)
            local thistype head
            local thistype this
            if HaveSavedInteger(thistype.hash, id, 0) then
                set head = LoadInteger(thistype.hash, id, 0)
                set this = head.bnext
                loop
                    if this.dispelId == BUFF_POSITIVE or this.dispelId == BUFF_NEGATIVE then
                        call this.remove()
                    endif
                    exitwhen this == head
                    set this = this.bnext
                endloop
            endif
        endmethod
       
        static method dispelAll takes unit u returns nothing
            local integer id = GetHandleId(u)
            local thistype head
            local thistype this
            if HaveSavedInteger(thistype.hash, id, 0) then
                set head = LoadInteger(thistype.hash, id, 0)
                set this = head.bnext
                loop
                    call this.remove()
                    exitwhen this == head
                    set this = this.bnext
                endloop
            endif
        endmethod
       
        private static method onDeath takes nothing returns nothing
            call thistype.dispelAll(GetTriggerUnit())
        endmethod
       
        method check takes unit source, unit target returns thistype
            local boolean apply = false
            local integer bprevSpellId = 0
            local integer idt = GetHandleId(target)
            local integer ids
            local thistype head
           
           
            set this.stackId = this.stackType()
            set this.dispelId = this.dispelType()
           
            if this.stackId == BUFF_STACK_FULL then
                //Count how many buffs are stored in a certain unit
                call SaveInteger(thistype.hash, this.getType(), idt, LoadInteger(thistype.hash, this.getType(), idt) + 1)                
                set apply = true
               
            elseif this.stackId == BUFF_STACK_PARTIAL then
                set ids = GetHandleId(source)
                //Check if a similar buff with the same source and target exist
                //Uses dimensions [source id][target id][buff type]
                if HaveSavedInteger(thistype.hash, ids, idt*this.getType()) then
                    call this.destroy()
                    set this = LoadInteger(thistype.hash, ids, idt*this.getType())
                    set bprevSpellId = this.spellId
                else
                    //Store the Buff instance to hashtable [source id][target id][buff type]
                    call SaveInteger(thistype.hash, ids, idt*this.getType(), this)
                    set apply = true
                   
                    //Count how many buffs of this type are stored in this certain unit
                    call SaveInteger(thistype.hash, this.getType(), idt, LoadInteger(thistype.hash, this.getType(), idt) + 1)
                endif
               
            elseif this.stackId == BUFF_STACK_NONE then
                //Check if a similar buff with the same target exist
                //Uses dimensions [target id][buff type]
                if HaveSavedInteger(thistype.hash, idt, this.getType()) then
                    call this.destroy()
                    set this = LoadInteger(thistype.hash, idt, this.getType())
                    set bprevSpellId = this.spellId
                else
                    //Store the Buff instance to hashtable [target id][buff type]
                    call SaveInteger(thistype.hash, idt, this.getType(), this)
                    set apply = true
                endif
            endif
           
            set this.source = source
            set this.target = target
            set this.exist = true
            set this.spellId = this.rawcode()
            set this.buffId = this.spellId + 0x20000000
           
            //If SpellBuff is different, remove the previous SpellBuff
            if bprevSpellId != 0 and bprevSpellId != this.spellId then
                call UnitRemoveAbility(target, bprevSpellId)
                call UnitRemoveAbility(target, bprevSpellId + 0x20000000)
                call UnitAddAbility(target, this.spellId)
                call UnitMakeAbilityPermanent(target, true, this.spellId)
            endif
           
            if apply then
                
                if GetUnitAbilityLevel(target, this.spellId) == 0 then
                    call UnitAddAbility(target, this.spellId)
                    call UnitMakeAbilityPermanent(target, true, this.spellId)
                endif
               
                //Add the Buff to a BuffList of this unit
                    //If BuffList already exist
                if HaveSavedInteger(thistype.hash, idt, 0) then
                    set head = LoadInteger(thistype.hash, idt, 0)
                    set this.bnext = head
                    set this.bprev = head.bprev
                    set this.bnext.bprev = this
                    set this.bprev.bnext = this
                else
                    //Set this as the unit's BuffList head
                    call SaveInteger(thistype.hash, idt, 0, this)
                    set this.bnext = this
                    set this.bprev = this
                endif
               
                call this.onApply()
            endif
           
            return this
        endmethod
       
        implement optional BuffInit
       
        private static method onInit takes nothing returns nothing
            static if LIBRARY_RegisterPlayerUnitEvent then
                call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
            else
                local trigger t = CreateTrigger()
                local code c = function thistype.onDeath
                call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DEATH)
                call TriggerAddCondition(t, Condition(c))
            endif
        endmethod
       
    endstruct
   
    static if PRELOAD_BUFFS then
        module BuffInit
           
            readonly static unit preloader
           
            private static method killPreloader takes nothing returns nothing
                call RemoveUnit(thistype.preloader)
            endmethod
           
            private static method onInit takes nothing returns nothing
                set thistype.preloader = CreateUnit(Player(14), 'ushd', GetRectMaxX(bj_mapInitialPlayableArea), GetRectMaxY(bj_mapInitialPlayableArea), 0)
                call TimerStart(CreateTimer(), 1.0, false, function thistype.killPreloader)
            endmethod
        endmodule
    endif
   
    module BuffApply
       
        static method add takes unit source, unit target returns thistype
            local thistype this = thistype.create()        
            set this = this.check(source, target)
            return this
        endmethod
       
        static if PRELOAD_BUFFS then
            private static method onInit takes nothing returns nothing
                local thistype this = thistype.create()
                local integer raw = this.rawcode()
                call UnitAddAbility(Buff.preloader, raw)
                call UnitRemoveAbility(Buff.preloader, raw)
                call this.destroy()
            endmethod
        endif
    endmodule
   
    module BuffListStart
        if Buff.buffHead > 0 then
            set Buff.picked = Buff.buffHead
            loop
    endmodule
   
    module BuffListEnd
                exitwhen Buff.picked == Buff.buffHead.bprev
                set Buff.picked = Buff.picked.bnext
            endloop
        endif
    endmodule
   
endlibrary
