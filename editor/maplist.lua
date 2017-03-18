

require("..engine.lclass")
require("..engine.io.io")

require("../editor/textinput")

local allmaps = {}

local modfun = math.fmod
local floorfun = math.floor

local options = {
  "F1 - New Map",
  "F2 - Edit Name",
  "F3 - Remove Map",
  "",
  "F4 - Edit Map",
  "",
  "Ctrl + J - Set Map Script",
  "",
  "F9 - Save List",
  "F11 - Back",
  "",
  "Pg Up - Previous Page",
  "Pg Down - Next Page"
}

class "MapList"

function MapList:MapList( ownerEditor, thegame )
  self.game      = thegame
  self.editor    = ownerEditor

  self.pageIndex = 1
  self.selIndex  = 1
  self.listStart = 1
  self.listEnd   = 1

  self.mode      = 0
  self.inputMode = 0
  self.textInput = nil

  self.mapEditor = nil

  self.tempData  = nil
end

function MapList:save()
  self.game:getMapManager():saveList( allmaps )
end

function MapList:load()
  allmaps = self.game:getMapManager():loadList()
end

function MapList:onEnter()
  print("Entered MapList")

  self:load()
  self:refreshList()
end

function MapList:onExit()

end

function MapList:update(dt)
  if ( self.mode == 1 or self.mode == 2 or self.mode == 7 ) then
    self:updateAddEdit( dt )
    return
  end

  if ( self.mapEditor ) then
    self.mapEditor:update( dt )
    return
  end

end

function MapList:draw()
  if ( self.textInput ) then

    self.textInput:draw()

  elseif ( self.mapEditor ) then
      self.mapEditor:draw()
  else
    for i = 1, #options do
      love.graphics.print(options[i], 16, (i * 16) + 40)
    end

    self:drawMapList()
  end

end

