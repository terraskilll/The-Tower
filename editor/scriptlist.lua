--[[

the engine resource list. it allows to add images and sounds to the
list of available resources. all resources names and paths are loaded
when the game starts, and the resources are loaded by paths an level editors

a resource is identified by a name, a type and a path.

]]

require("..engine.lclass")
require("..engine.io.io")

require("..editor.textinput")

local modfun = math.fmod
local floorfun = math.floor

local options = {
  "F1 - Add Script",
  "F3 - Remove Script",
  "",
  "F9 - Save List",
  "F11 - Back",
  "",
  "Pg Up - Previous Page",
  "Pg Down - Next Page"
}

class "ScriptList"

local allscripts = {}

function ScriptList:ScriptList( ownerEditor, thegame )
  self.game      = thegame
  self.editor    = ownerEditor

  self.pageIndex = 1
  self.selIndex  = 1
  self.listStart = 1
  self.listEnd   = 1

  self.mode      = 0
  self.textInput = nil

  self.tempData  = nil
end

function ScriptList:addScript( scriptname, scriptfile )
  table.insert(allscripts, { scriptname, scriptfile } )
end

function ScriptList:save()
  self.game:getScriptManager():save( allscripts )
end

function ScriptList:load()
  allscripts = self.game:getScriptManager():load()
end

function ScriptList:onEnter()
  print("Entered ScriptList")

  self:load()
  self:refreshList()
end

function ScriptList:onExit()

end

function ScriptList:draw()
  if ( self.textInput ) then

    self.textInput:draw()

  else
    for i = 1, #options do
      love.graphics.print( options[i], 16, (i * 16) + 40 )
    end

    self:drawScriptList()
  end

end

function ScriptList:drawScriptList()

  love.graphics.setColor( 0, 255, 100, 255 )
  love.graphics.print( "Name", 200, 56 )
  love.graphics.print( "File", 500, 56 )
  love.graphics.setColor( glob.defaultColor )

  love.graphics.setColor( 255, 255, 255, 80 )
  love.graphics.rectangle( "fill", 190, (self.selIndex * 16) + 56, 1000, 18 )
  love.graphics.setColor( glob.defaultColor )

  if ( #allscripts == 0 ) then
    return
  end

  for i = self.listStart, self.listEnd do
    love.graphics.print( allscripts[i][1], 200, ( (i - self.listStart + 1) * 16) + 56 )
    love.graphics.print( allscripts[i][2], 500, ( (i - self.listStart + 1) * 16) + 56 )
  end

end

function ScriptList:update( dt )

  if ( self.mode == 1 or self.mode == 2 ) then
    self:updateAddEdit(dt)
  end

end

function ScriptList:onKeyPress( key, scancode, isrepeat )
  if ( self.mode == 1 or self.mode == 2 ) then
    self.textInput:keypressed( key )
    return
  end

  if ( key == "f1" ) then
    self.tempData  = {}
    self.mode      = 1
    self.textInput = TextInput("Script Name:")
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
    return
  end

  if ( key == "f11" ) then
    self.editor:backFromEdit()
    return
  end
end

function ScriptList:removeSelected()
  local delIndex = self.selIndex + ( self.pageIndex - 1 ) * 40

  table.remove( allscripts, delIndex )

  self:refreshList()
end

function ScriptList:doTextInput ( t )
  if ( self.textInput ) then
    self.textInput:input( t )
  end
end

function ScriptList:updateAddEdit( dt )
  if ( self.textInput:isFinished() ) then

    if ( self.mode == 2 ) then
      self.tempData[2] = self.textInput:getText()
      self.mode = 3
    end

    if ( self.mode == 1 ) then
      self.tempData[1] = self.textInput:getText()
      self.textInput = TextInput( "File name:" )
      self.mode = 2
    end

    if ( self.mode == 3 ) then

      self:addScript( self.tempData[1], self.tempData[2] )

      self.tempData  = nil
      self.mode      = 0
      self.textInput = nil

      self:refreshList()
    end

  end
end

function ScriptList:refreshList()
  --//TODO go to same page ?
  self.selIndex  = 1
  self.pageIndex = 1

  self.listStart = ( self.pageIndex - 1 ) * 40 + 1

  self.listEnd = self.listStart + 40

  if ( self.listEnd > #allscripts ) then
    self.listEnd   = #allscripts
  end
end

function ScriptList:selectPrevious( steps )
  steps = steps or 1

  self.selIndex = self.selIndex - steps

  if ( self.selIndex <= 0 ) then
    self.selIndex = 1
  end
end

function ScriptList:selectNext( steps )
  steps = steps or 1

  self.selIndex = self.selIndex + steps

  --//TODO get list bounds
  if ( self.selIndex > 40 ) then
    self.selIndex = 40
  end

  if ( self.listEnd < self.selIndex ) then
     self.selIndex = self.listEnd
  end
end

function ScriptList:listUp()
  self.pageIndex = self.pageIndex - 1

  if (self.pageIndex == 0) then
    self.pageIndex = 1
  end

  self.listStart = ( self.pageIndex - 1 ) * 40 + 1

  self.listEnd = self.listStart + 40 - 1

  if ( self.listEnd > #allscripts ) then
    self.listEnd   = #allscripts
  end
end

function ScriptList:listDown()
  self.pageIndex = self.pageIndex + 1

  if ( self.pageIndex > modfun( #allscripts, 40 ) ) then
    self.pageIndex = modfun( #allscripts, 40 )
  end

  self.listStart = (self.pageIndex - 1) * 40 + 1

  self.listEnd = self.listStart + 40 - 1

  if ( self.listEnd > #allscripts ) then
    self.listEnd   = #allscripts
  end
end
