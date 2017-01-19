--[[

list all static game objects and allow to add and edit objects

]]

require("../engine/lclass")
require("../engine/io/io")

require("../editor/textinput")

local modfun = math.fmod
local floorfun = math.floor

local options = {
  "F1 - Create Object",
  "F2 - Edit Properties",
  "F3 - Remove Object",
  "",
  "F4 - Edit Object",
  "F9 - Save",
  "Pg Up - Previous Page",
  "Pg Down - Next Page"
}

class "ObjectList"

local allObjects = {}

function ObjectList:ObjectList()
  self.pageIndex = 1
  self.selIndex  = 1
  self.listStart = 1
  self.listEnd   = 1

  self.mode      = 0
  self.inputMode = 0
  self.textInput = nil

  self.objectEditor = nil

  self.tempData  = nil
end

function ObjectList:save()
  saveFile("__objectlist", allObjects)
end

function ObjectList:load()
  allObjects, err = loadFile("__objectlist")

  if (allObjects == nil) then
    allObjects = {}
  end
end

function ObjectList:onEnter()
  print("Entered ObjectList")

  self:load()
  self:refreshList()
end

function ObjectList:onExit()

end

function ObjectList:update(dt)
  if ( self.mode == 1 or self.mode == 2 ) then
    self:updateAddEdit( dt )
    return
  end

  if ( self.objectEditor ~= nil ) then
    self.objectEditor:update( dt )
    return
  end

end

function ObjectList:draw()
  if ( self.textInput ~= nil ) then

    self.textInput:draw()

  elseif ( self.objectEditor ~= nil ) then
      self.objectEditor:draw()
  else
    for i = 1, #options do
      love.graphics.print(options[i], 16, (i * 16) + 40)
    end

    self:drawObjectList()
  end

end

function ObjectList:drawObjectList()

  love.graphics.setColor(0, 255, 100, 255)
  love.graphics.print("Name", 200, 56)
  love.graphics.setColor(glob.defaultColor)

  if ( #allObjects == 0) then
    return
  end

  love.graphics.setColor(255, 255, 255, 80)
  love.graphics.rectangle("fill", 190, (self.selIndex * 16) + 56, 1000, 18)
  love.graphics.setColor(glob.defaultColor)

  for i = self.listStart, self.listEnd do
    love.graphics.print(allObjects[i][1], 200, ( (i - self.listStart + 1) * 16) + 56)
  end

end

function ObjectList:updateAddEdit(dt)
  if ( self.textInput:isFinished() ) then
    self.inputMode = self.inputMode + 1

    self.tempData[1] = self.textInput:getText()

    if ( self.inputMode == 2 ) then -- have everything
      self.tempData[2] = {}

      if ( self.mode == 1 ) then
        table.insert(allObjects, self.tempData)
      else
        allObjects[self.selIndex] = self.tempData
      end

      self.tempData  = nil
      self.inputMode = 0
      self.mode      = 0
      self.textInput = nil

      self:refreshList()
    end

  end
end

function ObjectList:onKeyPress(key, scancode, isrepeat)
  if ( self.mode == 1 or self.mode == 2 ) then
    self.textInput:keypressed( key )
    return
  end

  if ( self.objectEditor ~= nil ) then
    self.objectEditor:onKeyPress( key, scancode, isrepeat )
    return
  end

  if ( key == "f1" ) then
    self:addMode()
  end

  if ( key == "f2" ) then
    self:editMode()
  end

  if ( key == "f3" ) then
    self:removeSelected()
  end

  if ( key == "f4" ) then
    self:editSelected()
  end

  if ( key == "pageup" ) then
    self:listUp()
  end

  if ( key == "pagedown" ) then
    self:listDown()
  end

  if ( key == "up" ) then
    if ( Input:isKeyDown("lctrl") ) then
      self:selectPrevious(10)
    else
      self:selectPrevious()
    end
  end

  if ( key == "down" ) then
    if ( Input:isKeyDown("lctrl") ) then
      self:selectNext(10)
    else
      self:selectNext()
    end
  end

  if ( key == "f9" ) then
    self:save()
  end
end

function ObjectList:removeSelected()
  local delIndex = self.selIndex + ( self.pageIndex - 1 ) * 40

  table.remove(allObjects, delIndex)

  self:refreshList()
end

function ObjectList:doTextInput ( t )
  if ( self.textInput ~= nil ) then
    self.textInput:input( t )
    return
  end

  if (self.objectEditor ~= nil) then
    self.objectEditor:doTextInput( t )
    return
  end
end

function ObjectList:addMode()
  self.tempData  = {}
  self.mode      = 1
  self.inputMode = 1
  self.textInput = TextInput("Object Name:")
end

function ObjectList:editMode()
  self.tempData  = {}
  self.mode      = 2
  self.inputMode = 1
  self.textInput = TextInput("Object Name:", allObjects[self.selIndex][1])
end

function ObjectList:editSelected()
  local objIndex = self.selIndex + ( self.pageIndex - 1 ) * 40

  self.mode = 4

  self.objectEditor = ObjectEditor(self, objIndex, allObjects[objIndex][1], allObjects[objIndex][2])
end

function ObjectList:backFromEdit()
  self.objectEditor = nil
end

function ObjectList:refreshList()
  --//TODO go to same page ?
  self.selIndex  = 1
  self.pageIndex = 1

  self.listStart = (self.pageIndex - 1) * 40 + 1

  self.listEnd = self.listStart + 40 - 1

  if (self.listEnd > #allObjects) then
    self.listEnd   = #allObjects
  end
end

function ObjectList:selectPrevious(steps)
  steps = steps or 1

  self.selIndex = self.selIndex - steps

  if ( self.selIndex <= 0 ) then
    self.selIndex = 1
  end
end

function ObjectList:selectNext(steps)
  steps = steps or 1

  self.selIndex = self.selIndex + steps

  --//TODO get list bounds
  if ( self.selIndex > 40 ) then
    self.selIndex = 40
  end

  if ( self.listEnd < self.selIndex) then
     self.selIndex = self.listEnd
  end
end

function ObjectList:listUp()
  self.pageIndex = self.pageIndex - 1

  if (self.pageIndex == 0) then
    self.pageIndex = 1
  end

  self.listStart = (self.pageIndex - 1) * 40 + 1

  self.listEnd = self.listStart + 40 - 1

  if (self.listEnd > #allObjects) then
    self.listEnd = #allObjects
  end
end

function ObjectList:listDown()
  self.pageIndex = self.pageIndex + 1

  if (self.pageIndex > modfun(#allObjects, 40)) then
    self.pageIndex = modfun(#allObjects, 40)
  end

  self.listStart = (self.pageIndex - 1) * 40 + 1

  self.listEnd = self.listStart + 40

  if (self.listEnd > #allObjects) then
    self.listEnd = #allObjects
  end
end
