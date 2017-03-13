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

  table.insert( self.objects, objectToAdd )

  if ( self.navmesh ) then
    self.navmesh:addCollider( objectToAdd:getCollider() ) --//TODO change to navbox
  end

end

function Area:getObjects()
  return self.objects
end

function Area:getObjectByName( instanceName )

  for i = 1, #self.objects do
    if ( self.objects[i]:getInstanceName() == instanceName ) then
      return self.objects[i], i
    end
  end

  return nil, 0

end

function Area:removeObject( instanceName )

  local obj, index = self:getObjectByName( instanceName )

  if ( index > 0 ) then
    table.remove( self.objects, index )
    return true
  end

  return false
end

function Area:addSpawnPoint( spawnPointToAdd )
  table.insert( self.spawns, spawnPointToAdd )
end

function Area:getSpawnPoints()
  return self.spawns
end

function Area:getSpawnPointByIndex( index )
  if ( self.spawns[index] ) then
    return self.spawns[index]
  end
end

function Area:getSpawnPointByName( spawnName )

  for i = 1, #self.spawns do
    if ( self.spawns[i]:getInstanceName() == spawnName ) then
      return self.spawns[i], i
    end
  end

  return nil, 0
end

function Area:removeSpawnPoint( spawnName )

  local obj, index = self:getSpawnPointByName( spawnName )

  if ( index > 0 ) then
    table.remove( self.spawns, index )
    return true
  end

  return false
end

function Area:setNavMesh( newNavMesh )
  self.navmesh = newNavMesh
  self.navmesh:setOwner( self )
end

function Area:getNavMesh()
  return self.navmesh
end
