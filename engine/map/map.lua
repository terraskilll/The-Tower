--[[

a map is a big playable zone (a tower floor, in this game context),
composed of many areas (rooms or similar)

]]

require("../engine/lclass")

class "Map"

function Map:Map( mapName )
  self.name  = mapName
  self.areas = {}

  self.currentArea = nil
end

function Map:getName()
  return self.name
end

function Map:update(dt)

  for _,k in pairs(self.areas) do
    k:update(dt)
  end

end

function Map:draw()
  self.currentArea:draw()
end

function Map:addArea( areaName, area)
  self.areas[areaName] = area

--[[ --TODO fix?
  print(#self.areas)

  if ( #self.areas == 1 ) then
    self.currentArea = self.areas[1]
  end

  ]]--
end

function Map:setCurrentAreaByName( areaName )
  self.currentArea = self.areas[areaName]
end

function Map:setCurrentAreaByIndex( areaIndex )
  self.currentArea = self.areas[areaIndex]
end
