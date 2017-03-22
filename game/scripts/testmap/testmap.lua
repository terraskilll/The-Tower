require("..engine.lclass")

scriptsetup = function( map )
  map.mapOnEnter = testmapMapEnter
end

testmapMapEnter = function ()
  local resname, restype, respath = getGame():getResourceManager():getResourceByName( "abretesesamo_a" )
  local audio = getGame():getResourceManager():loadAudio( respath )
  getGame():getAudioManager():addSound( "abretesesamo_a", audio, 0.4 )
end
