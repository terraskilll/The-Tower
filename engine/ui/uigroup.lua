require("../engine/lclass")

require("../engine/input")

class "UIGroup"

function UIGroup:UIGroup()
  self.altDelay      = 0.16
  self.selectedIndex = 1
  self.items         = {}
  self.loopCount     = 0
  self.visible       = true
end

function UIGroup:update(dt)
  local keyVec = Input:getAxis()

  if (keyVec.y == 0) then
    self.altDelay = 0.16
  else
    self.altDelay = self.altDelay + dt

    if ( self.altDelay >= 0.16 ) then

      if ( keyVec.y == -1 ) then
        self:selectPrevious()
        self.altDelay = 0
      end

      if ( keyVec.y == 1 ) then
        self:selectNext()
        self.altDelay = 0
      end

    end
  end

  self:updateComponents(dt)
end

function UIGroup:updateComponents(dt)
  for _,comp in ipairs(self.items) do
    comp:update(dt)
  end
end

function UIGroup:keyPressed(key, sender)

  if ( key == "return" or key == "kpenter" ) then
    if ( self.items[self.selectedIndex].onClick ) then
      self.items[self.selectedIndex]:onClick(sender)
    end
  end

  if ( key == "left" or key == "right" ) then
    if ( self.items[self.selectedIndex].onSelectorChange ) then
      self.items[self.selectedIndex]:onChange( sender )
    end
  end

end

function UIGroup:addButton(button)
  table.insert(self.items, button)

  if (#self.items == 1) then
    self:selectFirst()
  end

end

function UIGroup:setVisible(isVisible)
  self.visible = isVisible
end

function UIGroup:selectFirst()
  self.selectedIndex = 1

  self:desselectAll()

  if ( self.items[self.selectedIndex]:isEnabled() ) then
    self.items[self.selectedIndex]:setSelected(true)
    self.loopCount = 0
  else
    self:checkLoop(1)
  end
end

function UIGroup:selectNext()
  self.selectedIndex = self.selectedIndex + 1

  if (self.selectedIndex > #self.items) then
    self.selectedIndex = 1
  end

  self:desselectAll()

  if ( self.items[self.selectedIndex]:isEnabled() ) then
    self.items[self.selectedIndex]:setSelected( true )
    self.loopCount = 0
  else
    self:checkLoop(1)
  end
end

function UIGroup:selectPrevious()
  self.selectedIndex = self.selectedIndex - 1

  if (self.selectedIndex <= 0) then
    self.selectedIndex = #self.items
  end

  self:desselectAll()

  if ( self.items[self.selectedIndex]:isEnabled() ) then
    self.items[self.selectedIndex]:setSelected(true)
    self.loopCount = 0
  else
    self:checkLoop(-1)
  end
end

function UIGroup:checkLoop( whereToGo )
  -- check "loops" (all buttons are disabled) and
  -- does not allow the buttongroup to lock in selectNext/selectPrevious
  if ( #self.items > 0 ) then

    self.loopCount = self.loopCount + 1

    -- there is enabled buttons
    if ( self.loopCount < #self.items ) then

      if (whereToGo == 1) then
        self:selectNext()
      else
        self:selectPrevious()
      end

    end

  end
end

function UIGroup:draw()

  if ( self.visible ) then

    for _,v in ipairs(self.items) do
        v:draw()
    end

  end

end

function UIGroup:desselectAll()

  for _,v in ipairs(self.items) do
      v:setSelected(false)
  end

end

function UIGroup:joystickPressed( joystick, button, sender )

  if ( button == 1 or button == 8 ) then

    if ( self.items[self.selectedIndex].onClick ) then
      self.items[self.selectedIndex]:onClick( sender )
    end

  end

end

function UIGroup:mousePressed( x, y, button, scaleX, scaleY, sender )

  if ( button == 1 ) then

    if ( self.items[self.selectedIndex]:isMouseOver( x, y) ) then
      self.items[self.selectedIndex]:onClick( sender )
    end

  end

end

function UIGroup:mouseReleased( x, y, button, scaleX, scaleY, sender )

end

function UIGroup:mouseMoved( x, y, dx, dy, scaleX, scaleY, sender )
  local over = false

  local sel = 0

  local i = 1

  for _,v in ipairs( self.items ) do
    if ( not over ) then

      over = v:isMouseOver( x, y )

      if ( over ) then
        sel = i
      end

      i = i + 1

    end

  end

  if ( over ) then

    if ( self.items[sel]:isEnabled() ) then
      self:desselectAll()
      self.selectedIndex = sel
      self.items[self.selectedIndex]:setSelected( true )
    end

  end

end
