

require("..engine.lclass")
require("..engine.globalconf")
require("..engine.colors")

class "NavBox"

function NavBox:NavBox( x, y, w, h, offX, offY, s )
  self.positionX = x
  self.positionY = y
  self.width     = w
  self.height    = h
  self.offsetX   = offX
  self.offsetY   = offY
  self.color     = { 175, 100, 50, 75 }
  self.scale     = s or 1
end

function NavBox:draw()
  if ( glob.devMode.drawNavMesh ) then

    love.graphics.setColor( self.color[1], self.color[2], self.color[3], self.color[4] )

    love.graphics.rectangle( "fill",
        self.positionX + self.offsetX, self.positionY + self.offsetY,
        self.width * self.scale, self.height * self.scale )

    love.graphics.setColor(colors.WHITE )

  end
end

function NavBox:changePosition( movementVector )
  self.positionX = self.positionX + movementVector.x
  self.positionY = self.positionY + movementVector.y
end

function NavBox:setPosition( newX, newY )
  self.positionX = newX or self.positionX
  self.positionY = newY or self.positionY
end

function NavBox:setScale( newScale )
  self.scale = newScale or 1
end

function NavBox:getBounds()
  return
      self.positionX + self.offsetX,
      self.positionY + self.offsetY,
      self.width * self.scale,
      self.height * self.scale
end

function NavBox:clone()

  local theclone = NavBox( self.positionX, self.positionY, self.width, self.height,
                           self.offsetX, self.offsetY, self.scale )

  return theclone
end
