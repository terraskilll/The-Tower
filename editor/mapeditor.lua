--[[

the engine map editor

]]

require("../engine/lclass")
require("../engine/input")
require("../engine/ui/uigroup")
require("../engine/ui/button/button")
require("../engine/screen/screen")
require("../engine/gameobject/gameobject")
require("../engine/gameobject/staticimage")
require("../engine/gameobject/simpleobject")
require("../engine/gameobject/movingobject")
require("../engine/light/light")
require("../engine/map/map")
require("../engine/map/area")
require("../engine/map/spawnpoint")
require("../engine/collision/collision")
require("../engine/navigation/navmesh")
require("../engine/navigation/navmap")
require("../engine/utl/funcs")

require("../editor/objectselector")

local Vec = require("../engine.math.vector")

local generalOptions = {
  "/ - Help/Command List",
  "Numpad '+/-' - Change Inc Modifier",
  "F9 - Save",
  "F11 - Back"
}

local mapOptions = {
  "=== AREA OPTIONS ===",
  "F1 - Add Area",
  "F2 - Select Area",
  "Ctrl + F1 - Rename Area",
  "Ctrl + Alt + F1 - Remove Area",
  --"F2 - Next Area (Ctrl:Previous)",
  "F3 - Edit NavMesh",
  "",
  "=== OBJECT OPTIONS ===",
  "F5 - Load Object From Library",
  "Ctrl + D - Duplicate",
  "DEL - Remove Object",
  "Alt + PgUp - Layer Up",
  "Alt + PgDown - Layer Down",
  "",
  "Ctrl + L - Change Layer",
  "Alt + L - Add Layer"
}

local editNavMeshOptions = {

}

local spawnPtOptions = {

}

local enemyOptions = {

}

local optionsToShow = mapOptions

class "MapEditor"

function MapEditor:MapEditor( mapListOwner, mapIndex, mapName, thegame )
  self.game    = thegame
  self.mapList = mapListOwner
  self.index   = mapIndex
  self.name    = mapName

  self.showHelp = false

  self.textInput = nil

  self.incModifier = 1

  self.layers       = {}
  self.currentLayer = 0
  self.layerCount   = 0

  self.objectNameIndex = 0

  self.map   = nil
  self.area  = nil

  self.objectSelector = ObjectSelector()

  self.updatefunction   = self.updateEditMap
  self.keypressfunction = self.keypressEditMap

  self.allobjects = {}
  self.library    = {}

  self.selectedCount = 0

  self.middleisdown = false
  self.leftisdown = false

  self.mousewasdragged = false

  self:loadMap( mapName )
end

function MapEditor:onEnter()
  print("Entered MapEditor")
end

function MapEditor:onExit()
  self.game:getCamera():setPosition( 0, 0 )
end

function MapEditor:update( dt )
  self:updatefunction( dt )
end

function MapEditor:draw()

  if ( self.showHelp ) then
    self:drawHelp()
    return
  end

  if ( self.textInput ) then
    self.textInput:draw()
    return
  end

  self.game:getCamera():set() --- camera dependent drawings

  self.game:getDrawManager():draw()

  local ww, hh

  love.graphics.setColor( 240, 240, 100, 200 )

  for i = 1, #self.allobjects do

    if ( self.allobjects[i].selected ) then

      local qd = self.allobjects[i].selbox

      love.graphics.line( qd[1] - 5, qd[2] - 5, qd[1] + qd[3] / 5, qd[2] - 5 )
      love.graphics.line( qd[1] - 5, qd[2] - 5, qd[1] - 5, qd[2] + qd[4] / 5 )

      love.graphics.line( qd[1] + qd[3] + 5, qd[2] + qd[4] + 5, qd[1] + qd[3] - qd[3] / 5, qd[2] + qd[4] + 5 )
      love.graphics.line( qd[1] + qd[3] + 5, qd[2] + qd[4] + 5, qd[1] + qd[3] + 5, qd[2] + qd[4] - qd[4] / 5 )

    end

  end

  self.game:getCamera():unset()

  love.graphics.setColor( glob.defaultColor )

  for i = 1, #generalOptions do
    love.graphics.print( generalOptions[i], 1050, (i * 16) )
  end

  for i = 1, #optionsToShow do
    love.graphics.print( optionsToShow[i], 1050, (i * 16) + 100 )
  end

  --self.objectSelector:draw()

  love.graphics.print( "Inc Modifier: " .. self.incModifier, 1050, 700 )
  self.game:getCamera():drawPosition( 1050, 680 )

  self:drawMapName()

