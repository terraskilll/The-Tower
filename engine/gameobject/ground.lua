--[[
a walkable part in a area
]]

require("../engine/lclass")

require("../engine/collision/boxcollider")

local Vec = require("../engine/math/vector")

class "Ground" ("StaticObject")

function Ground:Ground(positionX, positionY, groundImage, groundQuad, objectScale)
  self.position = Vec(positionX, positionY)
  self.image    = groundImage
  self.quad     = groundQuad
  self.scale    = objectScale

  self.stair = false
end

function Ground:setAsStair(isStair)
  self.stair = isStair
end
