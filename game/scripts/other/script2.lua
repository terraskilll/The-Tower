require("..engine.lclass")

local gameobject = nil

scriptsetup = function( object )
  gameobject = object

  gameobject.onCollisionEnter = localCollisionEnter
end

localCollisionEnter = function ( otherCollider )
  print( "Hello! Im a windmill!" )
end
