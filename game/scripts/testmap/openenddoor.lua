openEndDoor = function ()
  print( "End Door" )

  local ri, rv, rk = getGame():getSaveGame():getEventKey( "redkeyopen" )
  local gi, gv, gk = getGame():getSaveGame():getEventKey( "greenkeyopen" )
  local bi, bv, bk = getGame():getSaveGame():getEventKey( "bluekeyopen" )

  print ( ri .. gi .. bi )
end
