
--[[
a walkable part in a area
]]

require("../engine/lclass")

require("../engine/collision/boxcollider")

local Vec = require("../engine/math/vector")

local absfun = math.abs

class "MovingObject" ("SimpleObject")

function MovingObject:MovingObject(objectName, positionX, positionY, platformImage, platformQuad, platformScale)
  self.name     = objectName

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

  self.navMesh  = nil --//TODO

  self.initialDelay = 1 --//TODO
  self.middleDelay  = 0
  self.finalDelay   = 1

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
end

function MovingObject:setSpeed( newSpeed )
  self.speed = newSpeed
end

function MovingObject:setCircular( isCircular )
  self.circular = isCircular
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
  local movement = self.targetPoint - self.position

  movement:normalize()

  movement = (movement * dt * self.speed)

  self:updateObjectOver(movement)

  self.position = self.position + movement

  self:checkNextPoint()

  if ( self.navmesh ~= nil) then
    self.navmesh:changePosition(movement)
  end

end

function MovingObject:checkNextPoint()
  local dist = self.position:distSqTo(self.targetPoint)

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

    self.targetPoint = self.points[self.currentTargetIndex]
  end
end

function MovingObject:addObjectOver(objectName, object)
  self.objectsOver[objectName] = object
end

function MovingObject:removeObjectOver(objectName)
  self.objectsOver[objectName] = nil
end

function MovingObject:updateObjectOver(movementVector)
  for _,obj in pairs(self.objectsOver) do
    obj:changePosition(movementVector)
  end
end
