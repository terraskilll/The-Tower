require("lclass")

require("input")

class "ButtonGroup"

function ButtonGroup:ButtonGroup()
  self.altDelay = 0.16
  self.selectedIndex = 1
  self.buttons = {}
  self.loopCount = 0
  self.visible = true
end

function ButtonGroup:update(dt)
  local xKey, yKey = Input:getAxis()
  
  if ( Input:isKeyDown("down") ) then
    yKey = 1
  end

  if ( Input:isKeyDown("up") ) then
    yKey = -1
  end

  if (yKey == 0) then
    self.altDelay = 0.16
  else
    self.altDelay = self.altDelay + dt

    if ( self.altDelay >= 0.16 ) then
      
      if ( yKey == -1 ) then
        self:selectPrevious()
        self.altDelay = 0
      end

      if ( yKey == 1 ) then
        self:selectNext()
        self.altDelay = 0
      end

    end
  end
end

function ButtonGroup:keyPressed(key, sender)
  
  if ( key == "return" or key == "kpenter" ) then
    self.buttons[self.selectedIndex]:onClick(sender)
  end

end

function ButtonGroup:addButton(button)
  table.insert(self.buttons, button)

  if (#self.buttons == 1) then
    self:selectFirst()
  end

end

function ButtonGroup:setVisible(isVisible)
  self.visible = isVisible
end

function ButtonGroup:selectFirst()
  self.selectedIndex = 1

  self:desselectAll()

  if ( self.buttons[self.selectedIndex]:isEnabled() ) then
    self.buttons[self.selectedIndex]:setSelected(true)
    self.loopCount = 0
  else
    self:checkLoop(1)
  end
end

function ButtonGroup:selectNext()
  self.selectedIndex = self.selectedIndex + 1

  if (self.selectedIndex > #self.buttons) then
    self.selectedIndex = 1
  end

  self:desselectAll()

  if ( self.buttons[self.selectedIndex]:isEnabled() ) then
    self.buttons[self.selectedIndex]:setSelected(true)
    self.loopCount = 0
  else
    self:checkLoop(1)
  end
end

function ButtonGroup:selectPrevious()
  self.selectedIndex = self.selectedIndex - 1

  if (self.selectedIndex <= 0) then
    self.selectedIndex = #self.buttons
  end

  self:desselectAll()

  if ( self.buttons[self.selectedIndex]:isEnabled() ) then
    self.buttons[self.selectedIndex]:setSelected(true)
    self.loopCount = 0
  else
    self:checkLoop(-1)
  end
end

function ButtonGroup:checkLoop(whereToGo)
  -- check "loops" (all buttons are disabled) and 
  -- does not allow the buttongroup to lock in selectNext/selectPrevious
  if ( #self.buttons > 0 ) then
    
    self.loopCount = self.loopCount + 1
    
    -- there is enabled buttons
    if ( self.loopCount < #self.buttons ) then

      if (whereToGo == 1) then
        self:selectNext()
      else
        self:selectPrevious()
      end

    end

  end
end

function ButtonGroup:drawButtons()
  
  if ( self.visible ) then
    for _,v in ipairs(self.buttons) do
        v:draw()
    end
  end

end

function ButtonGroup:desselectAll()
  
  for _,v in ipairs(self.buttons) do
      v:setSelected(false)
  end

end

function ButtonGroup:joystickPressed(joystick, button, sender)
  
  if ( button == 1 or button == 8 ) then
    self.buttons[self.selectedIndex]:onClick(sender)
  end

end