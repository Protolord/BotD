//! novjass

    /*
                             DamagePackage v1.45
                                Documentation
                                  by Flux

        Contains libraries for your damage detection, distinction and manipulation needs.

        -----------
        DamageEvent
        -----------
            A lightweight damage detection system that
            detects when a unit takes damage.
            Can distinguish physical and magical damage.

        ------------
        DamageModify
        ------------
            An add-on to DamageEvent that allows modification
            of damage taken before it is applied.


        -------------
        DamageObjects
        -------------
            Automatically generates required Objects by DamageEvent and
            DamageModify.

    CONTENTS:
        - API
        - How to use DamagePackage
        - Important Notes
        - Credits
        - Changelog

    //==================================================================//
                                      API:
    //==================================================================//
    */

    DamageEvent:
        -----------------------------
              DAMAGE PROPERTIES
        -----------------------------
        Damage.source
            // Unit that dealt the damage.
        Damage.target
            // Unit that took the damage.
        Damage.amount
            // Amount of damage taken.
        Damage.type
            // The type of damage taken.
            // Values can be DAMAGE_TYPE_PHYSICAL or DAMAGE_TYPE_MAGICAL.

        -----------------------------
               DAMAGE CALLBACKS
        -----------------------------
        Damage.register(code)
            // Registers a code that will permanently run when a registered
            // unit takes damage.
        Damage.registerTrigger(trigger)
            // Registers a trigger that will run when a registered unit takes
            // damage. The trigger can be disabled to avoid an infinite loop.
            // Triggers will execute depending on the order they are registered.
        Damage.unregisterTrigger(trigger)
            // Removes the event in the trigger, causing the trigger to no longer
            // run when a registered unit takes damage.
        Damage.add(unit)
            // For manual registration of units to DamageEvent. You
            // won't use this if AUTO_REGISTER is set to true.

        -----------------------------
               MISCELLANEOUS
        -----------------------------
        Damage.enabled
            //Turns on/off the entire DamageEvent.
        Damage.lockAmount()
            //Prevents further modification of damage on this damage instance.
        Damage.triggeringTrigger
            // The trigger that causes the event to run

    DamageModify
        set Damage.amount = <new amount>
            // Modify the damage taken before it is applied.

        Damage.registerModifier(code)
            // Registers a code that will permanently run when a
            // registered unit takes damage executing before any callbacks
            // registered via Damage.register(code)/Damage.registerTrigger(trigger).

        Damage.registerModifierTrigger(trigger)
            // Registers a trigger that will run when a registered unit
            // takes damage executing before any callbacks registered
            // via Damage.register(code)/Damage.registerTrigger(trigger).
            // The trigger can be disabled to avoid an infinite loop.

        Damage.unregisterModifierTrigger(trigger)
            // Removes the event in the trigger, it will no longer evaluate
            // and execute when a registered unit takes damage.

    /*

    //==================================================================//
                          HOW TO USE DAMAGE PACKAGE:
    //==================================================================//

        1. Decide whether you need to use DamageEvent or DamageEvent with DamageModify.
           If you only want to detect the damage and the type of damage, DamageEvent
           will suffice, but if you want to modify the Damage taken, then you need
           DamageModify. Note that DamageEvent without DamageModify is designed to be
           lightweight, therefore it is better not to have DamageModify if you do not
           need it. Using DamageModify is 90 to 100 microseconds slower.

        2. Define Basic configuration of DamageEvent
            */
            private constant integer DAMAGE_TYPE_DETECTOR
                //An ability based on Runed Bracer that is utilized by DamageEvent to distinguish
                //PHYSICAL and MAGICAL damage.

            private constant real ETHEREAL_FACTOR
                //Using DamageEvent disables the ethereal factor configured in Gameplay Constants as
                //a side effect of Runed Bracer. However, the system simulates ethereal amplification
                //and this is the new ethereal factor for magic damage. The configured ethereal factor
                //in Gameplay Constants will be completely ignored.
            .
            private constant boolean AUTO_REGISTER
                //Determines whether units entering the map are automatically registered
                //to the DamageEvent system

            private constant boolean PREPLACE_INIT
                //Auto registers units initially placed in World Editor.

            private constant integer COUNT_LIMIT
                //When the number of registered individual unit in the current DamageBucket
                //reaches COUNT_LIMIT, the system will find a new DamageBucket with units less
                //than COUNT_LIMIT and use it as the new current DamageBucket. If none is found,
                //the system will create a new DamageBucket.

            private constant real REFRESH_TIMEOUT
                //Periodic Timeout of Trigger Refresh.
                //Every REFRESH_TIMEOUT, the system will refresh a signle DamageBucket.

            private constant integer SET_MAX_LIFE
                //An ability based on Item Life Bonus that is utilized by DamageModify to
                //manipulate damage taken.
        /*


        3. Register a code or a trigger that will run when a registered unit takes damage. Example:
            */
            //USING CODE PARAMETER
                library L initializer Init

                    private function OnDamage takes nothing returns nothing
                        //This will run whenever a unit registered takes damage.
                        //Do you thing here
                    endfunction

                    private function Init takes nothing returns nothing
                        call Damage.register(function OnDamage)
                    endfunction

                endlibrary

            //USING TRIGGER PARAMETER
                library L initializer Init

                    globals
                        private trigger trg = CreateTrigger()
                    endglobals

                    private function OnDamage takes nothing returns boolean
                        //This will run whenever a unit registered takes damage.
                        return false
                    endfunction

                    private function Init takes nothing returns nothing
                        call Damage.registerTrigger(trg)
                        call TriggerAddCondition(trg, Condition(function OnDamage))
                    endfunction

                endlibrary

                // You would want to use Damage.registerTrigger when avoiding recursion loop
                // because the trigger can be disabled unlike code.

            /*

        4. If you want to modify the damage taken, you need the DamageModify library.
           Simply change Damage.amount to whatever you want the new damage value to be.
           Example:
           */
                library L initializer Init

                    private function OnDamage takes nothing returns nothing
                        //All damage taken will be amplied by two
                        set Damage.amount = 2*Damage.amount
                    endfunction

                    private function Init takes nothing returns nothing
                        call Damage.registerModifier(function OnDamage)
                    endfunction

                endlibrary
            /*
            DamageModify callbacks and triggers runs first before DamageEvent callbacks
            and triggers. Example:
            */
                library L initializer Init

                    private function OnDamageModifier takes nothing returns nothing
                        set Damage.amount = 0   //This will cause all damage taken to be zero
                    endfunction

                    private function OnDamage takes nothing returns nothing
                        call BJDebugMsg(GetUnitName(Damage.target) " takes " + R2S(Damage.amount) + " damage")
                        //Will print:
                        //"<Target Name> takes 0 damage"
                    endfunction

                    private function Init takes nothing returns nothing
                        call Damage.registerModifier(function OnDamageModifier)
                        call Damage.register(function OnDamageModifier)
                    endfunction

                endlibrary
            /*

        5. If you want to deal damage inside onDamage callback without causing infinite loops,
           you can do so using Damage.registerTrigger(trigger) and disabling the trigger before
           the new damage is applied then enabling it again after damage is applied. Example:
           */
                library L initializer Init

                    globals
                        private trigger trg = CreateTrigger()
                    endglobals

                    private function OnDamage takes nothing returns boolean
                        call BJDebugMsg(GetUnitName(Damage.target) " takes " + R2S(Damage.amount) + " damage")
                        call DisableTrigger(thistype.trg)
                        call UnitDamageTarget(Damage.source, Damage.target, 42.0, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
                        call EnableTrigger(thistype.trg)
                        call BJDebugMsg(GetUnitName(Damage.target) " takes an extra 42 damage.")
                        return false
                    endfunction

                    private function Init takes nothing returns nothing
                        call Damage.registerTrigger(trg)
                        call TriggerAddCondition(trg, Condition(function OnDamage))
                    endfunction

                endlibrary
            /*


    //==================================================================//
                               IMPORTANT NOTES:
    //==================================================================//

        - Life Drain will not work with this system.

        - Locust Swarm abilities will still work, but the "Data - Damage Return Factor"
          defined in Object Editor must be multiplied to -1. Example, to fix the
          default Locust Swarm ability, change the value from 0.75 to -0.75

        - Runed Bracer items and abilities will not work with this system. But one
          can easily make a trigger for that.

        - Mana Shield works normally.

        - Artillery attacks that causes unit to explode on death works normally.

        - Finger of Death works normally.

        - Spirit Link will not work with this system. However, it is possible to
          recreate a triggered version of Spirit Link using this system.

        - Magic Attacks are detected as DAMAGE_TYPE_PHYSICAL while Spells Attack
          are detected as DAMAGE_TYPE_MAGICAL.


    //==================================================================//
                                   CREDITS:
    //==================================================================//

        looking_for_help
            - for the Runed Bracer trick allowing this system to distinguish PHYSICAL
              and MAGICAL damage.
            - for Physical Damage Detection System which was used as a reference for
              creating this system.

        Bribe
            - for the optional Table

        Cokemonkey11 and PurplePoot
            - for the bucket-based damage detection systems for less processes per refresh.

        Aniki, Quilnez and Wietlol
            - for finding bugs, giving feedbacks and suggestions.



    //==================================================================//
                                   CHANGELOG:
    //==================================================================//
        v1.00 - [3 Aug 2016]
         - Initial Release

        v1.10 - [7 Aug 2016]
         - Fixed unremoved and unintentional BJDebug Messages.
         - Fixed unremoved group in preplace.
         - Fixed uncleaned Table/hashtable timer handle id.
         - Fixed "Nonrecursive Damage bug".
         - Fixed HP Bar flickering bug.
         - Fixed a bug where revived units are not registered.
         - Optimized the script, now only uses 1 static timer.
         - Replaced UnitAlive by GetUnitTypeId as the condition for removal.
         - Removed optional requirements TimerUtils and TimerUtilsEx.
         - Implemented a periodic refresh mechanism.
         - Implemented the bucket technique to limit the number of units per refresh.

        v1.11 - [7 Aug 2016]
         - Fixed a bug where it does not auto-register preplaced units when using Table.
         - Fixed some functions compiling to trigger evaluation due to the order.
         - Added a filter when using AUTO_REGISTER.

        v1.12 - [8 August 2016]
         - Fixed a bug when all DamageBuckets are removed.
         - Fixed a bug where currentBucket points to a destroyed DamageBucket
           when it is destroyed.
         - Fixed unremoved saved boolean in Table/hashtable.
         - AutoRegisterFilter is now also applied to preplaced units.

        v1.20 - [17 August 2016]
         - Fixed recursion bug.
         - Added Damage.enabled to control whether DamageEvent callbacks are ON/OFF.
         - Added Damage.registerPermanent(code).
         - Renamed Damage.registerFirst(code) to Damage.registerModifier(code).
         - Damage.registerModifier(code) only comes within DamageModify.
         - SET_MAX_LIFE of DamageModify is now preloaded.

        v1.30 - [15 October 2016]
         - Added more detailed documentation with examples.
         - Now uses life change event instead of a timer avoiding several bugs.
         - Fixed recursion damage workaround.
         - Optimized and shortened the code.

        v1.40 - [29 March 2017]
         - Implemented a stack to make Damage.source, Damage.target, Damage.amount and Damage.type behave like local variables in the callback.
         - Fixed Damage.source and Damage.target changing unit value withing callback due to recursion.
         - Fixed Damage.amount and Damage.type changing value within callback due to recursion.
         - Improved documentation on how it affects default Warcraft 3 abilities.

        v1.41 - [24 May 2017]
         - Added Damage.lockAmount() feature.
         - Fixed bug occuring when units with very high hp takes damage.
         - Changing Damage.amount will no longer work on non-modifier codes/triggers.

        v1.42 - [25 May 2017]
         - Fixed bug occuring when units with very high hp takes very small damage.

        v1.43 - [29 May 2017]
         - Fixed bug when magic damage amount is between 0.125 to 0.2.

        v1.44 - [3 June 2017]
         - Fixed bug when magic damage exceeds max hitpoints.

        v1.45 - [22 July 2017]
         - Added Damage.triggeringTrigger.

    */


//! endnovjass