function MapList:drawMapList()

  love.graphics.setColor( 0, 255, 100, 255 )
  love.graphics.print( "Name", 200, 56 )
  love.graphics.print( "File", 500, 56 )
  love.graphics.print( "Engine Version", 800, 56 )
  love.graphics.setColor( colors.WHITE )

  if ( #allmaps == 0) then
    return
  end

  love.graphics.setColor( 255, 255, 255, 80 )
  love.graphics.rectangle( "fill", 190, ( self.selIndex * 16 ) + 56, 1000, 18 )
  love.graphics.setColor( colors.WHITE )

  for i = self.listStart, self.listEnd do
    love.graphics.print( allmaps[i][1], 200, ( ( i - self.listStart + 1 ) * 16) + 56 )
    love.graphics.print( allmaps[i][2], 500, ( ( i - self.listStart + 1 ) * 16) + 56 )
    love.graphics.print( allmaps[i][3], 800, ( ( i - self.listStart + 1 ) * 16) + 56 )
  end

end

function MapList:updateAddEdit(dt)
  if ( self.textInput:isFinished() ) then

    if ( self.mode == 7 ) then
      self:setScript( self.textInput:getText() )
    else
      self:setMapData( self.textInput:getText() )
    end

  end
end

function MapList:setScript( scriptname )
  local scname, scpath = self.game:getScriptManager():getScriptByName( scriptname, true )

  if ( scpath ) then
    local map = self.game:getMapManager():loadMap( allmaps[self.selIndex][1], allmaps[self.selIndex][2] )

    if ( map ) then
      map:setScript( scname, scpath )
      self.game:getMapManager():saveMap( allmaps[self.selIndex][1], allmaps[self.selIndex][2], map )
    end
  else
    print("Script not found")
  end

  self.tempData  = nil
  self.inputMode = 0
  self.mode      = 0
  self.textInput = nil

  self:refreshList()
end

function MapList:setMapData( str )
  self.tempData[self.inputMode] = str

  self.inputMode = self.inputMode + 1

  self.textInput = TextInput( "File Name: " )

  if ( self.inputMode == 3 ) then -- have everything
    self.tempData[3] = glob.engineVersion

    if ( self.mode == 1 ) then
      table.insert( allmaps, self.tempData )
    else
      allmaps[self.selIndex] = self.tempData
    end

    self.tempData  = nil
    self.inputMode = 0
    self.mode      = 0
    self.textInput = nil

    self:refreshList()
  end
end

function MapList:onKeyPress( key, scancode, isrepeat )
  if ( self.mode == 1 or self.mode == 2 or self.mode == 7 ) then
    self.textInput:keypressed( key )
    return
  end

  if ( self.mapEditor  ) then
    self.mapEditor:onKeyPress( key, scancode, isrepeat )
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

  if ( ( key == "j" ) and ( Input:isKeyDown("lctrl") ) ) then
    self:setScriptMode()
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

function MapList:onMousePress( x, y, button, istouch )
  if ( self.mapEditor ) then

    if ( self.mapEditor.onMousePress ) then
      self.mapEditor:onMousePress( x, y, button, istouch )
    end

  end
end

function MapList:onMouseRelease( x, y, button, istouch )
  if ( self.mapEditor ) then

    if ( self.mapEditor.onMouseRelease ) then
      self.mapEditor:onMouseRelease( x, y, button, istouch )
    end

  end
end

function MapList:onMouseMove( x, y, dx, dy )

  if ( self.mapEditor ) then

    if ( self.mapEditor.onMouseMove ) then
      self.mapEditor:onMouseMove( x, y, dx, dy )
    end

  end
end

function MapList:removeSelected()
  local delIndex = self.selIndex + ( self.pageIndex - 1 ) * 40

  table.remove(allmaps, delIndex)

  self:refreshList()
end

function MapList:doTextInput ( t )
  if ( self.textInput ) then
    self.textInput:input( t )
    return
  end

  if ( self.mapEditor ) then
    self.mapEditor:doTextInput( t )
    return
  end

end

function MapList:addMode()
  self.tempData  = {}
  self.mode      = 1
  self.inputMode = 1
  self.textInput = TextInput( "Map Name:" )
end

function MapList:editMode()
  self.tempData  = {}
  self.mode      = 2
  self.inputMode = 1
  self.textInput = TextInput( "Map Name:", allmaps[self.selIndex][1] )
end

function MapList:setScriptMode()
  self.tempData  = {}
  self.mode      = 7
  self.inputMode = 1
  self.textInput = TextInput( "Script Name:" )
end

function MapList:editSelected()
  local mapindex = self.selIndex + ( self.pageIndex - 1 ) * 40

  self.mode = 4

  self.mapEditor = MapEditor( self, mapindex, allmaps[mapindex][1], allmaps[mapindex][2], self.game )

  self.mapEditor:onEnter()
end

function MapList:backFromEdit()
  self.mapEditor:onExit()
  self.mapEditor = nil
end

function MapList:refreshList()
  --//TODO go to same page ?
  self.selIndex  = 1
  self.pageIndex = 1

  self.listStart = ( self.pageIndex - 1 ) * 40 + 1

  self.listEnd = self.listStart + 40 - 1

  if ( self.listEnd > #allmaps ) then
    self.listEnd   = #allmaps
  end
end

function MapList:selectPrevious( steps )
  steps = steps or 1

  self.selIndex = self.selIndex - steps

  if ( self.selIndex <= 0 ) then
    self.selIndex = 1
  end
end

function MapList:selectNext( steps )
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

function MapList:listUp()
  self.pageIndex = self.pageIndex - 1

  if (self.pageIndex == 0) then
    self.pageIndex = 1
  end

  self.listStart = (self.pageIndex - 1) * 40 + 1

  self.listEnd = self.listStart + 40 - 1

  if (self.listEnd > #allmaps) then
    self.listEnd = #allmaps
  end
end

function MapList:listDown()
  self.pageIndex = self.pageIndex + 1

  if (self.pageIndex > modfun(#allmaps, 40)) then
    self.pageIndex = modfun(#allmaps, 40)
  end

  self.listStart = (self.pageIndex - 1) * 40 + 1

  self.listEnd = self.listStart + 40

  if (self.listEnd > #allmaps) then
    self.listEnd = #allmaps
  end

end
