--[[
a walkable part in a area
]]

require("lclass")

local Vec = require("../math/vector")

class "Floor"

function Floor:Floor(positionX, positionY, floorImage)
  self.position = Vec(positionX, positionY)
  self.image = floorImage
end

function Floor:update(dt)
  -- ?
end

function Floor:draw()  
  love.graphics.draw(self.image, self.position.x, self.position.y)
end