end

function MapEditor:drawMapName()
  if ( self.map ) then

    love.graphics.print( "Map: " .. self.map:getName(), 10, 700 )

    if ( self.area ) then
      love.graphics.print( "Area: " .. self.area:getName(), 310, 700 )
    end

  end

  love.graphics.print( "Layer: " .. self.currentLayer, 610, 700 )

end

--- SELECT OBJECTS -------------------------------------------------------------

function MapEditor:selectObject( objectToSelect )

  local done = false

  local i = 1

  while not done do

    done = self.allobjects[i].object:getName() == objectToSelect:getName()

    if ( done ) then
      self.allobjects[i].selected = true

      self.selectedCount = self.selectedCount + 1
    end

    i = i + 1
  end

end

function MapEditor:objectIsSelected( object )
  local index = 0

  local sell = false

  for i = 1, #self.allobjects do

    if ( self.allobjects[i].object:getName() == object:getName() ) then
      sell = self.allobjects[i].selected

      if ( sell ) then
        index = i
      end

    end

  end

  return sell, index
end

function MapEditor:selectAll( trueToSelect, layerindex )

  self.selectedCount = 0

  for i = 1, #self.allobjects do

    if ( self.allobjects[i].layer == layerindex) then

      self.allobjects[i].selected = trueToSelect

      if ( trueToSelect ) then
        self.selectedCount = self.selectedCount + 1
      else
        self.selectedCount = self.selectedCount - 1
      end

    end

  end

end

function MapEditor:selectOnClick( cx, cy )
  local wasselected = false

  local sl = {}

  local ox, oy = self.game:getCamera():getPositionXY()

  for i = 1, #self.allobjects do

    if ( self.allobjects[i].layer == self.currentLayer ) then

      if pointInRect(
          cx + ox, cy + oy,
          self.allobjects[i].selbox[1] + ox, self.allobjects[i].selbox[2],
          self.allobjects[i].selbox[3] + oy, self.allobjects[i].selbox[4] ) then

          table.insert( sl, self.allobjects[i] )
          wasselected = true

      end

    end

  end

  if ( not Input:isKeyDown("lctrl") ) then
    self:selectAll( false, self.currentLayer )
  end

  if ( wasselected ) then

    for i = 1, #sl do
      self:selectObject( sl[i].object )
    end

  end

end

--------------------------------------------------------------------------------

function MapEditor:onKeyPress( key, scancode, isrepeat )

  if ( key == "kp+" ) then

    if ( self.incModifier == 1 ) then
      self.incModifier = 5
    else
      self.incModifier = self.incModifier + 5

      if ( self.incModifier > 50 ) then
        self.incModifier = 50
      end
    end

  end

  if ( key == "kp-" ) then

    if ( self.incModifier <= 5 ) then
      self.incModifier = 1
    else
      self.incModifier = self.incModifier - 5
    end

  end

  if ( key == "f9" ) then
    self:saveMap( self.name )

    return
  end

  self:keypressfunction( key )
end

function MapEditor:onMousePress( x, y, button, istouch )

  self.leftisdown   = button == 1
  self.middleisdown = button == 3

end

function MapEditor:onMouseRelease( x, y, button, istouch )

  if ( self.leftisdown ) and ( not self.mousewasdragged ) then
    self:selectOnClick( x, y )
  end

  if ( button == 1 ) then
    self.leftisdown   = false
  end

  if ( button == 3 ) then
    self.middleisdown = false
  end

end

function MapEditor:onMouseMove( x, y, dx, dy )

  self.mousewasdragged = false

  if ( self.leftisdown ) then
    self:moveSelected( dx, dy )

    self.mousewasdragged = true
  end

  if ( self.middleisdown ) then
    self.game:getCamera():move( -dx, -dy )

    self.mousewasdragged = true
  end

end

function MapEditor:doTextInput ( t )

  if ( self.textInput ) then
    self.textInput:input( t )
  end

end

function MapEditor:saveMap( mapFileName )
  print("TODO save")
