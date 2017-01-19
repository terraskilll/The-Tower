
--[[
a walkable part in a area
]]

require("../engine/lclass")

require("../engine/collision/boxcollider")

local Vec = require("../engine/math/vector")

local absfun = math.abs

class "MovingPlatform"

function MovingPlatform:MovingPlatform(positionX, positionY, platformImage, platformImage)
  self.position = Vec(positionX, positionY)
  self.image    = platformImage
  self.quad     = platformImage

  self.points   = {}
  self.speed    = 0
  self.circular = false

  self.navMesh  = nil -- //TODO

  self.currentPoint = nil
  self.targetPoint  = nil
end

function MovingPlatform:addPoint( pointToAdd )
  table.insert( self.points, pointToAdd )

  if ( #self.points == 1) then
    self.currentPoint = pointToAdd
  end
end

function MovingPlatform:setSpeed( newSpeed )
  self.speed = newSpeed
end

function MovingPlatform:setCircular( isCircular )
  self.circular = isCircular
end

function MovingPlatform:update(dt)
  --local motion =
end

function MovingPlatform:draw()
  if ( self.quad ) then
    love.graphics.draw(self.image, self.quad, self.position.x, self.position.y)
  else
    love.graphics.draw(self.image, self.position.x, self.position.y)
  end
end
