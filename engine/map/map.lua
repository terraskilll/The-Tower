--[[

a map is a big playable zone (a tower floor, in this game context),
composed of many floors (rooms or similar)

]]

require("../engine/lclass")
require("../engine/io/io")

class "Map"

function Map:Map( mapName )
  self.name       = mapName
  self.floors     = {}
  self.floorCount = 0

  self.currentFloor = nil

  self.objectList = {}

  self:loadFromFile( mapName )
end

function Map:getName()
  return self.name
end

function Map:update( dt )

  for _,a in pairs( self.floors ) do
    a:update( dt )
  end

end

function Map:draw()
  self.currentFloor:draw()
end

function Map:getObjectList()
  return self.objectList
end

function Map:addFloor( floorToAdd )
  self.floors[floorToAdd:getName()] = floorToAdd

  self.floorCount = self.floorCount + 1

  if ( self.floorCount == 1 ) then
    self.currentFloor = self.floors[floorToAdd:getName()]
  end

end

function Map:getFloorByName( floorName )

  if ( self.floors[floorName] ) then
    return self.floors[floorName]
  else
    return nil
  end

end

function Map:removeFloorByName( floorName )

  if ( self.floors[floorName] ) then
    self.floors[floorName] = nil
    return true
  else
    return false
  end

end

function Map:setCurrentFloorByName( floorName )
  self.currentFloor = self.floors[floorName]
end

function Map:getFloorCount()
  return self.floorCount
end

function Map:loadFromFile( mapName )
  mapdata, err = loadFile("__maps/" .. mapName)

  if ( err ) then
    return
  end

  --//TODO load map from file
end
