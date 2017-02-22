
--[[-----------------------------------------------------------------------------
simple selector class for menus.

must be used with a buttongroup for menu management (focus and click)

------------------------------------------------------------------------------]]--
require("../engine/globalconf")
require("../engine/lclass")
require("../engine/ui/anchor")

local Vec = require("../engine/math/vector")

local selectorShader = love.graphics.newShader("engine/shaders/ui.glsl")

class "Selector"

function Selector:Selector(positionX, positionY, captionText, selectorImage, selectorScale)
  self.position   = Vec(positionX, positionY)
  self.caption    = captionText
  self.image      = selectorImage
  self.scale      = selectorScale or 1
  self.width      = selectorImage:getWidth()
  self.height     = selectorImage:getHeight()

  self.altDelay    = 0.16
  self.selected    = false
  self.enabled     = true
  self.changed     = false
  self.anchor      = nil

  self.selectedIndex = 1
  self.options       = {}
  self.optionValues  = {}

  self.currentOption = nil
  self.currentValue  = nil

  self.onSelectorChange = nil
end

function Selector:update(dt)
  if (self.selected == false) then
    return
  end

  local keyVec = Input:getAxis()

  if (keyVec.x == 0) then
    self.altDelay = 0.16
  else
    self.altDelay = self.altDelay + dt

    if ( self.altDelay >= 0.16 ) then
      if ( keyVec.x == -1 ) then
        self:selectPrevious()
        self.altDelay = 0
      end

      if ( keyVec.x == 1 ) then
        self:selectNext()
        self.altDelay = 0
      end

    end
  end

end

function Selector:draw()
  selectorShader:send("uIsSelected", self.selected)
  selectorShader:send("uIsEnabled", self.enabled)

  x, y = self:getPosition()

  love.graphics.setShader(selectorShader)
  love.graphics.draw(self.image, x, y, 0, self.scale, self.scale)

  love.graphics.setShader()

  self:drawText()
end

function Selector:getPosition()
  if ( self.anchor ) then
    return self:getPositionByAnchor()
  else
    return self.position.x, self.position.y
  end
end

function Selector:getPositionByAnchor()
  return getAnchoredPosition( self.anchor, self.position.x, self.position.y, self.offsetX, self.offsetY, self.width, self.height, self.scale )
end

function Selector:drawText()
  love.graphics.setNewFont(80 * self.scale)

  --// shader does not like transparency in text =(
  local a = 255

  if (self.enabled == false) then
    a = 64
  elseif ( self.selected == false) then
    a = 153
  end

  love.graphics.setColor( 255, 255, 255, a)
  love.graphics.print(self.caption, x + 96 * self.scale, y + 5 * self.scale)
  love.graphics.print(self.currentOption, x + 800 * self.scale, y + 5 * self.scale)
  love.graphics.setColor( 255, 255, 255, 255)

  love.graphics.setNewFont(glob.defaultFontSize)
end

function Selector:setAnchor(anchorPoint, offX, offY)
  self.anchor = anchorPoint or nil
  self.offsetX = offX
  self.offsetY = offY
end

function Selector:addOption(newOption, returnValue)
  table.insert(self.options, newOption)
  table.insert(self.optionValues, returnValue)
end

function Selector:selectNext()
  self.selectedIndex = self.selectedIndex + 1

  if (self.selectedIndex > #self.options) then
    self.selectedIndex = 1
  end

  self.currentOption =  self.options[self.selectedIndex]
  self.currentValue  =  self.optionValues[self.selectedIndex]

  self.changed = true
end

function Selector:selectPrevious()
  self.selectedIndex = self.selectedIndex - 1

  if (self.selectedIndex <= 0) then
    self.selectedIndex = #self.options
  end

  self.currentOption =  self.options[self.selectedIndex]
  self.currentValue  =  self.optionValues[self.selectedIndex]

  self.changed = true
end

function Selector:setDefaultOptionIndex(defaultIndex)
  self.selectedIndex = defaultIndex
  self.currentOption = self.options[self.selectedIndex]
  self.currentValue  = self.optionValues[self.selectedIndex]
end

function Selector:haveChanged()
  return self.changed
end

function Selector:unchange()
  self.changed = false
end

function Selector:onChange( sender )
  if ( self.onSelectorChange ~= nil ) then
    self:onSelectorChange( sender,  self.currentValue)
  end
end

function Selector:setSelected(isSelected)
  self.selected = isSelected or false
end

function Selector:setEnabled(isEnabled)
  self.enabled = isEnabled -- or true
end

function Selector:isEnabled()
  return self.enabled
end

function Selector:getValue()
  return self.currentValue
end

function Selector:checkMouseOver( x, y )
  return false
end
