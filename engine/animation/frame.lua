require("..engine.lclass")

class "Frame"

function Frame:Frame()
  self.duration  = 1
  self.offsetX   = 0
  self.offsetY   = 0
  self.quad      = nil
end

function Frame:setQuad( quadToSet )
  self.quad = quadToSet
end

function Frame:getQuad()
  return self.quad
end

function Frame:setDuration( durationToSet )
  self.duration = durationToSet
end

function Frame:setOffset( newOffSetX, newOffSetY )
  self.offsetX = newOffSetX or 0
  self.offsetY = newOffSetY or 0
end

function Frame:getDuration()
  return self.duration
end

function Frame:draw( image, positionX, positionY )
  love.graphics.draw( image, self.quad, positionX + self.offsetX, positionY + self.offsetY )
end

function Frame:drawRect( positionX, positionY )

  local qx, qy, lx, ly = self.quad:getViewport()

  love.graphics.rectangle( "line", qx, qy, lx, ly )

end

function Frame:getDataAsTable()

  local qx, qy, lx, ly = self.quad:getViewport()
  local qw, qh = self.quad:getTextureDimensions()

  local data = {
    duration = self.duration,
    offx     = self.offsetX,
    offy     = self.offsetY,
    quadx    = qx,
    quady    = qy,
    quadw    = lx,
    quadh    = ly,
    imgw     = qw,
    imgh     = qh
  }

  return data

end

function Frame:clone()
  local theclone = Frame()

  local qx, qy, lx, ly = self.quad:getViewport()
  local qw, qh = self.quad:getTextureDimensions()

  local quad = love.graphics.newQuad( qx, qy, lx, ly, qw, qh )

  theclone:setQuad( quad )
  theclone:setDuration( self.duration )
  theclone:setOffset( self.offsetX, self.offsetY )

  return theclone

end
