--[[

a map is a big playable zone (a tower floor, in this game context),
composed of many areas (rooms or similar)

--//TODO remove layer function? duplicated in Area

]]

require("../engine/lclass")
require("../engine/io/io")

class "Map"

function Map:Map( mapName )
  self.name = mapName

  self.areas         = {}
  self.areaCount     = 0
  self.movingObjects = {}

  self:loadFromFile( mapName )
end

function Map:getName()
  return self.name
end

function Map:update( dt )
--[[
  for _,a in pairs( self.areas ) do
    a:update( dt )
  end
]]

  for _,mo in pairs( self.movingObjects ) do
    mo:update( dt )
  end

end

function Map:addArea( area )
  self.areas[area:getName()] = area
  self.areaCount = self.areaCount + 1
end

function Map:getAreas()
  return self.areas
end

function Map:getAreaByName ( areaName )
  return self.areas[areaName]
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

function Map:addMovingObject( objectToAdd )
  self.movingObjects[objectToAdd:getName()] = objectToAdd
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

function Map:checkChangedNavMesh( objectPosition, objectMovement )
  local pos = objectPosition + objectMovement

  local nav = nil

  local isIn = false

  for i, fl in pairs( self.areas ) do

    isIn = fl:getNavMesh():isInside( pos.x, pos.y )

    if (isIn) then
      nav = fl:getNavMesh()
    end

  end

  for _,mo in pairs( self.movingObjects ) do
    if ( mo:isWalkable() ) then

      isIn = mo:getNavMesh():isInside( pos.x, pos.y )

      if (isIn) then
        nav = mo:getNavMesh()
        --//TODO reprocess navmap for object when navmesh changed?
      end

    end
  end

  return nav
end

function Map:loadFromFile( mapName )
  mapdata, err = loadFile("__maps/" .. mapName)

  if ( err ) then
    return
  end

  --//TODO load map from file (use map manager?)
end
