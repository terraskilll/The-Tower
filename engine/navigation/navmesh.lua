-- http://gamedev.stackexchange.com/questions/7735/how-do-i-test-if-a-circle-and-concave-polygon-intersect
-- https://love2d.org/wiki/General_math
-- http://grepcode.com/file/repository.grepcode.com/java/root/jdk/openjdk/7-b147/java/awt/geom/Line2D.java#Line2D.linesIntersect(double,double,double,double,double,double,double,double)

--[[

a navmesh is the walkable part of an floor

]]

require("../engine/lclass")
require("../engine/globalconf")
require("../engine/utl/funcs")

local Vec = require("../engine/math/vector")

local linesIntersect = linesIntersectFunc

class "NavMesh"

function NavMesh:NavMesh()
  self.owner = nil

  self.bounds     = {}

  self.coords     = {} --pairs of points of the mesh (polygon)
  self.lines      = {} -- precomputed for speed
  self.lineCount  = 0

  self.mobile = false

  self.obstacleColliders      = {}
  self.obstacleCollidersCount = 0

  --//TODO obstacles and simple colliders are a bit redundant, no?
  self.obstacles     = {}
  self.obstacleCount = 0
end

function NavMesh:draw()
  if ( glob.devMode.drawNavMesh ) then
    love.graphics.setColor(0, 255, 255)

    love.graphics.polygon( "line", self.coords )

    love.graphics.setColor(0, 200, 255, 100 )

    love.graphics.line( self.bounds[1], self.bounds[2], self.bounds[1], self.bounds[4] )
    love.graphics.line( self.bounds[1], self.bounds[2], self.bounds[3], self.bounds[2] )
    love.graphics.line( self.bounds[3], self.bounds[2], self.bounds[3], self.bounds[4] )
    love.graphics.line( self.bounds[1], self.bounds[4], self.bounds[3], self.bounds[4] )

    love.graphics.setColor( glob.defaultColor )
  end
end

function NavMesh:setOwner( newOwner )
  self.owner = newOwner
end

function NavMesh:getOwner()
  return self.owner
end

function NavMesh:addPoint( pointX, pointY )
  table.insert(self.coords, pointX)
  table.insert(self.coords, pointY)

  if (#self.coords == 2) then

    self.bounds[1] = pointX
    self.bounds[2] = pointY
    self.bounds[3] = pointX
    self.bounds[4] = pointY

  else

    if ( pointX < self.bounds[1] ) then
      self.bounds[1] = pointX
    end

    if ( pointY < self.bounds[2] ) then
      self.bounds[2] = pointY
    end

    if ( pointX > self.bounds[3] ) then
      self.bounds[3] = pointX
    end

    if ( pointY > self.bounds[4] ) then
      self.bounds[4] = pointY
    end

  end

  self:recomputeLines()
end

function NavMesh:recomputeLines()
  --//TODO refactor make a better name and check for a better calling moment

  -- each time a point is created this is called

  -- create a line between the points
  if ( #self.coords >= 4 ) then

    self.lines = {}

    self.lineCount = 0

    for i = 1, #self.coords - 2, 2 do

      local line = {
        self.coords[i],
        self.coords[i + 1],
        self.coords[i + 2],
        self.coords[i + 3]
      }

      table.insert(self.lines, line)

      self.lineCount = self.lineCount + 1

    end

    line = {
      self.coords[#self.coords - 1],
      self.coords[#self.coords],
      self.coords[1],
      self.coords[2]
    }

    table.insert(self.lines, line)

    self.lineCount = #self.lines

  end

end

function NavMesh:changePosition( movementVector )

  for i=1, #self.coords, 2 do
    self.coords[i]   = self.coords[i] + movementVector.x
    self.coords[i+1] = self.coords[i+1] + movementVector.y
  end

  for i=1, #self.lines do
    self.lines[i][1] = self.lines[i][1] + movementVector.x
    self.lines[i][2] = self.lines[i][2] + movementVector.y
    self.lines[i][3] = self.lines[i][3] + movementVector.x
    self.lines[i][4] = self.lines[i][4] + movementVector.y
  end

  self.bounds[1] = self.bounds[1] + movementVector.x
  self.bounds[2] = self.bounds[2] + movementVector.y
  self.bounds[3] = self.bounds[3] + movementVector.x
  self.bounds[4] = self.bounds[4] + movementVector.y

end

function NavMesh:addSimpleCollider( colliderToAdd )
  if ( colliderToAdd == nil ) then
    return
  end

  table.insert( self.obstacleColliders, colliderToAdd )
  self.obstacleCollidersCount = #self.obstacleColliders
end
--[[
function NavMesh:addObstacle( obstacleToAdd, addOffSet )
  -- obstacle must be the rectangle of the objects boundingbox

  --//TODO use this?

  -- create a offset in the rectangle
  if ( addOffSet == true ) then
    obstacleToAdd[1] = obstacleToAdd[1] - 2
    obstacleToAdd[2] = obstacleToAdd[2] - 2
    obstacleToAdd[3] = obstacleToAdd[3] + 2
    obstacleToAdd[4] = obstacleToAdd[4] + 2
  end

  table.insert( self.obstacles, obstacleToAdd )
  self.obstacleCount = self.obstacleCount + 1
end

]]

function NavMesh:getObstacles()
  return self.obstacles
end

function NavMesh:getObstacleColliders()
  return self.obstacleColliders
end

function NavMesh:getBounds()
  return self.bounds
end

function NavMesh:setMobile( isMobile )
  self.mobile = isMobile
end

function NavMesh:isMobile()
  return self.mobile
end

function NavMesh:getCollisionCheckedPosition ( currentPosition, movementVector, objectCollider, collisionManager )

  movementVector = collisionManager:checkCollisionForMovement( currentPosition, movementVector, objectCollider )

  return movementVector
end

function NavMesh:getInsidePosition( currentPosition, movementVector )

  local newX = currentPosition.x + movementVector.x
  local newY = currentPosition.y + movementVector.y

  if self:isInside( newX, newY ) then
    return movementVector
  else

    if ( self:isInside( currentPosition.x, newY ) ) then -- no change in X

      return Vec(0, movementVector.y )

    elseif ( self:isInside( newX, currentPosition.y ) ) then -- no change in Y

      return Vec( movementVector.x, 0 )

    else -- cant go where it wants

      return Vec( 0, 0 )

    end

  end

end

function NavMesh:isInside( centerX, centerY )
  -- far ended horizontal line to the right
  --//TODO check if 1000000000 is enough :D
  local intersections = self:countIntersections( centerX, centerY, 1000000000, centerY )

  return ( intersections % 2 ) == 1
end

function NavMesh:countIntersections(centerX, centerY, endx, endy)
  local total = 0

  -- data from other line

  for i = 1, self.lineCount do
    local lx1, ly1, lx2, ly2 =
      self.lines[i][1], self.lines[i][2], self.lines[i][3], self.lines[i][4]

    if ( linesIntersect (centerX, centerY, endx, endy, lx1, ly1, lx2, ly2) ) then
      total = total + 1
    end

  end

  return total
end
