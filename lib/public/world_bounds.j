library WorldBounds /* v2.0.0.0
************************************************************************************
*
*    struct WorldBounds extends array
*
*    Fields
*    -------------------------
*
*    readonly static integer maxX
*    readonly static integer maxY
*    readonly static integer minX
*    readonly static integer minY
*
*    readonly static integer centerX
*    readonly static integer centerY
*
*    readonly static rect world
*    readonly static region worldRegion
*
************************************************************************************/
private module WorldBoundInit

    private static method onInit takes nothing returns nothing
        set world = GetWorldBounds()
        set maxX = R2I(GetRectMaxX(world))
        set maxY = R2I(GetRectMaxY(world))
        set minX = R2I(GetRectMinX(world))
        set minY = R2I(GetRectMinY(world))
        set centerX = R2I((maxX + minX)/2)
        set centerY = R2I((minY + maxY)/2)
        set playMaxX = GetRectMaxX(bj_mapInitialPlayableArea)
        set playMaxY = GetRectMaxY(bj_mapInitialPlayableArea)
        set playMinX = GetRectMinX(bj_mapInitialPlayableArea)
        set playMinY = GetRectMinY(bj_mapInitialPlayableArea)
        set worldRegion = CreateRegion()
        call RegionAddRect(worldRegion, world)
        endmethod
    endmodule

    struct WorldBounds extends array
        readonly static integer maxX
        readonly static integer maxY
        readonly static integer minX
        readonly static integer minY
        readonly static integer centerX
        readonly static integer centerY
        readonly static rect world
        readonly static region worldRegion
        readonly static real playMaxX
        readonly static real playMaxY
        readonly static real playMinX
        readonly static real playMinY
        implement WorldBoundInit
    endstruct

endlibrary

//! textmacro WORLDBOUNDS_CHECK takes X, Y
    if $X$ > WorldBounds.maxX then
        set $X$ = WorldBounds.maxX
    elseif $X$ < WorldBounds.minX then
        set $X$ = WorldBounds.minX
    endif
    if $Y$ > WorldBounds.maxY then
        set $Y$ = WorldBounds.maxY
    elseif $Y$ < WorldBounds.minY then
        set $Y$ = WorldBounds.minY
    endif
//! endtextmacro