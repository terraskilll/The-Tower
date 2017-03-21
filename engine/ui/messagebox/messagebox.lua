--[[

a messagebox class, to show in-game messages (as a "caption box")

message box text alignment is resolution dependent, so it needs to be recreated
or reset (TODO) if resolution changes

]]

require("..engine.lclass")
require("..engine.colors")
require("..engine.utl.funcs")

class "MessageBox"

function MessageBox:MessageBox()
  local w, h = love.graphics.getDimensions()

  self.screenw = w

  self.bottom = h - 80

  self.width  = w - 40
  self.height = h - 40

  self.message = nil

  self.showing = false

  self.duration = 0
end

function MessageBox:show( messageStr, duration )
  duration = duration or 4

  self.message = messageStr

  self.duration = duration

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

  if not ( self.showing ) then
    return
  end

  --- RECTANGLES ---

  love.graphics.setColor( 0, 0, 0, 200 )
  love.graphics.rectangle( "line", 22, self.bottom - 3, self.width, 35, 4, 4 )

  love.graphics.setColor( 100, 100, 255, 180 )
  love.graphics.rectangle( "fill", 20, self.bottom - 5, self.width, 35, 4, 4 )

  love.graphics.setColor( 220, 255, 245, 200 )
  love.graphics.rectangle( "line", 20, self.bottom - 5, self.width, 35, 4, 4 )

  --- TEXT ---

  love.graphics.setNewFont( 18 )

  love.graphics.setColor( 0, 0, 0, 200 )
  love.graphics.printf( self.message, 2, self.bottom + 2, self.screenw, "center" )

  love.graphics.setColor( 255, 255, 235, 255 )
  love.graphics.printf( self.message, 0, self.bottom, self.screenw, "center" )

  love.graphics.setNewFont( glob.defaultFontSize )
  love.graphics.setColor( colors.WHITE )
end
