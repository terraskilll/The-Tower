require("..engine.input")
require("..engine.fsm.fsm")
require("..engine.navigation.navagent")
require("..engine.collision.boxcollider")
require("..engine.collision.circlecollider")
require("..engine.render.boundingbox")
require("..engine.navigation.navbox")

require("..game.actors.player.states.iddlestate")
require("..game.actors.player.states.walkingstate")

local Vec = require("..engine.math.vector")

local i__me =  loadImage("res/_me.png") --//TODO temporary

class "Player" ( "Actor" )

function Player:Player( playerName, instName, positionX, positionY )
  self.instancename = instName

  self.name      = playerName
  self.position  = Vec( positionX, positionY )

  self.hasCamera = false
  self.hasTorch  = false

  self.fsm   = nil

  self.map    = nil
  self.area   = nil

  self.boundingbox = nil
  self.collider    = nil

  self:configure()
end

function Player:update( dt, game )
  self.fsm:getCurrent():onUpdate( dt )

  local xyVec = Input:getAxis()

  self.navagent:update( dt, xyVec, game:getCollisionManager() )
end

function Player:draw()
  --//TODO use player animations
  --self.fsm:getCurrent():getAnimation():draw(self:getPositionXY())

  local x, y = self:getPositionXY()
  --love.graphics.circle( "line", x, y, 20, 4 )
  --love.graphics.circle( "line", x, y, 2 )

  love.graphics.draw(i__me, x, y, 0, 0.75, 0.75, 32, 32)

  self.collider:draw()
  self.navagent:draw()
  self.boundingbox:draw()
end

function Player:changePosition( movementVector )
  self.position = self.position + movementVector

  self.collider:changePosition( movementVector.x, movementVector.y )
  self.boundingbox:setPosition( self.position.x, self.position.y )
  self.navagent:changePosition( movementVector )
end

function Player:setPosition( newX, newY )
  self.position = Vec( newX, newY )

  self.collider:setPosition( newX, newY )
  self.boundingbox:setPosition( newX, newY )
  self.navagent:setPosition( newX, newY )
end

function Player:joystickPressed( joystick, button, sender )
  --//TODO
end

function Player:getCollider()
  return self.collider
end

function Player:getKind()
  return "PLAYER"
end

function Player:configure()
  self.fsm = FSM()

  --local walkingstate = WalkingState()

  --self.fsm:pushState(walkingstate)
  --self.fsm:setCurrentState(walkingstate)

  local iddlestate = IddleState()

  self.fsm:pushState( iddlestate )
  self.fsm:setCurrentState( iddlestate )
  self.fsm:start()

  self.fsm:start()

  -------------------------------------------
  -- Collider, NavAgent, BoundingBox
  -------------------------------------------

  self:setNavAgent( NavAgent(self, self.position.x, self.position.y, 10, 0, 12), 150 )

  self.collider = CircleCollider(self.position.x, self.position.y, 12, 0, 10)
  --self.collider = BoxCollider(self.position.x, self.position.y, 20, 22, 23, 42)
  self.collider:setOwner( self )

  self.boundingbox = BoundingBox(self.position.x, self.position.y, 32, 16, 0, -16, 10)
end

function Player:onCollisionEnter( otherCollider )
  --print( "Player Collided with " .. otherCollider:getOwner():getInstanceName() )
  --print( otherCollider:getOwner():getInstanceName() )
end
