--[[-----------------------------------------------------------------------------
simple button class for menus. 

must be used with a buttongroup for menu management (focus and click)

------------------------------------------------------------------------------]]--

require("globalconf")
require("lclass")
require("../engine/ui/anchor")

local Vec = require("../math/vector")

local buttonShader = love.graphics.newShader("engine/shaders/button.glsl")

class "Button"

function Button:Button(positionX, positionY, buttonText, buttonImage, buttonScale)
  self.position = Vec(positionX, positionY)
  self.selected = false
  self.enabled  = true

  self.text   = buttonText
  self.image  = buttonImage
  self.scale  = buttonScale or 1
  self.anchor = nil

  self.onButtonClick = nil
end

function Button:setImages(newImageSelected)
  self.image = newImageSelected
end

function Button:draw()
  buttonShader:send("uIsSelected", self.selected)
  buttonShader:send("uIsEnabled", self.enabled)

  x, y = self:getPosition()

  love.graphics.setShader(buttonShader)
  love.graphics.draw(self.image, x, y, 0, self.scale, self.scale)
  love.graphics.setShader()

  self:drawText()
end

function Button:drawText()
  love.graphics.setNewFont(80 * self.scale) 

  --// shader does not like transparency in text =(
  local a = 255

  if (self.enabled == false) then
    a = 64
  elseif ( self.selected == false) then
    a = 153
  end

  love.graphics.setColor( 255, 255, 255, a)
  love.graphics.print(self.text, x + 96 * self.scale, y + 5 * self.scale)

  love.graphics.setColor( 255, 255, 255, 255)
  love.graphics.setNewFont(glob.defaultFontSize)
end

function Button:setSelected(isSelected)
  self.selected = isSelected or false
end

function Button:setEnabled(isEnabled)
  self.enabled = isEnabled -- or true
end

function Button:isEnabled()
  return self.enabled
end

function Button:setAnchor(buttonAnchorPoint, offX, offY)
  self.anchor = buttonAnchorPoint or nil
  self.offsetX = offX
  self.offsetY = offY
end

function Button:getPosition()
  if ( self.anchor ) then
    local iw, ih = self.image:getDimensions()

    local px, py = getAnchoredPosition(self.anchor, self.position.x, self.position.y, self.offsetX, self.offsetY, iw, ih, self.scale) 

    return px, py
  else
    return self.position.x, self.position.y
  end
end

function Button:onClick(sender)
  if ( self.onButtonClick ~= nil ) then
    self:onButtonClick(sender)
  end
end