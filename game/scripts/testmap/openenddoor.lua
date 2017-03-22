openEndDoor = function ()
  print( "End Door" )

  local ri, rv, rk = getGame():getSaveGame():getEventKey( "redkeyopen" )
  local gi, gv, gk = getGame():getSaveGame():getEventKey( "greenkeyopen" )
  local bi, bv, bk = getGame():getSaveGame():getEventKey( "bluekeyopen" )

  if ( bk ) and ( gk ) and ( rk ) then
    local dooraObj = getGame():queryObjectByName("doora")
    local doorbObj = getGame():queryObjectByName("doorb")

    dooraObj:setProperty( 1 )
    doorbObj:setProperty( 1 )

    getGame():getAudioManager():playSound( "abretesesamo_a" )
  end
end
