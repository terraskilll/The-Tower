--[[

a floor is a part of an area. it has its own navmesh

]]

require("../engine/lclass")

require("../engine/input")

class "Floor"

function Floor:Floor( floorName )
  self.name    = floorName
  self.grounds = {}
  self.spawns  = {}

  self.simpleObjects = {}

  self.navmesh = nil
end

function Floor:getName()
  return self.name
end

function Floor:draw()
  --//TODO change ground drawing to drawmanager
  for i,gr in pairs(self.grounds) do
    gr:draw()
  end

  for i,sw in pairs(self.spawns) do
    sw:draw()
  end

  self.navmesh:draw()
end

function Floor:addGround( groundName, ground )
  self.grounds[groundName] = ground
end

function Floor:addSpawnPoint( spanwName, spawnPoint )
  self.spawns[spanwName] = spawnPoint
end

function Floor:addSimpleObject( objectName, simpleObjectToAdd )
  self.simpleObjects[objectName] = simpleObjectToAdd

  if ( self.navmesh ~= nil ) then
    self.navmesh:addSimpleCollider( simpleObjectToAdd:getCollider() )
  end

end

function Floor:getGrounds()
  return self.grounds
end

function Floor:getGroundByName( groundName )
  return self.grounds[groundName]
end

function Floor:getSpawnPoints()
  return self.spawns
end

function Floor:getSpawnPointByName( spawnName )
  return self.spawns[spawnName]
end

function Floor:setNavMesh( newNavMesh )
  self.navmesh = newNavMesh
  self.navmesh:setOwner( self )
end

function Floor:getNavMesh()
  return self.navmesh
end
