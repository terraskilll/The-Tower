require("..engine.lclass")

require("..engine.gameobject/actor")
require("..engine.fsm/fsm")
require("..engine.collision/boxcollider")
require("..engine.collision/circlecollider")
require("..engine.ai/fov")

local Vec = require("..engine.math.vector")

class "Spider" ("Actor")

function Spider:Spider( spiderName, instName, positionX, positionY )
  self.instancename = instName

  self.name      = spiderName
  self.position  = Vec( positionX, positionY )
  self.direction = Vec( 0, 0 )

  self.fsm         = nil
  self.map         = nil
  self.collider    = nil
  self.boundingbox = nil

  self:configure()

  self.target = nil

  self.nextCheck = 0.05

  --//TODO add states and animations
end

function Spider:setTarget( targetActor )
  self.target = targetActor
end

function Spider:update( dt, game )

  --//TODO movement in state
  self:updateAI( dt, game )

  self.collider:update( dt )

  self.fov:update( dt ) --//TODO send walking angle
end

function Spider:updateAI( dt, game )
  if( self.target ~= nil ) then
    local dist = self.position:distSqTo( self.target:getPosition() )

    self.pursuing = dist < 75000 -- 75000 is good enough?
  end

  self.nextCheck = self.nextCheck - dt

  if ( self.nextCheck <= 0 ) then
    local pos = self.target:getPosition()

    local nm = self.navagent:getNavMesh()

    if ( nm:isInside( pos.x, pos.y ) ) then
      self.navagent:findPathTo( self.target:getPosition() )
    end

    self.nextCheck = 0.5
  end

  self:walk( dt, game )

end

function Spider:draw()
  --//TODO animations
  --self.fsm:getCurrent():getAnimation():draw(self:getPositionXY())

  local x, y = self:getPositionXY()
  love.graphics.draw(i__spid, x, y, 0, 0.75, 0.75, 64, 64)

  local x, y = self:getPositionXY()
  love.graphics.circle( "line", x, y, 20, 10 )
  love.graphics.circle( "line", x, y, 2 )

  self.collider:draw()
  self.navagent:draw()
  self.boundingbox:draw()
  self.fov:draw()
end

function Spider:walk( dt, game )
  local nextPos = self.navagent:nextStep()

  self.navagent:update( dt, nextPos, game:getCollisionManager() )

  self.direction = nextPos - self.position:getNormalized()

  self.direction:normalize()

  --if (self.name == "Spider2") then
    --print(tostring(nextPos) .. " " .. tostring(self.direction))
  --end
end

function Spider:changePosition( movementVector )
  self.position = self.position + movementVector

  self.collider:changePosition( movementVector.x, movementVector.y )
  self.boundingbox:setPosition( self.position.x, self.position.y )
  self.navagent:changePosition( movementVector )

  self.fov:changePosition( movementVector )
  self.fov:setViewDirection( movementVector )
end

function Spider:getCollider()
  return self.collider
end

function Spider:configure()
  self.collider = CircleCollider( self.position.x, self.position.y, 36, 0, 4 )
  self.collider:setOwner( self )
  self.collider:setSolid( false )

  --self:setNavAgent( NavAgent(self, self.position.x, self.position.y, 20, 0, 12), 100 )
  self:setNavAgent( NavAgent(self, self.position.x, self.position.y, 30, 0, 12), 100 )

  self.boundingbox = BoundingBox(self.position.x, self.position.y, 88, 88, 0, -44, -44)

  self.fov = FieldOfView(self.position.x, self.position.y, 90, 200)
end
