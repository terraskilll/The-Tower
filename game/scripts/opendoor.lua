require("..engine.lclass")
require("..engine.collision.boxcollider")
require("..engine.collision.circlecollider")

local gameobject = nil

scriptsetup = function( object )
  gameobject = object

  gameobject.onCollisionEnter = doorCollisionEnter
end

doorCollisionEnter = function ( caller, otherCollider )

  if ( otherCollider:getOwner():getInstanceName() == "PLAYER" ) then
    local name = caller:getInstanceName()

    local objectHit = getGame():queryObjectByName( name )

    if  ( objectHit ) then
      if ( getGame():getInventory():consumeItem( "simplekey" ) ) then
        getGame():destroy( objectHit )
        getGame():getSaveGame():addEventKey( "thisdooropen", 1 )
      end
    end

  end
end
