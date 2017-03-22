require("..engine.lclass")

local shown = false

scriptsetup = function( object )
  object.onCollisionEnter = invisibleCollisionEnter

  local resname, restype, respath = getGame():getResourceManager():getResourceByName( "caminho_invisivel_a" )
  local audio = getGame():getResourceManager():loadAudio( respath )
  getGame():getAudioManager():addSound( "caminho_invisivel_a", audio, 0.4 )
end

invisibleCollisionEnter = function ( caller, otherCollider )

  if ( otherCollider:getOwner():getInstanceName() ~= "PLAYER" ) then
    return
  end

  if  ( not shown ) then
    shown = true
    getGame():getAudioManager():playSound( "caminho_invisivel_a" )
  end

end
