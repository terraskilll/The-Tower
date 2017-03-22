require("..engine.lclass")
require("..engine.collision.boxcollider")
require("..engine.collision.circlecollider")

local read = false

scriptsetup = function( object )
  object.onCollisionEnter = signCollisionEnter

  local resname, restype, respath = getGame():getResourceManager():getResourceByName( "animador_a" )
  local audio = getGame():getResourceManager():loadAudio( respath )
  getGame():getAudioManager():addSound( "animador_a", audio, 0.4 )
end

signCollisionEnter = function ( caller, otherCollider )

  if ( otherCollider:getOwner():getInstanceName() == "PLAYER" ) then

    if  ( not read ) then
      getGame():getMessageBox():show( "\"Abandon All Hope, Ye Who Enter Here\"" , 6 )
      getGame():getAudioManager():playSound( "animador_a" )
      read = true
    end

  end
end
