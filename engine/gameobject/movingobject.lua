
--[[
a walkable part in a area
]]

require("..engine.lclass")

require("..engine.collision/boxcollider")

local Vec = require("..engine.math/vector")

local absfun = math.abs

class "MovingObject" ("SimpleObject")

function MovingObject:MovingObject( objectName, instName, positionX, positionY, platformImage, platformQuad, platformScale )
  self.name         = objectName
  self.instancename = instName

  self.position = Vec(positionX, positionY)
  self.image    = platformImage
  self.quad     = platformQuad or nil
  self.scale    = platformScale or 1

  self.animation = nil

  self.collider    = nil
  self.boundingbox = nil

  self.points   = {}
  self.speed    = 1
  self.circular = false

  self.incMove = 1

  self.objectsOver = {}

  self.currentTargetIndex = 2
  self.targetPoint  = nil

  self.initialPoint = nil
  self.finalPoint   = nil

  self.navMesh  = nil

  self.initialDelay = 0
  self.middleDelay  = 0
  self.finalDelay   = 0

  self.stopDelay = 0
end

function MovingObject:getKind()
  return "MovingObject"
end

function MovingObject:setDelays( initial, middle, final )
  self.initialDelay = initial
  self.middleDelay  = middle
  self.finalDelay   = final
end

function MovingObject:addPoint( pointToAdd )
  table.insert( self.points, pointToAdd )

  if ( #self.points == 1) then
    self.initialPoint = pointToAdd
  end

  self.finalPoint = pointToAdd
end

function MovingObject:start()
  self.targetPoint = self.points[self.currentTargetIndex]

  if ( self.circular == true ) then
    self.stopDelay = self.middleDelay
  else
    self.stopDelay = self.initialDelay
  end
end

function MovingObject:setSpeed( newSpeed )
  self.speed = newSpeed
end

function MovingObject:setCircular( isCircular )
  self.circular = isCircular
end

function MovingObject:isCircular()
  return self.circular
end

function MovingObject:setNavMesh( newNavMesh )
  self.navmesh = newNavMesh
  newNavMesh:setOwner( self )
end

function MovingObject:getNavMesh()
  return self.navmesh
end

function MovingObject:isWalkable()
  return self.navmesh ~= nil
end

function MovingObject:update( dt )
  local movement = Vec( 0, 0 )

  if ( self.stopDelay > 0 ) then
    self.stopDelay = self.stopDelay - dt
  else
    movement = self.targetPoint - self.position

    movement:normalize()

    movement = ( movement * dt * self.speed )
  end

  self.position = self.position + movement

  self:updateObjectOver( movement )

  self:checkNextPoint()

  if ( self.navmesh ) then
    self.navmesh:changePosition( movement )
  end

end

function MovingObject:checkNextPoint()
  local dist = self.position:distSqTo( self.targetPoint )

  local oldIndex = self.currentTargetIndex

  if ( dist < 1 ) then
    self.currentTargetIndex = self.currentTargetIndex + self.incMove

    if ( self.currentTargetIndex > #self.points ) then

      if ( self.circular == true ) then
        self.currentTargetIndex = 1
      else
        self.incMove = -1
        self.currentTargetIndex = self.currentTargetIndex + self.incMove
      end

    end

    if ( self.currentTargetIndex == 0 ) then

      if ( self.circular == true ) then
        self.currentTargetIndex = #self.points
      else
        self.incMove = 1
        self.currentTargetIndex = self.currentTargetIndex + self.incMove
      end

    end

    if ( oldIndex ~= self.currentTargetIndex ) then

      self.stopDelay = self.middleDelay

      if ( self.circular == false ) then

        if ( oldIndex == 1 ) then
          self.stopDelay = self.initialDelay
        end

        if ( oldIndex == #self.points ) then
          self.stopDelay = self.finalDelay
        end

      end

    end

    self.targetPoint = self.points[self.currentTargetIndex]
  end
end

function MovingObject:addObjectOver( objectName, object )
  self.objectsOver[objectName] = object
end

function MovingObject:removeObjectOver( objectName )
  self.objectsOver[objectName] = nil
end

function MovingObject:updateObjectOver( movementVector )

  for _,obj in pairs( self.objectsOver ) do
    obj:changePosition( movementVector )
  end

end

function MovingObject:clone( newname )

  local qd = nil

  if ( self.quad ) then
    local qx, qy, lx, ly = self.quad:getViewport()
    local qw, qh = self.quad:getTextureDimensions()

    qd = love.graphics.newQuad( qx, qy, lx, ly, qw, qh )
  end

  local cloned = MovingObject( newname, self.position.x, self.position.y, self.image, qd,  self.scale )

  if ( self.navmesh ) then
    local navms = self.navmesh:clone()
    cloned:setNavMesh( navms )
  end

  for i = 1, #self.points do
    cloned:addPoint( Vec( self.points[i].x, self.points[i].y ) )
  end

  cloned:setCircular( self:isCircular() )
  cloned:setDelays( self.initialDelay, self.middleDelay, self.finalDelay )

  return cloned
end
