

require("../engine/lclass")
require("../engine/globalconf")

class "BoundingBox"

function BoundingBox:BoundingBox( x, y, w, h, z, offX, offY, s, boxColor )
  self.positionX = x
  self.positionY = y
  self.width     = w
  self.height    = h
  self.zIndex    = z
  self.offsetX   = offX
  self.offsetY   = offY
  self.color     = boxColor or { 255, 255, 255, 75 }
  self.scale     = s or 1
end

function BoundingBox:draw()
  if ( glob.devMode.drawBoundingBox ) then

    love.graphics.setColor( self.color[1], self.color[2], self.color[3], self.color[4] )
    love.graphics.rectangle( "fill",
        self.positionX + self.offsetX, self.positionY + self.offsetY,
        self.width * self.scale, self.height * self.scale )
    love.graphics.setColor(glob.defaultColor )

  end
end

function BoundingBox:changePosition( movementVector )
  self.positionX = self.positionX + movementVector.x
  self.positionY = self.positiony + movementVector.y
end

function BoundingBox:setPosition( newX, newY )
  self.positionX = newX or self.positionX
  self.positionY = newY or self.positionY
end

function BoundingBox:setScale( newScale )
  self.scale = newScale or 1
end

function BoundingBox:getBounds()
  return
      self.positionX + self.offsetX,
      self.positionY + self.offsetY,
      self.width * self.scale,
      self.height * self.scale
end

function BoundingBox:getZ()
  return self.zIndex
end

function BoundingBox:getLowY()
  return self.positionY + self.offsetY + ( self.height * self.scale )
end

function BoundingBox:clone()
  local colr = { self.color[1], self.color[2], self.color[3], self.color[4] }

  local cloned = BoundingBox( self.positionX, self.positionY, self.width, self.height,
                              self.zIndex, self.offsetX, self.offsetY, self.scale, colr )

  return cloned
end
