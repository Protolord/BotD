library Unselectable

/*
    Unselectable(u, transformId)
        - Make a unit unselectable using a Transform Ability.
        - Do not show HP Bar and cannot be selectable.
        - Unit is still targetable.
*/
    function Unselectable takes unit u, integer id returns nothing
        call UnitRemoveAbility(u, 'Aloc')
        call UnitAddAbility(u, id)
        call UnitRemoveAbility(u, id)
    endfunction

endlibrary