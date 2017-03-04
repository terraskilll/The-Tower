--[[
a walkable part in a area
]]

require("../engine/lclass")

require("../engine/collision/boxcollider")

local Vec = require("../engine/math/vector")

class "Ground" ("SimpleObject")

function Ground:Ground( groundName, positionX, positionY, groundImage, groundQuad, objectScale )
  self.name     = groundName
  self.position = Vec( positionX, positionY )
  self.image    = groundImage
  self.quad     = groundQuad or nil
  self.scale    = objectScale or 1

  self.width  = groundImage:getWidth()
  self.height = groundImage:getHeight()

  self.stair = false

  self.animation   = nil

  self.collider    = nil
  self.boundingbox = nil

  self.onCollisionEnter = nil
end

function Ground:setAsStair( isStair )
  self.stair = isStair
end

function Ground:isStair()
  return self.stair
end

function Ground:clone( newname )

  local qd = nil

  if ( self.quad ) then
    local qx, qy, lx, ly = self.quad:getViewport()
    local qw, qh = self.quad:getTextureDimensions()

    qd = love.graphics.newQuad( qx, qy, lx, ly, qw, qh )
  end

  local cloned = Ground(newname, self.position.x, self.position.y, self.image, qd, self.scale)

  cloned:setAsStair( self.stair )

  return cloned

end
