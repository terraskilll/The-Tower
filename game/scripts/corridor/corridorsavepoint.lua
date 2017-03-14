require("..engine.lclass")

local gameobject = nil

local saved = false

scriptsetup = function( object )
  gameobject = object

  gameobject.onCollisionEnter = localCollisionEnter
end

localCollisionEnter = function ( caller, otherCollider )

  if ( not saved ) then
    getGame():getSaveGame():setMapName( "corridor" )
    getGame():getSaveGame():setAreaName( "mainarea" )
    getGame():getSaveGame():setSpawnName( "corridorpath" )

    saved = true
  end
end
