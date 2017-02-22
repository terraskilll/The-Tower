
--[[-----------------------------------------------------------------------------

simple textbox class for ui

------------------------------------------------------------------------------]]--

require("../engine/globalconf")
require("../engine/lclass")
require("../engine/ui/anchor")

local Vec = require("../engine/math/vector")

--local selectorShader = love.graphics.newShader("engine/shaders/ui.glsl")

class "TextBox"

function TextBox:TextBox(positionX, positionY, selectorScale)
  self.position   = Vec(positionX, positionY)
  self.scale      = selectorScale or 1
  self.text       = ""

  self.altDelay   = 0.16
  self.selected   = false
  self.enabled    = true
  self.anchor     = nil
end

function TextBox:onEnter()
  love.keyboard.setTextInput( true )
end

function TextBox:onExit()
  love.keyboard.setTextInput( false )
end

function TextBox:getText()
  return self.text
end

function TextBox:checkMouseOver( x, y )
  return false
end
