//! novjass

                           
                            Buff System v1.30
                                 by Flux
           
            Handles all interactions of self-defined Buffs.
           
           
            Features:
                - Can dispel positive/negative/both/all Buffs.
                - Supports 3 types of buff stacking.
                - Buffs with duration.
                - Pick all Buffs of a unit easily.
                                 
    //==================================================================//
                                   API
    //==================================================================//

        static method add takes unit source, unit target returns thistype
            - Adds and creates a new Buff to the target depending on the 
              stacking type.
             
              EXAMPLE:
                local MyBuff b = MyBuff.add(GetTriggerUnit(), GetSpellTargetUnit())

              If the stackType is BUFF_STACK_NONE, and the target already has
              the same Buff applied, it will not create a new Buff instance, 
              instead it will return an existing Buff of the same type from 
              the target.
             
              If the stackType is BUFF_STACK_PARTIAL, it will only create a new
              Buff instance if there is no existing Buff on the target with the
              same source, else it will return a Buff coming from that source.
              That means same type of Buff from different sources will stack.
             
              If the stackType is BUFF_STACK_FULL, then "static method add" will
              return a newly created Buff instance everytime it is called.
       
        method operator duration= takes real time returns nothing
            - Adds a countdown timer to a Buff or change the countdown time of a
              Buff if a count down timer already exist.
             
              EXAMPLE:
                set b.duration = 10
       
        static method get takes unit source, unit target, integer typeid returns thistype
            - Returns a Buff from <target> caused by <source> and has a type of typeid.
            - When you want to retrieve a Buff from target caused by any source, input
              null in the source argument.
            - If Buff is non-existing, it returns 0.
            - If there is more than a Buff because that Buff fully stacks, it will return
              the oldest applied Buff.
           
        static method has takes unit source, unit target, integer typeid returns boolean
            - A simple wrapper function for Buff.get(source, target, typeid)
               
        method operator name takes nothing returns string
            - Returns the name of the Buff as defined in Object Editor
             
              EXAMPLE:
                call BJDebugMsg("Buff name is " + b.name)
       
        static method dispel takes unit u, integer dispelType returns nothing
            - Removes all <dispelType> Buffs from a unit.
             
              EXAMPLE:
                call Buff.dispel(GetTriggerUnit(), BUFF_POSITIVE)
       
        static method dispelBoth takes unit u returns nothing
            - Removes positive and negative buffs of a unit.
              Buffs with dispelType of BUFF_NONE will not be removed.
               
              EXAMPLE:
                call Buff.dispelBoth(u)
       
        static method dispelAll takes unit u returns nothing
            - Removes all Buffs from a unit.
             
              EXAMPLE:
                call Buff.dispelAll(u)
       
        static method pickBuffs takes unit u returns nothing
            - Used when you want to pick all buffs of a unit. More detailed
              example below the API list
             
              EXAMPLE:
                call Buff.pickBuffs(GetTriggerUnit())
       
        method remove takes nothing returns nothing
            - Removes a Buff instance. Using inside 'method onRemove'
              will cause an infinite loop.
               
              EXAMPLE:
                call b.remove()
       
        //------------------------------------------------//
                   HOW TO PICK ALL BUFFS ON A UNIT
        //------------------------------------------------//
       
        1. Use Buff.pickBuffs(yourUnit)
        2. Put your scripts/actions between 'implement BuffListStart' and
           'implement BuffListEnd'
       
        EXAMPLE: (A Spell that will remove the first 3 negative buffs applied)
           
            private static method onCast takes nothing returns nothing
                local integer counter = 3
                call Buff.pickBuffs(GetTriggerUnit())
                implement BuffListStart
                    if Buff.picked.dispelType == BUFF_NEGATIVE then
                        call Buff.picked.remove()
                        set counter = counter - 1
                    endif
                    exitwhen counter == 0
                implement BuffListEnd
            endmethod
           
        //NOTE: Since it's using modules, it can only be done inside a struct.
   
    //==================================================================//
                            HOW TO USE BUFF SYSTEM:
    //==================================================================//
   
    1. Create your own struct that 'extends Buff'.
       Do not forget to put 'implement BuffApply' before the end of the struct
   
        Example:
       
        private struct <BuffName> extends Buff
            /*
             * Your code here
            */
            implement BuffApply
        endstruct
       
       
    2. Define basic Buff configurations inside your struct
       
        Example:
        //Rawcode of a spell based on Slow Aura (Tornado)
        //Will be tackled more on Step 4
        private static constant integer RAWCODE = 'AXYZ'
        private static constant integer DISPEL_TYPE = BUFF_NEGATIVE
        private static constant integer STACK_TYPE =  BUFF_STACK_PARTIAL

       
       
    3. Configure onApply and onRemove methods inside your struct.
       
        Example:
       
        //This will execute when:
        //  - A BUFF_STACK_NONE Buff is removed from a unit.
        //  - A BUFF_STACK_PARTIAL Buff from a certain source is removed from a unit.
        //  - A BUFF_STACK_FULL Buff instance is removed.
        method onRemove takes nothing returns nothing
            //Configure what happens when the Buff is removed.
        endmethod
       
        //This will execute when:
        //  - A BUFF_STACK_NONE/BUFF_STACK_PARTIAL Buff is applied to a unit
        //    not having the same Buff before it is applied.
        //  - A BUFF_STACK_PARTIAL Buff is applied to a unit already having
        //    the same buff but from a different source.
        //  - A BUFF_STACK_FULL Buff is applied to a unit.
        method onApply takes nothing returns nothing
            //Configure what happens when the Buff is applied.
        endmethod
       
   
    4. Create the Buff Objects.
       a. In Object Editor, find "Slow Aura (Tornado)" [Aasl] and use it as the basis 
          to create a new Ability because "Slow Aura (Tornado)" does not appear in the 
          unit command card.
       b. Make sure "Data - Attack Speed Factor" and "Data - Movement Speed Factor"
          are both zero so that it does not do anything. The Buff mechanics/effects will
          be entirely defined by code.
       c. Create a new Buff based on "Tornado (Slow Aura)" [Basl]. It is very important
          that the rawcode of this new Buff is exactly the same as the newly created
          Ability done in Step 4.a except the first letter which depends on the value
          of BUFF_OFFSET.
          Example: 
            BUFF_OFFSET = 0x01000000
                Ability - 'AXYZ'
                Buff    - 'BXYZ'
            BUFF_OFFSET = 0x20000000
                Ability - 'AXYZ'
                Buff    - 'aXYZ'
       d. Edit the Ability: "Stats - Buff" of the new Ability from Step 4.a so 
          that its new Buff is the the Buff created at Step 4.c.
       e. Change the Ability: "Stats - Targets Allowed" to "self"
       f. Change the Buff Icon, Attachment Effects and Tooltips.
   
    5. Configuration is done. You can now easily add the Buff to a unit using:
            <BuffName>.add(source, target)
       
        The system will automatically handles the stacking type of the Buff.


//! endnovjass