--[[

a map is a big playable zone (a floor, in this game context), 
composed of many areas (rooms or similar)

]]

require("lclass")

class "Map"

function Map:Map()
  self.areas = {}
  self.currentArea = nil
end

function Map:update(dt)
  for _,k in ipairs(self.areas) do
    k:update(dt)
  end
end

function Map:draw()
  self.currentArea:draw()

  --for _,k in ipairs(self.areas) do
    --k:draw(dt)
  --end
end

function Map:addArea(areaToAdd)
  table.insert(self.areas, areaToAdd)
  
  if ( #self.areas == 1 ) then
    self.currentArea = self.areas[1]
  end
end