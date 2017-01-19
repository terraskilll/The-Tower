require("../engine/input")
require("../engine/fsm/fsm")
require("../engine/navigation/navagent")
require("../engine/collision/boxcollider")
require("../engine/collision/circlecollider")
require("../engine/render/boundingbox")

require("../game/player/states/iddlestate")
require("../game/player/states/walkingstate")

local Vec = require("../engine/math/vector")

class "Player" ("GameObject")

function Player:Player()
  self.position  = Vec( 0, 0 )
  self.speed     = 150

  self.hasCamera = false
  self.hasTorch  = false

  self.fsm   = nil

  self.map    = nil
  self.area   = nil
  self.floor  = nil
  self.floor  = nil

  self.navagent    = nil
  self.boundingbox = nil
  self.collider    = nil

  self:configure()
end

function Player:update(dt)
  self.fsm:getCurrent():onUpdate(dt)

  --//TODO movement in state ?

  local xv, yv = Input:getAxis()

  self.navagent:update(dt, Vec(xv, yv))
end

function Player:draw()
  --//TODO
  --self.fsm:getCurrent():getAnimation():draw(self:getPositionXY())

  local x, y = self:getPositionXY()
  love.graphics.circle( "line", x, y, 20, 4 )
  love.graphics.circle( "line", x, y, 2 )

  love.graphics.draw(i__me, x, y, 0, 0.75, 0.75, 32, 32)

  self.collider:draw()
  self.navagent:draw()
  self.boundingbox:draw()
end

function Player:changeSpeed(newSpeed)
  self.speed = newSpeed
  self.navagent:setSpeed(self.speed)
end

function Player:changePosition( movementVector )
  self.position = self.position + movementVector

  self.collider:changePosition(movementVector.x, movementVector.y)
  self.boundingbox:setPosition(self.position.x, self.position.y)
  self.navagent:changePosition( movementVector )
end

function Player:setPosition( newX, newY )
  self.position = Vec( newX, newY )

  self.collider:setPosition( newX, newY )
  self.boundingbox:setPosition( newX, newY )
  self.navagent:setPosition( newX, newY )
end

function Player:joystickPressed(joystick, button, sender)
  --//TODO
end

function Player:getCollider()
  return self.collider
end

function Player:getNavAgent()
  return self.navagent
end

function Player:getBoundingBox()
  return self.boundingbox
end

function Player:setMap( newMap, newArea, newFloor, spawnPoint )
  self.map   = newMap
  self.area  = newArea
  self.floor = newFloor

  self.navagent:setNavMesh(self.floor:getNavMesh())

  if ( spawnPoint ~= nil ) then
    local pos = spawnPoint:getPosition()

    self:setPosition( pos.x, pos.y )
  end

end

function Player:getPosition()
  return self.position
end

function Player:configure()
  self.fsm = FSM()

  --local walkingstate = WalkingState()

  --self.fsm:pushState(walkingstate)
  --self.fsm:setCurrentState(walkingstate)

  local iddlestate = IddleState()

  self.fsm:pushState(iddlestate)
  self.fsm:setCurrentState(iddlestate)
  self.fsm:start()

  self.fsm:start()

  -------------------------------------------
  -- Collider
  -------------------------------------------

  self.collider = CircleCollider(self.position.x, self.position.y, 12, 0, 10)

  self.navagent = NavAgent(self, self.position.x, self.position.y, 10, 0, 12)

  self.navagent:setSpeed(self.speed)

  self.boundingbox = BoundingBox(self.position.x, self.position.y, 32, 16, 0, -16, 10)
end
