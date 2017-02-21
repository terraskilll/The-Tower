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

local Grid = require ("../engine/navigation/jumper.grid")
local Pathfinder = require ("../engine/navigation/jumper.pathfinder")

local Vec = require("../engine/math/vector")

class "NavAgent"

function NavAgent:NavAgent( agentOwner, posX, posY, agentRadius, offX, offY )
  self.owner     = agentOwner
  self.position  = Vec( posX, posY )
  self.direction = Vec( 0, 0 )
  self.radius    = agentRadius
  self.offsetX   = offX or 0
  self.offsetY   = offY or 0
  self.speed     = 100

  self.navmesh = nil
  self.navmap  = nil
  self.area    = nil

  self.walkPath  = false
  self.path      = {}
  self.nextpoint = Vec( posX, posY )

end

function NavAgent:setNavMesh( newNavMesh )
  self.navmesh = newNavMesh
end

function NavAgent:getNavMesh()
  return self.navmesh
end

function NavAgent:setNavMap( newNavMap )
  self.navmap = newNavMap
end

function NavAgent:setArea( newArea )
  self.area = newArea
end

function NavAgent:setSpeed( newSpeed )
  self.speed = newSpeed
end

function NavAgent:getRadius()
  return self.radius
end

function NavAgent:setPath( newPath )
  self.path     = newPath
  self.walkPath = #self.path > 0
end

function NavAgent:update( dt, axisVector, collisionManager )
  axisVector:normalize()

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

      self.owner:setFloor( self.navmesh:getOwner() )

  end

  local boundedMov = self.navmesh:getInsidePosition( offsettedPosition, movement )

  --//TODO allow movement if it is diagonal and collision is on one direction (x or y)
  local collisionCheckedMov = self.navmesh:getCollisionCheckedPosition( offsettedPosition, boundedMov, self.owner:getCollider(), collisionManager )

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

function NavAgent:findPathTo( targetPosition )
  self.path = {}

  local agentRow, agentCol    = self.navmap:getAgentCurrentCell( self.position.x + self.offsetX, self.position.y + self.offsetY, self.radius )
  local targetRow, targetCol  = self.navmap:getAgentCurrentCell( targetPosition.x, targetPosition.y, self.radius )

  local grid = Grid( self.navmap:getGrid() )
  local pathfinder = Pathfinder( grid, 'JPS', 0 )

  local p = pathfinder:getPath( agentCol, agentRow, targetCol, targetRow )

  if ( p ) then

    for node, count in p:nodes() do

      table.insert( self.path, { row = node.y, col = node.x } )

    end

    table.remove( self.path, 1 )

    self.nextpoint = self:nextPointInPath()

    self.walkPath = true

  end

end

function NavAgent:nextStep()
  if ( self.nextpoint ) then

    local dist = self.position:distSqTo( self.nextpoint )

    if ( dist < 1 ) then

      self.nextpoint = self:nextPointInPath()

    end

  end

  self.direction = self.nextpoint - self.position

  self.direction:normalize()

  return self.direction
end

function NavAgent:nextPointInPath()
  local next = Vec( self.position.x, self.position.y )

  if ( #self.path > 0 ) then
    local pt = table.remove( self.path, 1 )

    local bd = self.navmesh:getBounds()

    local xm = bd[1] + ( pt.col - 1 ) * self.radius
    local ym = bd[2] + ( pt.row - 1 ) * self.radius

    next:set( xm + self.radius, ym + self.radius )
  end

  return next
end

function NavAgent:draw()
  if ( glob.devMode.drawNavMesh ) then
    love.graphics.setColor(255, 255, 0)

    love.graphics.circle( "line",
      self.position.x + self.offsetX,
      self.position.y + self.offsetY,
      self.radius)

    self:drawPath()

    love.graphics.setColor(glob.defaultColor)
  end
end

function NavAgent:drawPath()

  if (not glob.devMode.drawNavMesh) then
    return
  end

  if ( #self.path == 0) then
    return
  end

  local bd = self.navmesh:getBounds()

  local p = self.path[1]

  local x = bd[1] + ( p.col - 1 ) * self.radius
  local y = bd[2] + ( p.row - 1 ) * self.radius

  love.graphics.line(self.position.x, self.position.y, x, y)

  for i = 1, #self.path - 1 do

    local p1 = self.path[i]
    local p2 = self.path[i+1]

    local x1 = bd[1] + ( p1.col - 1 ) * self.radius
    local y1 = bd[2] + ( p1.row - 1 ) * self.radius

    local x2 = bd[1] + ( p2.col - 1 ) * self.radius
    local y2 = bd[2] + ( p2.row - 1 ) * self.radius

    love.graphics.line(x1, y1, x2, y2)
  end

end
