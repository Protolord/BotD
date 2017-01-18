library SetUnitZ

/*
    function GetPointZ(x, y)
        - Get z-coordinate of the ground in (x, y)

    function GetUnitZ(u)
        - Get z-coordinate of a unit. Flying height is considered.

    function SetUnitZ(u, z)
        - Set the z-coordinate of a unit.

    UnitZ.height
        - New height of the unit used in SetUnitZ

*/

    private struct S extends array
        readonly static location l = Location(0, 0)
    endstruct
    
    function GetPointZ takes real x, real y returns real
        call MoveLocation(S.l, x, y)
        return GetLocationZ(S.l)
    endfunction
    
    function GetUnitZ takes unit u returns real
        return GetUnitFlyHeight(u) + GetPointZ(GetUnitX(u), GetUnitY(u))
    endfunction
    
    function SetUnitZ takes unit u, real z returns nothing
        call SetUnitFlyHeight(u, z - GetPointZ(GetUnitX(u), GetUnitY(u)), 0)
    endfunction
    
endlibrary
