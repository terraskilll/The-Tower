require("..engine.lclass")
require("..engine.collision.boxcollider")
require("..engine.collision.circlecollider")

local gameobject = nil

scriptsetup = function( object )
  gameobject = object

  gameobject.onCollisionEnter = collisionEnter
end

collisionEnter = function ( caller, otherCollider )

  if ( otherCollider:getOwner():getInstanceName() == "PLAYER" ) then
    local name = caller:getInstanceName()

    local objectHit = getGame():queryObjectByName( name )

    if  ( objectHit ) then
      local posx, posy = objectHit:getPositionXY()

      local layer = objectHit:getLayer()

      getGame():destroy( objectHit )

      getGame():addObject( "coin", "mainarea", posx + 40, posy, layer )
    end
  end

  -- if ( otherCollider:getOwner():getTag() == "PLAYER" ) then
  --   print( "Collided with coin" )
  -- end

  --//TODO destroy coin
end
