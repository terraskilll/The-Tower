require("..engine.lclass")

local gameobject = nil

local saved = false

scriptsetup = function( object )
  gameobject = object

  gameobject.onCollisionEnter = testmapsaveCollisionEnter
end

testmapsaveCollisionEnter = function ( caller, otherCollider )

  print("game saved")

  if ( not saved ) then
    getGame():getSaveGame():setMapName( "testmap" )
    getGame():getSaveGame():setAreaName( "startarea" )
    getGame():getSaveGame():setSpawnName( "spawnpoint" )

    saved = true
  end
end