end

function MapEditor:loadMap( mapName )

  self.map = Map( mapName )

  self:addLayer( "default" )
  self.game:getDrawManager():addLayer( "default" )

  self.currentLayer = 1
  self.layerCount   = self.game:getDrawManager():getLayerCount()

end

function MapEditor:getNextGeneratedName()
  self.objectNameIndex = self.objectNameIndex + 1

  return "obj" .. self.objectNameIndex
end

--- OBJECT MANAGEMENT ----------------------------------------------------------

function MapEditor:addObject( objectToAdd, addSelected )

  if ( addSelected == nil ) then
    addSelected = false
  end

  local vpts = objectToAdd:getPosition()

  local w, h = objectToAdd:getDimensions()

  local qd = { vpts.x, vpts.y, w, h }

  local obj = {
    object   = objectToAdd,
    layer    = self.currentLayer,
    selected = addSelected,
    selbox   = qd
  }

  if ( addSelected ) then
    self.selectedCount = self.selectedCount + 1
  end

  table.insert( self.allobjects, obj )

end

function MapEditor:replaceInAllObjects( newObject, index, isSelected )
  self.allobjects[index].object = newObject

  if ( isSelected ) then
    self.selectedCount = self.selectedCount + 1
  end

end

function MapEditor:removeObject( objectindex, layerIndex )

  if ( self.layers[layerindex].locked ) then
    return
  end

  local obj = self.allobjects[objectindex].object

  if ( obj ) then

    self.area:removeObject( obj:getName() )
    self.area:removeSpawnPoint( obj:getName() )

    self.game:getDrawManager():removeObject( obj:getName(), self.allobjects[objectindex].layer )

    table.remove( self.allobjects, objectindex )

  end

end

function MapEditor:duplicateSelectedObjects( layerindex )

  if ( self.layers[layerindex].locked ) then
    return
  end

  local oc = #self.allobjects

  for i = 1, oc do

    if ( self.allobjects[i].selected ) then

      local newname = self:getNextGeneratedName()

      local dp = self.allobjects[i].object:clone( newname )

      dp:changePosition( Vec( 40, 40) )

      index = self:addObject( dp, true )

      self:selectObject( dp )

      self.area:addObject( dp )

      self.game:getDrawManager():addObject( dp, self.currentLayer )

    end

  end -- for

end

function MapEditor:moveSelected( dx, dy )

  local c = #self.allobjects

  local v = Vec ( dx, dy )

  for i = 1, c do

    if ( self.allobjects[i].selected ) then
      self.allobjects[i].object:changePosition( v )

      self.allobjects[i].selbox[1] = self.allobjects[i].selbox[1] + dx
      self.allobjects[i].selbox[2] = self.allobjects[i].selbox[2] + dy
    end

  end

end

