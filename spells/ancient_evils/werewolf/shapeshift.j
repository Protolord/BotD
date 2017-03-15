scope ShapeShift

    globals
        private constant integer SPELL_ID = 'A2XX'
        private constant string SFX = "Models\\Effects\\ShapeShift.mdx"
        private constant string SFX2 = "Models\\Effects\\ShapeShifting.mdx"
        private constant string LIGHT = "Models\\Effects\\CeilingRays.mdx"
        private constant integer ENTER_ANIMATION = 3  //Animation index to play upon finishing transformation
    endglobals

    struct Shapeshift extends array
        
        private effect sfx
        private effect sfx2
        private unit u
        private unit dummy
        private real duration
        private boolean human
        private boolean transformed
        private real ctr
        
        private Root root
        private TurningOff turnOff
        
        implement CTLExpire
            set this.duration = this.duration - CTL_TIMEOUT
            if this.duration > 0 then
                if this.human then
                    call SetUnitVertexColor(this.dummy, 255, 50, 50, 255 - R2I(255*this.duration))
                else
                    call SetUnitVertexColor(this.dummy, 255, 50, 50, R2I(255*this.duration))
                endif
            elseif this.transformed then
                set this.ctr = this.ctr - CTL_TIMEOUT
                if this.ctr <= 0 then
                    if GetUnitCurrentOrder(this.u) == 0 then
                        call SetUnitAnimation(this.u, "stand")
                    endif
                    call this.root.destroy()
                    call this.turnOff.destroy()
                    set this.u = null
                    call this.destroy()
                endif
            else
                call SetUnitTimeScale(this.u, 1.0)
                call DestroyEffect(AddSpecialEffect(SFX, GetUnitX(this.u), GetUnitY(this.u)))
                call DestroyEffect(this.sfx)
                call DestroyEffect(this.sfx2)
                call RecycleDummy(this.dummy)
                set this.sfx = null
                set this.sfx2 = null
                set this.dummy = null
                if this.human then
                    call IssueImmediateOrderById(this.u, ORDER_stop)
                    call SetUnitAnimationByIndex(this.u, ENTER_ANIMATION)
                    set this.transformed = true
                    set this.root = Root.create(this.u)
                    set this.turnOff = TurningOff.create(this.u)
                    set this.ctr = 1.2
                else
                    set this.u = null
                    call this.destroy()
                endif
            endif
        implement CTLEnd
        
        private static method onCast takes nothing returns nothing
            local unit u = GetTriggerUnit()
            local thistype this = thistype.create()
            local real x = GetUnitX(u)
            local real y = GetUnitY(u)
            set this.dummy = GetRecycledDummyAnyAngle(x, y, 0)
            set this.sfx = AddSpecialEffectTarget(LIGHT, this.dummy, "origin")
            set this.sfx2 = AddSpecialEffect(SFX2, x, y)
            set this.duration = 1.01
            set this.u = u
            set this.transformed = false
            call SetUnitAnimation(u, "death")
            call SetUnitTimeScale(u, 0.5)
            if GetUnitTypeId(u) == 'UWeW' then
                set this.human = false
                call SetUnitVertexColor(this.dummy, 255, 50, 50, 255)
            elseif GetUnitTypeId(u) == 'UWeH' then
                set this.human = true
                call SetUnitVertexColor(this.dummy, 0, 0, 0, 0)
            endif
            set u = null
            call SystemMsg.create(GetUnitName(GetTriggerUnit()) + " cast thistype")
        endmethod
        
        static method init takes nothing returns nothing
            call SystemTest.start("Initializing thistype: ")
            call RegisterSpellEffectEvent(SPELL_ID, function thistype.onCast)
            call SystemTest.end()
        endmethod
        
    endstruct
    
endscope