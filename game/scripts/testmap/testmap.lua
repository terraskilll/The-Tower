require("..engine.lclass")

scriptsetup = function( map )
  map.mapOnEnter = testmapMapEnter

  --//TODO load audios here
  -- local resname, restype, respath = getGame():getResourceManager():getResourceByName( "coin2audio" )
  --
  -- local audio = getGame():getResourceManager():loadAudio( respath )
  --
  -- getGame():getAudioManager():addSound( "coin2audio", audio, 0.5 )
end

testmapMapEnter = function ()
  print( "Map Enter" )
  -- local ki, kn, kv = getGame():getSaveGame():getEventKey( "thisdooropen" )
  --
  -- if ( kv == 1 ) then
  --   local object = getGame():queryObjectByName( "thedoor" )
  --   getGame():destroy( object )
  -- end
end
