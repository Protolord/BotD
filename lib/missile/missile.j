library Missile uses DummyRecycler, SetUnitZ, TimerUtilsEx,

/*

Missile:

    Missile.create()
        - Create a Missile.
    
    this.sourceUnit = <unit>
        - Set the unit source of the Missile.
    
    this.sourceXYZ(x, y, z)
        - Set the position source of the Missile.
    
    this.targetUnit = <unit>
        - Make a Missile target a unit.
    
    this.targetXYZ(x, y, z)
        - Make a Missile target a position.
    
    this.model = <string model path>
        - Set the model of the Missile.
    
    this.render()
        - Renders the Missile based on its model path.
    
    this.destroy()
        - Destroy the Missile instance.

MissileTrajectory:

    this.move(x, y, z)
        - Instantly move a missile.
    
    this.launch()
        - Launch a Missile. The Missile will begin to move based on its target type.
        - Also renders the Missile.

    this.speed = <missile speed>
        - Changes a Missile's speed.

    this.speed
        - Returns a Missile's speed.

MissileCallback:
     Missile.getHit()
        - Returns the Missile instance that hits its unit target or reached its position.
    
    this.registerOnHit(code)
        - Register a code that will execute when a Missile instance hits its unit target or reached its position.
*/
    
    struct Missile extends array
        implement Alloc
        implement MissileTrajectory
        implement MissileCallback
        
        public boolean autohide
        private boolean hidden
        
        readonly real x
        readonly real y
        readonly real z
        readonly real x2
        readonly real y2
        readonly real z2
        readonly unit target
        readonly unit u
        
        private string mdlPath
        private effect mdl
        
        readonly thistype next
        readonly thistype prev
        
        private static timer t = CreateTimer()
        
        private static constant real TIMEOUT = 0.03125
        private static constant real Z_OFFSET = 75
        
        method destroy takes nothing returns nothing
            set this.prev.next = this.next
            set this.next.prev = this.prev
            if thistype(0).next == 0 then
                call PauseTimer(thistype.t)
            endif
            call DestroyEffect(this.mdl)
            call DummyAddRecycleTimer(this.u, 3.0)
            set this.speed = 0
            set this.mdl = null
            set this.u = null
            set this.target = null
            call this.deallocate()
        endmethod
        
        method operator model= takes string s returns nothing
            set this.mdlPath = s
        endmethod
        
        method render takes nothing returns nothing
            set this.u = GetRecycledDummyAnyAngle(this.x, this.y, this.z)
            set this.mdl = AddSpecialEffectTarget(this.mdlPath, this.u, "origin")
        endmethod
        
        method sourceXYZ takes real x, real y, real z returns nothing
            set this.x = x
            set this.y = y
            set this.z = z
        endmethod
        
        method operator sourceUnit= takes unit u returns nothing
            set this.x = GetUnitX(u)
            set this.y = GetUnitY(u)
            set this.z = GetUnitZ(u) + thistype.Z_OFFSET
        endmethod
        
        method targetXYZ takes real x, real y, real z returns nothing
            set this.target = null
            set this.x2 = x
            set this.y2 = y
            set this.z2 = z
        endmethod
        
        method operator targetUnit= takes unit u returns nothing
            set this.target = u
            set this.x2 = GetUnitX(u)
            set this.y2 = GetUnitY(u)
            set this.z2 = GetUnitZ(u) + thistype.Z_OFFSET
        endmethod
        
        static method create takes nothing returns thistype
            local thistype this = thistype.allocate()
            set this.mdlPath = ""
            set this.stop = true
            set this.autohide = true
            set this.hidden = false
            set this.next = 0
            set this.prev = thistype(0).prev
            set this.next.prev = this
            set this.prev.next = this
            if this.prev == 0 then
                call TimerStart(thistype.t, thistype.TIMEOUT, true, function thistype.pickAll)
            endif
            return this
        endmethod
        
    endstruct
    
endlibrary