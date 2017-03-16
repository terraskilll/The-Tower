require("..engine.lclass")

local gameobject = nil

local saved = false

scriptsetup = function( object )
  gameobject = object

  gameobject.onCollisionEnter = localCollisionEnter
end

localCollisionEnter = function ( caller, otherCollider )

  getGame():changeMap( "centered", "mainarea", "startpoint")
end
