-------------------------------------------------------------------------------
-- gameobject base class
-------------------------------------------------------------------------------
require ("lclass")

local Vec = require("../math/vector")

class "GameObject"

function GameObject:GameObject()
  self.position = Vec(0,0)
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