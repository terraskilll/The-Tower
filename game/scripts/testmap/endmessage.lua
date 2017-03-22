require("..engine.lclass")
require("..engine.collision.boxcollider")
require("..engine.collision.circlecollider")

local gameobject = nil

local shown = false

scriptsetup = function( object )
  gameobject = object

  gameobject.onCollisionEnter = endCollisionEnter

  local resname, restype, respath = getGame():getResourceManager():getResourceByName( "victorytheme" )

  local audio = getGame():getResourceManager():loadAudio( respath )

  getGame():getAudioManager():addMusic( "victorytheme", audio, 0.5 )
end

endCollisionEnter = function ( caller, otherCollider )

  if ( otherCollider:getOwner():getInstanceName() ~= "PLAYER" ) then
    return
  end

  if  ( not shown ) then
    shown = true

    getGame():getMessageBox():show( "\"FIM\"" , 10 )
    getGame():getAudioManager():stopMusic()
    getGame():getAudioManager():playMusic( "victorytheme", false ) -- does not loop
  end

end
