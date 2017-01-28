--[[

a navagent is a object that can walk inside a navmesh

to change the owner position, the owner must have a changePosition
function which receives the movement vector computed by this agent
based on the current navmesh. the navagent does not change its own
position, merely checks if the direction being teste is reachable
and passes it to the owner, who can or cannot go there

]]

require("../engine/lclass")
require("../engine/input")
require("../engine/fsm/fsm")
require("../engine/globalconf")

local Vec = require("../engine/math/vector")

class "NavAgent"

function NavAgent:NavAgent( agentOwner, posX, posY, drawRadius, offX, offY )
  self.owner    = agentOwner
  self.position = Vec(posX, posY)
  self.radius   = drawRadius
  self.offsetX  = offX or 0
  self.offsetY  = offY or 0
  self.speed    = 100

  self.navmesh = nil
  self.area = nil
end

function NavAgent:setNavMesh( newNavMesh )
  self.navmesh = newNavMesh
end

function NavAgent:setArea( newArea )
  self.area = newArea
end

function NavAgent:setSpeed( newSpeed )
  self.speed = newSpeed
end

function NavAgent:update( dt, axisVector )
  local offsettedPosition = Vec( self.position.x + self.offsetX, self.position.y + self.offsetY )

  local movement = axisVector * dt * self.speed

  -- check if agent got into another navmesh
  local changedNavMesh = self.area:checkChangedNavMesh( offsettedPosition, movement )

  if ( changedNavMesh ~= nil ) and ( changedNavMesh ~= self.navmesh ) then

      if ( changedNavMesh:isMobile() ) then
        changedNavMesh:getOwner():addObjectOver( self.owner:getName(), self.owner )
      end

      if ( self.navmesh:isMobile() ) then
        self.navmesh:getOwner():removeObjectOver( self.owner:getName() )
      end

      self.navmesh = changedNavMesh

  end

  local boundedMov = self.navmesh:getInsidePosition( offsettedPosition, movement )

  --//TODO allow movement if it is diagonal and collision is on one direction (x or y)
  local collisionCheckedMov = self.navmesh:getCollisionCheckedPosition( offsettedPosition, boundedMov, self.owner:getCollider() )

  --self.position = self.position + collisionCheckedMov

  --self.position = self.position + boundedMov

  self.owner:changePosition( collisionCheckedMov )
end

function NavAgent:changePosition( movementVector )
  self.position = self.position + movementVector
end

function NavAgent:setPosition( newX, newY )
  self.position:set( newX, newY )
end

function NavAgent:draw()
  if ( glob.devMode.drawNavMesh ) then
    love.graphics.setColor(255, 255, 0)

    love.graphics.circle( "line",
      self.position.x + self.offsetX,
      self.position.y + self.offsetY,
      self.radius)

    love.graphics.setColor(glob.defaultColor)
  end
end
