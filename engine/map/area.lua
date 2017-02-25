--[[

an area is a isolated part of a floor (a room, for example)

only one area is rendered at a time, instead of the whole map (this is not working now)



]]

require("../engine/lclass")
require("../engine/input")

class "Area"

function Area:Area( areaName )
  self.name          = areaName

  self.grounds = {}
  self.spawns  = {}

  self.simpleObjects = {}

  self.navmesh = nil
end

function Area:getName()
  return self.name
end

function Area:draw()

  --//TODO change ground drawing to drawmanager
  for i,gr in pairs(self.grounds) do
    gr:draw()
  end

  for i,sw in pairs(self.spawns) do
    sw:draw()
  end

  self.navmesh:draw()

end

function Area:addGround( groundToAdd )
  self.grounds[groundToAdd:getName()] = groundToAdd
end

function Area:addSpawnPoint( spawnPointToAdd )
  self.spawns[spawnPointToAdd:getName()] = spawnPointToAdd
end

function Area:addSimpleObject( simpleObjectToAdd )
  self.simpleObjects[simpleObjectToAdd:getName()] = simpleObjectToAdd

  if ( self.navmesh ) then
    self.navmesh:addSimpleCollider( simpleObjectToAdd:getCollider() )
  end

end

function Area:getGrounds()
  return self.grounds
end

function Area:getGroundByName( groundName )
  return self.grounds[groundName]
end

function Area:getSpawnPoints()
  return self.spawns
end

function Area:getSpawnPointByName( spawnName )
  return self.spawns[spawnName]
end

function Area:setNavMesh( newNavMesh )
  self.navmesh = newNavMesh
  self.navmesh:setOwner( self )
end

function Area:getNavMesh()
  return self.navmesh
end
