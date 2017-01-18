module MissileCallback    

/*
    Missile.getHit()
        - Returns the Missile instance that hits its unit target or reached its position.
    
    this.registerOnHit(code)
        - Register a code that will execute when a Missile instance hits its unit target or reached its position.
*/
    //On Hit
    private static trigger array trgOnHit
    private static thistype hittingObj
    
    static method getHit takes nothing returns thistype
        return thistype.hittingObj
    endmethod
    
    method callbackOnHit takes nothing returns nothing
        if thistype.trgOnHit[this] != null then
            set thistype.hittingObj = this
            call TriggerEvaluate(thistype.trgOnHit[this])
            call DestroyTrigger(thistype.trgOnHit[this])
            set thistype.trgOnHit[this] = null
        endif
    endmethod
    
    method registerOnHit takes code c returns nothing
        set thistype.trgOnHit[this] = CreateTrigger()
        call TriggerAddCondition(thistype.trgOnHit[this], Filter(c))
    endmethod
        
endmodule