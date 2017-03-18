--[[

a messagebox class, to show in-game messages (as a "caption box")

]]

require("..engine.lclass")
require("..engine.utl.funcs")

class "MessageBox"

function MessageBox:MessageBox()
  local w, h = love.graphics.getDimensions()

  self.width  = w - 40
  self.height = h - 40

  self.message = nil

  self.showing = false

  self.duration = 0
end

function MessageBox:show( messageStr )
  self.message = messageStr

  self.duration = 4

  self.showing = true
end

function MessageBox:update( dt )

  if ( self.duration >= 0 ) then
    self.duration = self.duration - dt
  else
    self.showing = false
  end

end

function MessageBox:draw()
  local alpha = 50

  if ( self.duration < 0.5 ) then
    alpha = lerp( 0, 50, self.duration )
  elseif ( self.duration > 3.5 ) then
    alpha = lerp( 0, 50, 4 - self.duration )
  end

  love.graphics.setColor( 255, 255, 255, alpha )

  if ( self.showing ) then
    love.graphics.rectangle( "fill", 20, self.height - 50, self.width, self.height - 40 )
    love.graphics.setColor( 200, 200, 100, 50 )
  end

  love.graphics.setColor( colors.WHITE )
end
