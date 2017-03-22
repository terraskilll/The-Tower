require("..engine.lclass")
require("..engine.collision.boxcollider")
require("..engine.collision.circlecollider")

local gameobject = nil

local read = false

scriptsetup = function( object )
  gameobject = object

  gameobject.onCollisionEnter = keyCollisionEnter
end

keyCollisionEnter = function ( caller, otherCollider )

  if ( otherCollider:getOwner():getInstanceName() == "PLAYER" ) then

    if  ( not read ) then
      getGame():getMessageBox():show( "\"Abandon All Hope, Ye Who Enter Here\"" , 6 )
      read = true
    end

  end
end