function MapEditor:moveObjectsToLayer( layerindex, incLayer )
  if ( #self.layers < 2 ) then
    return
  end

  if ( layerindex + incLayer == 0 ) or ( layerindex + incLayer > #self.layers ) then
    return
  end

  if ( self.layers[layerindex].locked ) then
    return
  end

  for i = 1, #self.allobjects do

    if ( self.allobjects[i].selected ) then
      self.game:getDrawManager():swapObjectLayer(
          self.allobjects[i].object:getName(),
          self.allobjects[i].layer,
          self.allobjects[i].layer + incLayer )

      self.allobjects[i].layer = self.allobjects[i].layer + incLayer
    end

  end

end

function MapEditor:moveSelectedByKeys( key )
  local xd = 0
  local yd = 0

  if ( key == "up" ) then
    yd = -1
  end

  if ( key == "down" ) then
    yd = 1
  end

  if ( key == "left" ) then
    xd = -1
  end

  if ( key == "right" ) then
    xd = 1
  end

  self:moveSelected( self.incModifier * xd, self.incModifier * yd )

end

function MapEditor:removeSelected()

  local dd = #self.allobjects

  local remindexes = {}

  for i = 1, dd do

    if ( self.allobjects[i].selected ) then
      table.insert( remindexes, { index = i, layer = self.allobjects[i].layer } )
    end

  end

  table.sort( remindexes, function(a, b) return a > b end ) -- desc

  for i = 1, #remindexes do
    self:removeObject( remindexes[i].index, remindexes[i].layer )
  end

  self:selectAll( false, self.currentLayer ) -- unnecessary?

end

--- GENERAL UPDATE AND KEYPRESS ------------------------------------------------

function MapEditor:updateEditMap( dt )

end

function MapEditor:keypressEditMap( key )

  if ( self.textInput ) then
    self.textInput:keypressed( key )
    return
  end

  --- MISC -----

  self:keypressMiscelaneous( key )

  --- AREA -----

  self:keypressForAreas( key )

  --- OBJECTS -----

  self:keypressForObjects( key )

  if ( key == "f11") then

    self:onExit()
    self.mapList:backFromEdit()
    return

  end

end

---- LAYER FUNCTIONS -----------------------------------------------------------

function MapEditor:addLayer( layerName )
  local layer = {
    name   = layerName,
    locked = false
  }

  table.insert( self.layers, layer )
end

function MapEditor:changeLayer( inc )
  inc = inc or 1

  if ( #self.layers < 2 ) then
    return
  end

  self:selectAll( false, self.currentLayer )

  self.currentLayer = self.currentLayer + inc

  if ( ( inc > 0 ) and ( self.currentLayer > #self.layers ) ) then
    self.currentLayer = 1
  end

  if ( ( inc < 0 ) and ( self.currentLayer == 0 ) ) then
    self.currentLayer = #self.layers
  end

end

function MapEditor:lockLayer( layerindex )

  self.layers[layerindex].locked = not self.layers[layerindex].locked

  self:selectAll( false, layerindex )

end

--- ADD AREA -------------------------------------------------------------------

function MapEditor:updateAddArea( dt )

  if ( self.textInput:isFinished() ) then

    local areaname = self.textInput:getText()

    if ( areaname ~= "") then

      local area = Area( areaname )

      self.map:addArea( area )

      print( "Area Added '" .. areaname .. "' " )

      self.area = area

      self.updatefunction = self.updateEditMap
      self.keypressfunction = self.keypressEditMap
    end

    self.textInput = nil

  end

end

function MapEditor:keypressAddArea( key )
  self.textInput:keypressed( key )
end

---- RENAME AREA ---------------------------------------------------------------

function MapEditor:updateRenameArea( dt )
  --//TODO


  self.updatefunction   = self.updateEditMap
  self.keypressfunction = self.keypressEditMap
end

function MapEditor:keypressRenameArea( key )
  --//TODO
end

--- EDIT AREA -----------------------------------------------------------------

function MapEditor:keypressMiscelaneous( key )

  if ( key == "/" ) then
    self.showHelp = not self.showHelp
  end

  if ( ( key == "]" ) and ( Input:isKeyDown( "lctrl" ) ) ) then
    self:lockLayer( self.currentLayer )
  end

  if ( ( key == "]" ) and ( Input:isKeyDown( "lshift" ) ) ) then
    self.game:getDrawManager():toogleLayerVisible( self.currentLayer )
  end

  if ( (key == "l")  and ( Input:isKeyDown( "lctrl" ) ) ) then
    self:changeLayer()
  end

  if ( (key == "l")  and ( Input:isKeyDown( "lalt" ) ) ) then
    self.textInput        = TextInput( "Layer Name:" )
    self.updatefunction   = self.updateCreateLayer
    self.keypressfunction = self.keypressCreateLayer
  end

end

function MapEditor:keypressForAreas( key )

  if ( key == "f1" ) then
    self.textInput        = TextInput( "Area Name:" )
    self.updatefunction   = self.updateAddArea
    self.keypressfunction = self.keypressAddArea
  end

  if ( key == "f2" ) then
    --//TODO select Area
    --self.textInput        = TextInput( "Area Name:" )
    --self.updatefunction   = self.updateAddArea
    --self.keypressfunction = self.keypressAddArea
  end

  if ( ( key == "f1" ) and ( Input:isKeyDown( "lctrl" ) ) ) then

    self.textInput        = TextInput( "Area Name: ", self.area.getName() )

    self.updatefunction   = self.updateRenameArea
    self.keypressfunction = self.keypressRenameArea

  end

  if ( ( key == "f1" ) and ( Input:isKeyDown( "lctrl" ) ) and ( Input:isKeyDown( "lalt" ) ) ) then
    --//TODO remove current area
    print("Not implemented")
  end

  if ( key == "f3" ) then
    self:selectAll( false, self.currentLayer )
    --//TODO edit navmesh
    --optionsToShow = editNavMeshOptions

    --self.updatefunction   = self.updateNavMesh
    --self.keypressfunction = self.keypressNavMesh
  end

end

function MapEditor:keypressForObjects( key )
  if ( self.area == nil) then
    return
  end

  if ( ( key == "a" )  and ( Input:isKeyDown( "lctrl" ) )  ) then

    if ( self.selectedCount > 0 ) then
      self:selectAll( false, self.currentLayer )
    else
      self:selectAll( true, self.currentLayer )
    end

  end

  if ( key == "f5" ) then
    self.textInput        = TextInput("Object Name:")
    self.updatefunction   = self.updateSelectFromLibrary
    self.keypressfunction = self.keypressSelectFromLibrary
  end

  if ( (key == "d")  and ( Input:isKeyDown( "lctrl" ) ) ) then
    self:duplicateSelectedObjects( self.currentLayer )
  end

  if ( ( key == "pagedown" )  and ( Input:isKeyDown( "lalt" ) )  ) then
    self:moveObjectsToLayer( self.currentLayer, -1 )
  end

  if ( ( key == "pageup" )  and ( Input:isKeyDown( "lalt" ) )  ) then
    self:moveObjectsToLayer( self.currentLayer, 1 )
  end

  if ( key == "delete" ) then
    self:removeSelected()
  end

  if ( key == "up" or key == "down" or key == "left" or key == "right" ) then
    self:moveSelectedByKeys( key )
  end

end

--- ADD OBJECT FROM LIBRARY ----------------------------------------------------

function MapEditor:updateSelectFromLibrary( dt )
  if ( self.textInput:isFinished() ) then

    local objectname = self.textInput:getText()

    local object = nil

    local px, py = Input.mousePosition()

    local cx, cy = self.game:getCamera():getPositionXY()

    local instancename =  self:getNextGeneratedName()

    if ( self.library[objectname] ) then

      object = self.library[objectname]:clone( instancename )

      object:setPosition( Vec( px + cx, py + cy ) )

    else

      object = self.game:getObjectManager():loadObject( objectname, instancename, px + cx, py + cy )

      self.library[objectname] = object

    end

    if ( object ) then

      self.area:addObject( object )

      self.game:getDrawManager():addObject( object, self.currentLayer )

      self:addObject( object, "object", true )

    end

    self.textInput = nil

    self.updatefunction = self.updateEditMap
    self.keypressfunction = self.keypressEditMap
  end
end

function MapEditor:keypressSelectFromLibrary( key )
  self.textInput:keypressed( key )
end

--- CREATE LAYER ---------------------------------------------------------------

function MapEditor:updateCreateLayer( dt )
  if ( self.textInput:isFinished() ) then

    local layername = self.textInput:getText()

    self.game:getDrawManager():addLayer( layername )

    self:addLayer( layername )

    self.textInput = nil

    self.updatefunction = self.updateEditMap
    self.keypressfunction = self.keypressEditMap

  end
end

function MapEditor:keypressCreateLayer( key )
  self.textInput:keypressed( key )
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function MapEditor:drawHelp()
  --draws all editor commands and shortcuts
  --//TODO allways update

  local column1 = {
    "? - Help/Command List",
    "Numpad '+/-' - Change Inc Modifier",
    "F9 - Save",
    "F11 - Back"
  }

  local column2 = {
    "F1 - Add Area",
    "F2 - Select Area",
    "Ctrl + F1 - Rename Area",
    "Ctrl + Alt + F1 - Remove Area",
    "F3 - Edit NavMesh",
    "",
    "F5 - Load Object From Library",
    "Ctrl + D - Duplicate",
    "DEL - Remove Object",
    "Alt + PgUp - Layer Up",
    "Alt + PgDown - Layer Down",
    "Ctrl + L - Change Layer",
    "Alt + L - Add Layer"
  }

  for i = 1, #column1 do
    love.graphics.print( column1[i], 10, (i * 16) )
  end

  for i = 1, #column2 do
    love.graphics.print( column2[i], 300, (i * 16) )
  end

end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
