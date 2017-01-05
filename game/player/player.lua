require("../input")
require("../engine/fsm/fsm")
require("../engine/collision/boxcollider")

require("../game/player/states/iddlestate")
require("../game/player/states/walkingstate")

local Vec = require("../math/vector")

class "Player" ("GameObject")

function Player:Player()
  self.position  = Vec(100,100)
  self.speed     = 70

  self.fsm       = nil
  self.map       = nil
  self.collider  = nil

  self.hasCamera = false
  self.hasTorch  = false

  self:configure()
end

function Player:update(dt)
  self.fsm:getCurrent():onUpdate(dt)

  --//TODO movement in state
  
  local mov = Vec(Input:getAxis())

  mov = mov * dt * self.speed

  self.position = self.position + mov
  
  self.collider:update(dt, self.position.x, self.position.y)
end

function Player:draw()
  --self.fsm:getCurrent():getAnimation():draw(self:getPositionXY())

  local x, y = self:getPositionXY()
  love.graphics.circle( "line", x, y, 20, 10 )
  love.graphics.circle( "line", x, y, 2 )

  self.collider:draw()
end

function Player:joystickPressed(joystick, button, sender)
  --//TODO
end

function Player:getCollider()
  return self.collider
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

  self.collider = BoxCollider(self.position.x, self.position.y, 30, 10, -15, 0)
end

function Player:setMap(newMap)
  self.map = newMap
end