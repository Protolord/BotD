module MissileTrajectory

/*
    this.move(x, y, z)
        - Instantly move a missile.
    
    this.launch()
        - Launch a Missile. The Missile will begin to move based on its target type.

    this.speed = <missile speed>
        - Changes a Missile's speed.

    this.speed
        - Returns a Missile's speed.
*/
    public boolean stop
    private real spd
    private real chkDist
    private real dx
    private real dy
    private real dz

    private static constant real MIN_COLLISION = 50.0
    
    method move takes real x, real y, real z returns nothing
        set this.x = x
        set this.y = y
        set this.z = z
        call SetUnitX(this.u, x)
        call SetUnitY(this.u, y)
        call SetUnitFlyHeight(u, z - GetPointZ(x, y), 0)
    endmethod
    
    //! textmacro MISSILE_UPDATE_HAS_TARGET
        set dx = GetUnitX(this.target) - this.x
        set dy = GetUnitY(this.target) - this.y
        set dz = GetUnitZ(this.target) + thistype.Z_OFFSET - this.z
        if dx*dx + dy*dy + dz*dz < this.chkDist then
            call this.move(GetUnitX(this.target), GetUnitY(this.target), GetUnitZ(this.target) + thistype.Z_OFFSET)
            set this.stop = true
            call this.callbackOnHit()
        else
            set facing = Atan2(dy, dx)
            set pitch =  Atan((GetUnitZ(this.target) + thistype.Z_OFFSET - this.z)/SquareRoot(dx*dx + dy*dy))
            set this.x = this.x + this.spd*Cos(facing)*Cos(pitch)
            set this.y = this.y + this.spd*Sin(facing)*Cos(pitch)
            set this.z = this.z + this.spd*Sin(pitch)
            call SetUnitX(this.u, this.x)
            call SetUnitY(this.u, this.y)
            set height = this.z - GetPointZ(this.x, this.y)
            call SetUnitFlyHeight(this.u, height, 0)
            if this.autohide then
                if this.hidden and height >= 0 then
                    set this.hidden = false
                    call ShowDummy(this.u, true)
                elseif not this.hidden and height < 0 then
                    set this.hidden = true
                    call ShowDummy(this.u, false)
                endif
            endif
            call SetUnitFacing(this.u, facing*bj_RADTODEG)
            call SetUnitAnimationByIndex(this.u, R2I(pitch*bj_RADTODEG + 90.5))
        endif
    //! endtextmacro
        
    //! textmacro MISSILE_UPDATE_NO_TARGET
        set dx = this.x2 - this.x
        set dy = this.y2 - this.y
        set dz = this.z2 - this.z
        if dx*dx + dy*dy + dz*dz < this.chkDist then
            call this.move(this.x2, this.y2, this.z2)
            set this.stop = true
            call this.callbackOnHit()
        else
            set this.x = this.x + this.dx
            set this.y = this.y + this.dy
            set this.z = this.z + this.dz
            call SetUnitX(this.u, this.x)
            call SetUnitY(this.u, this.y)
            set height = this.z - GetPointZ(this.x, this.y)
            call SetUnitFlyHeight(this.u, height, 0)
            if this.autohide then
                if this.hidden and height >= 0 then
                    set this.hidden = false
                    call ShowDummy(this.u, true)
                elseif not this.hidden and height < 0 then
                    set this.hidden = true
                    call ShowDummy(this.u, false)
                endif
            endif
        endif
    //! endtextmacro
    
    static method pickAll takes nothing returns nothing
        local thistype this = thistype(0).next
        local real dx
        local real dy
        local real dz
        local real facing
        local real pitch
        local real height
        loop
            exitwhen this == 0
            if not this.stop then
                if this.target == null then
                    //! runtextmacro MISSILE_UPDATE_NO_TARGET()
                else
                    //! runtextmacro MISSILE_UPDATE_HAS_TARGET()
                endif
            endif
            set this = this.next
        endloop
    endmethod
    
    method launch takes nothing returns nothing
        local real dx = this.x2 - this.x
        local real dy = this.y2 - this.y
        local real facing = Atan2(dy, dx)
        local real xy = SquareRoot(dx*dx + dy*dy)
        local real pitch = 0
        set this.stop = false
        if xy > 0 then
            set pitch = Atan((this.z2 - this.z)/xy)
        endif
        if this.target == null then
            set this.dx = this.spd*Cos(facing)*Cos(pitch)
            set this.dy = this.spd*Sin(facing)*Cos(pitch)
            set this.dz = this.spd*Sin(pitch)
        endif
        if this.u == null then
            set this.u = GetRecycledDummy(this.x, this.y, this.z, facing*bj_RADTODEG)
            set this.mdl = AddSpecialEffectTarget(this.mdlPath, this.u, "origin")
        endif
    endmethod
    
    method operator speed= takes real speed returns nothing
        set this.spd = speed*TIMEOUT
        set this.chkDist = RMaxBJ(this.spd*this.spd, thistype.MIN_COLLISION*thistype.MIN_COLLISION)
    endmethod
    
    method operator speed takes nothing returns real
        return this.spd/TIMEOUT
    endmethod

endmodule
