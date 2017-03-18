require("..engine.lclass")

scriptsetup = function( map )
  map.mapOnEnter = corridorMapEnter
end

corridorMapEnter = function ()
  local ki, kn, kv = getGame():getSaveGame():getEventKey( "thisdooropen" )

  if ( kv == 1 ) then
    local object = getGame():queryObjectByName("thedoor")
    getGame():destroy( object )
  end
end
