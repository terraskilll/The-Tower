--[[

an area is a isolated part of a map (a room, for example)

only one area is rendered at a time, instead of the whole map

]]

require("../engine/lclass")

require("../engine/input")

class "Area"

function Area:Area( areaName )
  self.name   = areaName
  self.floors = {}
end

function Area:getName()
  return self.name
end

function Area:draw()
  for i,fl in pairs(self.floors) do
    fl:draw()
  end
end

function Area:addFloor( floorName, floor)
  self.floors[floorName] = floor
end

function Area:getFloors()
  return self.floors
end

function Area:getFloorByName ( floorName )
  return self.floors[floorName]
end
