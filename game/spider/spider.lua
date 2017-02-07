require("../engine/lclass")

require("../engine/gameobject/actor")
require("../engine/fsm/fsm")
require("../engine/collision/boxcollider")
require("../engine/collision/circlecollider")

local Vec = require("../engine/math/vector")

class "Spider" ("Actor")

function Spider:Spider( spiderName, positionX, positionY )
  self.name      = spiderName
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

  self.collider:update( dt )
end

function Spider:draw()
  --//TODO animations
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
  self.collider = CircleCollider( self.position.x, self.position.y, 16, 0, 0 )
  self.collider:setOwner( self )

  self:setNavAgent( NavAgent(self, self.position.x, self.position.y, 20, 0, 12) )
end
