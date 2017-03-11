require("..engine.lclass")

local gameobject = nil

scriptsetup = function( object )
  gameobject = object

  gameobject.onCollisionEnter = localCollisionEnter
end

localCollisionEnter = function ( otherCollider )
  print( "Im a Warp! I will send you somewhere!" )
  getGame():Message("What!")
end
