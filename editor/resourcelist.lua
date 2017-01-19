--[[

the engine resource list. it allows to add images and sounds to the
list of available resources. all resources names and paths are loaded
when the game starts, and the resources are loaded by paths an level editors

a resource is identified by a name, a type and a path.

]]

require("../engine/lclass")
require("../engine/io/io")

require("../editor/textinput")

local modfun = math.fmod
local floorfun = math.floor

local options = {
  "F1 - Add Resource",
  "F2 - Edit Resource",
  "F3 - Remove Resource",
  "F9 - Save",
  "Pg Up - Previous Page",
  "Pg Down - Next Page"
}

class "ResourceList"

local allResources = {}

function ResourceList:ResourceList()
  self.pageIndex = 1
  self.selIndex  = 1
  self.listStart = 1
  self.listEnd   = 1

  self.mode      = 0
  self.inputMode = 0
  self.textInput = nil

  self.tempData  = nil
end

function ResourceList:addResource( resourceName, resourceType, resourcePath )
  table.insert(allResources, { resourceName, resourceType, resourcePath })
end

function ResourceList:save()
  saveFile("__resourcelist", allResources)
end

function ResourceList:load()
  allResources, err = loadFile("__resourcelist")

  if (allResources == nil) then
    allResources = {}
  end
end

function ResourceList:onEnter()
  print("Entered ResourceList")

  self:load()
  self:refreshList()
end

function ResourceList:onExit()
  --self:save()
end

function ResourceList:draw()
  if ( self.textInput ~= nil ) then

    self.textInput:draw()

  else
    for i = 1, #options do
      love.graphics.print(options[i], 16, (i * 16) + 40)
    end

    self:drawResourceList()
  end

end

function ResourceList:drawResourceList()

  love.graphics.setColor(0, 255, 100, 255)
  love.graphics.print("Name", 200, 56)
  love.graphics.print("Type", 400, 56)
  love.graphics.print("Path", 600, 56)
  love.graphics.setColor(glob.defaultColor)

  love.graphics.setColor(255, 255, 255, 80)
  love.graphics.rectangle("fill", 190, (self.selIndex * 16) + 56, 1000, 18)
  love.graphics.setColor(glob.defaultColor)

  if ( #allResources == 0) then
    return
  end

  for i = self.listStart, self.listEnd do
    love.graphics.print(allResources[i][1], 200, ( (i - self.listStart + 1) * 16) + 56)
    love.graphics.print(allResources[i][2], 400, ( (i - self.listStart + 1) * 16) + 56)
    love.graphics.print(allResources[i][3], 600, ( (i - self.listStart + 1) * 16) + 56)
  end

end

function ResourceList:update(dt)
  if ( self.mode == 1 or self.mode == 2 ) then
    self:updateAddEdit(dt)
  end
end

function ResourceList:onKeyPress(key, scancode, isrepeat)
  if ( self.mode == 1 or self.mode == 2 ) then
    self.textInput:keypressed( key )
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

function ResourceList:addMode()
  self.tempData  = {}
  self.mode      = 1
  self.inputMode = 1
  self.textInput = TextInput("Resource Name:")
end

function ResourceList:editMode()
  self.tempData  = {}
  self.mode      = 2
  self.inputMode = 1
  self.textInput = TextInput("Resource Name:", allResources[self.selIndex][1])
end

function ResourceList:removeSelected()
  local delIndex = self.selIndex + ( self.pageIndex - 1 ) * 40

  table.remove(allResources, delIndex)

  self:refreshList()
end

function ResourceList:doTextInput ( t )
  if ( self.textInput ~= nil ) then
    self.textInput:input( t )
  end
end

function ResourceList:updateAddEdit(dt)
  if ( self.textInput:isFinished() ) then
    self.inputMode = self.inputMode + 1

    if ( self.inputMode == 2 ) then
      self.tempData[1] = self.textInput:getText()

      if ( self.mode == 1 ) then
        self.textInput = TextInput("Resource Type (image or audio):")
      else
        self.textInput = TextInput("Resource Type (image or audio):", allResources[self.selIndex][2])
      end

    end

    if ( self.inputMode == 3 ) then
      self.tempData[2] = self.textInput:getText()

      if ( self.mode == 1 ) then
        self.textInput = TextInput("Path to Resource (relative):")
      else
        self.textInput = TextInput("Path to Resource (relative):", allResources[self.selIndex][3])
      end

    end

    if ( self.inputMode == 4 ) then -- have everything
      self.tempData[3] = self.textInput:getText()

      if ( self.mode == 1 ) then
        table.insert(allResources, self.tempData)
      else
        allResources[self.selIndex] = self.tempData
      end

      self.tempData  = nil
      self.inputMode = 0
      self.mode      = 0
      self.textInput = nil

      self:refreshList()
    end

  end
end

function ResourceList:refreshList()
  --//TODO go to same page ?
  self.selIndex  = 1
  self.pageIndex = 1

  self.listStart = (self.pageIndex - 1) * 40 + 1

  self.listEnd = self.listStart + 40

  if (self.listEnd > #allResources) then
    self.listEnd   = #allResources
  end
end

function ResourceList:selectPrevious(steps)
  steps = steps or 1

  self.selIndex = self.selIndex - steps

  if ( self.selIndex <= 0 ) then
    self.selIndex = 1
  end
end

function ResourceList:selectNext(steps)
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

function ResourceList:listUp()
  self.pageIndex = self.pageIndex - 1

  if (self.pageIndex == 0) then
    self.pageIndex = 1
  end

  self.listStart = (self.pageIndex - 1) * 40 + 1

  self.listEnd = self.listStart + 40 - 1

  if (self.listEnd > #allResources) then
    self.listEnd   = #allResources
  end
end

function ResourceList:listDown()
  self.pageIndex = self.pageIndex + 1

  if (self.pageIndex > modfun(#allResources, 40)) then
    self.pageIndex = modfun(#allResources, 40)
  end

  self.listStart = (self.pageIndex - 1) * 40 + 1

  self.listEnd = self.listStart + 40 - 1

  if (self.listEnd > #allResources) then
    self.listEnd   = #allResources
  end
end
