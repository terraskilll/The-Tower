require("..engine.lclass")

require("..engine.globalconf")
require("..engine.colors")
require("..engine.ui.anchor")
require("..engine.ui.button.button")

local Vec = require("..engine.math.vector")

local done = false
local option = 0

class "ConfirmDialog"

function ConfirmDialog:ConfirmDialog( textLine1, textLine2, scale )
  self.text1 = textLine1
  self.text2 = textLine2

  local sw, sh = love.graphics.getDimensions()

  self.positionx = sw * 0.25
  self.positiony = sh * 0.4

  self.width  = ( sw * 0.5 )
  self.height = ( sh * 0.25 )

  self.scale = scale

  self.uigroup = UIGroup()
  self.uigroup:setTraversalMode( 2 )

  self.buttonYes = Button( self.positionx + 25, sh * 0.5 + 60, "SIM", ib_red1, scale )
  self.buttonYes.onButtonClick = self.confirm
  self.buttonNo  = Button( self.positionx + self.width - ( 760 * scale ), sh * 0.5 + 60, "NÃO", ib_yellow1, scale )
  self.buttonNo.onButtonClick = self.cancel

  self.uigroup:addButton( self.buttonYes )
  self.uigroup:addButton( self.buttonNo )
  self.uigroup:selectFirst()

  option = 0

  done = false
end

function ConfirmDialog:isDone()
  return done
end

function ConfirmDialog:getOption()
  return option
end

function ConfirmDialog:update( dt )
  self.uigroup:update( dt )
end

function ConfirmDialog:draw()
  local sw, sh = love.graphics.getDimensions()

  self:drawRectangleOverScreen( sw, sh )

  love.graphics.setColor( 255, 200, 255, 50 )

  love.graphics.rectangle( "fill", self.positionx, self.positiony, self.width, self.height, 4, 4 )

  love.graphics.setNewFont( 80 * self.scale )

  love.graphics.setColor( colors.WHITE )

  love.graphics.print( self.text1, self.positionx + 25, self.positiony + 20 )
  love.graphics.print( self.text2, self.positionx + 25, self.positiony + 60 )

  self.uigroup:draw()

  love.graphics.setColor( colors.WHITE )
  love.graphics.setNewFont( glob.defaultFontSize )
end

function ConfirmDialog:drawRectangleOverScreen( sw, sh )
  love.graphics.setColor( 10, 10, 10, 200 )
  love.graphics.rectangle( "fill", 0, 0, sw, sh )
  love.graphics.setNewFont( glob.defaultFontSize )
end

function ConfirmDialog:keyPressed( key, sender )
  self.uigroup:keyPressed( key, self )
end

function ConfirmDialog:mousePressed( x, y, button, scaleX, scaleY, sender )
  self.uigroup:mousePressed( x, y, button, scaleX, scaleY, self )
end

function ConfirmDialog:joystickPressed( joystick, button, sender )
  self.uigroup:joystickPressed( joystick, button, self )
end

function ConfirmDialog:mouseMoved( x, y, dx, dy, scaleX, scaleY, sender )
  self.uigroup:mouseMoved( x, y, dx, dy, scaleX, scaleY, self )
end

function ConfirmDialog:confirm()
  option = 1

  done = true
end

function ConfirmDialog:cancel()
  option = 2

  done = true
end
