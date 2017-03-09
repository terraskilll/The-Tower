--[[

an area is a isolated part of a floor (a room, for example)

only one area is rendered at a time, instead of the whole map (this is not working now)

--//TODO remove layer function
--//TODO spawn point in layer

]]

require("..engine.lclass")
require("..engine.input")

class "Area"

function Area:Area( areaName )
  self.name = areaName

  self.objects = {}

  self.spawns  = {}

  self.navmesh = nil
end

function Area:getName()
  return self.name
end

function Area:draw()

  -- Do Nothing?

end

function Area:addObject( objectToAdd )

  self.objects[objectToAdd:getInstanceName()] = objectToAdd

  if ( self.navmesh ) then
    self.navmesh:addCollider( objectToAdd:getCollider() ) --//TODO change to navbox
  end

end

function Area:getObjects()
  return self.objects
end

function Area:getObjectByName( instanceName )

  if ( self.objects[instanceName] ) then
    return self.objects[instanceName]
  end

  return nil

end

function Area:removeObject( instanceName )

  if ( self.objects[instanceName] ) then
    self.objects[instanceName] = nil
    return
  end

end

function Area:addSpawnPoint( spawnPointToAdd )
  self.spawns[spawnPointToAdd:getInstanceName()] = spawnPointToAdd
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
