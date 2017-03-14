require("..engine.lclass")
require("..engine.collision.boxcollider")
require("..engine.collision.circlecollider")

local gameobject = nil

scriptsetup = function( object )
  gameobject = object

  gameobject.onCollisionEnter = onCollisionEnter
end

onCollisionEnter = function ( other, infoindex )

  --print( "Object Kind: " .. gameobject:getCollider():getKind() )
  --print( "Other Kind: " .. other:getOwner():getInstanceName() )

  print( info )

  local info = getGame():getCollisionManager():getCollisionInfo( infoindex )

  -- if ( otherCollider:getOwner():getTag() == "PLAYER" ) then
  --   print( "Collided with coin" )
  -- end

  --//TODO destroy coin
end
