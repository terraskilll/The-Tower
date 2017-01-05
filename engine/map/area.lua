--[[

an area is a isolated part of a map

]]

require ("lclass")

require("../input")

class "Area"

function Area:Area()
  self.floors = {}
  self.staticObjects = {}
end

function Area:draw()
  for _,f in ipairs(self.floors)  do
    f:draw()
  end

  for  _,so in ipairs(self.staticObjects)  do
    so:draw()
  end
end

function Area:addFloor(floorToAdd)
  table.insert(self.floors, floorToAdd)
end

function Area:addStaticObject(staticObjectToAdd)
  table.insert(self.staticObjects, staticObjectToAdd)
end

function Area:canWalk()
  
end