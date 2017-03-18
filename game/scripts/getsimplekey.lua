require("..engine.lclass")
require("..engine.collision.boxcollider")
require("..engine.collision.circlecollider")

local gameobject = nil

scriptsetup = function( object )
  gameobject = object

  gameobject.onCollisionEnter = keyCollisionEnter

  local resname, restype, respath = getGame():getResourceManager():getResourceByName( "coin2audio" )

  local audio = getGame():getResourceManager():loadAudio( respath )

  getGame():getAudioManager():addSound( "coin2audio", audio, 0.5 )
end

keyCollisionEnter = function ( caller, otherCollider )

  if ( otherCollider:getOwner():getInstanceName() == "PLAYER" ) then
    local name = caller:getInstanceName()

    local objectHit = getGame():queryObjectByName( name )

    if  ( objectHit ) then
      getGame():getAudioManager():playSound( "coin2audio", 0.8 )
      getGame():getInventory():addItem( "simplekey", 1 )
      getGame():destroy( objectHit )
    end
  end
end
