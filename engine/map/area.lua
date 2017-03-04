--[[

an area is a isolated part of a floor (a room, for example)

only one area is rendered at a time, instead of the whole map (this is not working now)



]]

require("../engine/lclass")
require("../engine/input")

class "Area"

function Area:Area( areaName )
  self.name = areaName

  self.grounds = {}
  self.spawns  = {}

  self.simpleObjects = {}

  self.navmesh = nil
end

function Area:getName()
  return self.name
end

function Area:draw()

  -- Do Nothing?

end

function Area:addSimpleObject( simpleObjectToAdd )

  self.simpleObjects[simpleObjectToAdd:getName()] = simpleObjectToAdd

  if ( self.navmesh ) then
    self.navmesh:addSimpleCollider( simpleObjectToAdd:getCollider() )
  end

end

function Area:getSimpleObjects()
  return self.simpleObjects
end

function Area:getSimpleObjectByName( simpleObjectName )

  if ( self.simpleObjects[simpleObjectName] ) then
    return self.simpleObjects[simpleObjectName]
  end

end

function Area:removeSimpleObject( simpleObjectName )

  if ( self.simpleObjects[simpleObjectName] ) then
    self.simpleObjects[simpleObjectName] = nil
  end

end

function Area:addGround( groundToAdd )
  self.grounds[groundToAdd:getName()] = groundToAdd
end

function Area:getGrounds()
  return self.grounds
end

function Area:getGroundByName( groundName )
  return self.grounds[groundName]
end

function Area:removeGround( groundName )

  if ( self.grounds[groundName] ) then
    self.grounds[groundName] = nil
  end

end

function Area:addSpawnPoint( spawnPointToAdd )
  self.spawns[spawnPointToAdd:getName()] = spawnPointToAdd
end

function Area:getSpawnPoints()
  return self.spawns
end

function Area:getSpawnPointByName( spawnName )
  return self.spawns[spawnName]
end

function Area:removeSpawnPoint( spawnPointName )

  if ( self.spawns[spawnPointName] ) then
    self.spawns[spawnPointName] = nil
  end

end

function Area:setNavMesh( newNavMesh )
  self.navmesh = newNavMesh
  self.navmesh:setOwner( self )
end

function Area:getNavMesh()
  return self.navmesh
end
