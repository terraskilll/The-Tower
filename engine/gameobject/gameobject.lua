-------------------------------------------------------------------------------
-- gameobject base class
-------------------------------------------------------------------------------
require ("../engine/lclass")

local Vec = require("../engine/math/vector")

class "GameObject"

function GameObject:GameObject(positionX, positionY)
  self.position = Vec(positionX, positionY)
end

function GameObject:update(dt)
  print("default gameboject update method : need override")
end

function GameObject:draw()
  print("default gameboject draw method : need override")
end

function GameObject:getPositionXY()
  return self.position.x, self.position.y
end

function GameObject:incPosition(incVector)
  self.position = self.position + incVector
end
