require("../input")
require("../engine/fsm/fsm")
require("../engine/collision/boxcollider")

local Vec = require("../math/vector")

class "Spider" ("GameObject")

function Spider:Spider(positionX, positionY)
  self.position  = Vec(positionX, positionY)
  self.direction = Vec(0,0)
  self.speed     = 70

  self.fsm       = nil
  self.map       = nil
  self.collider  = nil

  self:configure()
  
  --//TODO add states and animations
end

function Spider:update(dt)

  --//TODO movement in state
 
  self.collider:update(dt, self.position.x, self.position.y)
end

function Spider:draw()
  --self.fsm:getCurrent():getAnimation():draw(self:getPositionXY())

  local x, y = self:getPositionXY()
  love.graphics.circle( "line", x, y, 20, 10 )
  love.graphics.circle( "line", x, y, 2 )

  self.collider:draw()
end

function Spider:getCollider()
  return self.collider
end

function Spider:configure()
  self.collider = BoxCollider(self.position.x, self.position.y, 30, 10, -15, 0)
end