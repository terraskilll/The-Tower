--[[

a map is a big playable zone (a tower floor, in this game context),
composed of many areas (rooms or similar)

--//TODO remove layer function? duplicated in Area

]]

require("..engine.lclass")
require("..engine.io.io")

class "Map"

function Map:Map( mapName, mapFile )
  self.name = mapName
  self.file = mapFile or ""

  self.nameindex = 0

  self.areas     = {}
  self.areaCount = 0

  self.layers = {}

  self.objectLibrary = {}

  self.movingObjects = {}
end

function Map:getName()
  return self.name
end

function Map:getFileName()
  return self.file
end

function Map:update( dt )

  for _,mo in pairs( self.movingObjects ) do
    mo:update( dt )
  end

end

function Map:setNameIndex( nameIndexToSet )
  self.nameindex = nameIndexToSet
end

function Map:getNameIndex()
  return self.nameindex
end

function Map:getNextGeneratedName()
  self.nameindex = self.nameindex + 1

  return "obj" .. self.nameindex
end

function Map:addArea( area )
  self.areas[area:getName()] = area
  self.areaCount = self.areaCount + 1
end

function Map:getAreas()
  return self.areas
end

function Map:getAreaByName( areaName )
  return self.areas[areaName]
end

function Map:getAreaByIndex ( areaIndex )
  local i = 1

  for _,area in pairs( self.areas ) do
    if ( i == areaIndex ) then
      return area
    end

    i = i + 1
  end

  return nil
end

function Map:getAreaCount()
  return self.areaCount
end

function Map:removeAreaByName( areaName )

  if ( self.areas[areaName] ) then
    self.areas[areaName] = nil
    return true
  else
    return false
  end

end

function Map:addLayer( layerName, layerIndex )
  table.insert( self.layers, { name = layerName, index = layerIndex, collision = true } )

  table.sort( self.layers , function ( l1, l2 ) return l1.index < l2.index end )
end

function Map:enableCollisionForLayer( layerIndex, trueToEnable )

  for i=1, #self.layers do

    if ( layerIndex == self.layers[i].index ) then
      self.layers[i].collision = trueToEnable
      return
    end

  end
end

function Map:getCollisionEnabledForLayer( layerIndex )

  for i=1, #self.layers do

    if ( layerIndex == self.layers[i].index ) then
      return self.layers[i].collision
    end

  end

  return false
end

function Map:getLayers()
  return self.layers
end

function Map:getLayerByName ( layerName )
  --return self.areas[areaName]
  --//TODO
end

function Map:getLayerCount()
  return #self.layers
end

function Map:addMovingObject( objectToAdd )
  self.movingObjects[objectToAdd:getInstanceName()] = objectToAdd
end

function Map:getMovingObjects()
  return self.movingObjects
end

function Map:getMovingObjectByName( objectName )
  return self.movingObjects[objectName]
end

function Map:removeMovingObject( objectName )

  if ( self.movingObjects[objectName] ) then
    self.movingObjects[objectName] = nil
    return true
  else
    return false
  end

end

function Map:getObjectFromLibrary( objectName )
  local obj = self.objectLibrary[objectName]

  return obj
end

function Map:addToLibrary( objectName, object )
  self.objectLibrary[objectName] = object
end

function Map:getLibrary()
  return self.objectLibrary
end

function Map:checkChangedNavMesh( objectPosition, objectMovement )
  --//TODO reprocess navmap for object when navmesh changed?

  local pos = objectPosition + objectMovement

  local nav = nil

  local isIn = false

  for i, fl in pairs( self.areas ) do

    isIn = fl:getNavMesh():isInside( pos.x, pos.y )

    if ( isIn ) then
      nav = fl:getNavMesh()
    end

  end

  for _,mo in pairs( self.movingObjects ) do
    if ( mo:isWalkable() ) then

      isIn = mo:getNavMesh():isInside( pos.x, pos.y )

      if ( isIn ) then
        nav = mo:getNavMesh()
      end

    end
  end

  return nav
end
