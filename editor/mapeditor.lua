--[[

the engine map editor

]]

require("..engine.lclass")
require("..engine.input")
require("..engine.ui.uigroup")
require("..engine.ui.button.button")
require("..engine.screen.screen")
require("..engine.gameobject.gameobject")
require("..engine.gameobject.staticimage")
require("..engine.gameobject.simpleobject")
require("..engine.gameobject.movingobject")
require("..engine.light.light")
require("..engine.map.map")
require("..engine.map.area")
require("..engine.map.spawnpoint")
require("..engine.collision.collision")
require("..engine.navigation.navmesh")
require("..engine.navigation.navmap")
require("..engine.utl.funcs")

local Vec = require("..engine.math.vector")

local absfun   = math.abs
local ceilfun  = math.ceil
local floorfun = math.ceil

local generalOptions = {
  "/ - Help/Command List",
  "Numpad '+/-' - Change Inc Modifier",
  "F9 - Save",
  "F11 - Back",
  "",
  "Alt + M - Set Music"
}

local mapOptions = {
  "=== AREA OPTIONS ===",
  "F1 - Add Area",
  "F2 - Next Area (Ctrl:Previous)",
  "Ctrl + F1 - Rename Area",
  "Ctrl + Alt + F1 - Remove Area",
  "F3 - Edit NavMesh",
  "",
  "=== OBJECT OPTIONS ===",
  "F5 - Load Object From Library",
  "Ctrl + D - Duplicate",
  "Ctrl + N - Rename",
  "Ctrl + B - Change Solid Collider",
  "Ctrl + J - Set Script",
  "DEL - Remove Object",
  "Alt + PgUp - Layer Up",
  "Alt + PgDown - Layer Down",
  "",
  "Ctrl + L - Change Layer",
  "Alt + L - Add Layer"
}

local editNavMeshOptions = {
  "F3 - Back",
  "Left Click: Add Point",
  "Right Click: Remove Point",
  "Drag Left - Move Point"
}

local enemyOptions = {

}

local optionsToShow = mapOptions

class "MapEditor"

function MapEditor:MapEditor( mapListOwner, mapIndex, mapName, mapFile, thegame )
  self.game     = thegame
  self.mapList  = mapListOwner
  self.index    = mapIndex
  self.mapname  = mapName
  self.filename = mapFile

  self.showHelp    = false
  self.lastMessage = ""

  self.textInput = nil

  self.incModifier = 1

  self.layers       = {}
  self.currentLayer = 0
  self.layerCount   = 0

  self.objectNameIndex = 0

  self.map   = nil
  self.area  = nil

  self.areaindex = 0

  self.navmesh = nil

  self.navpoints     = {}
  self.navinsets     = {}
  self.navindexclick = 0

  self.editNavMesh = false

  self.updatefunction   = self.updateEditMap
  self.keypressfunction = self.keypressEditMap

  self.allobjects = {}

  self.selectedCount = 0

  self.leftisdown   = false
  self.middleisdown = false
  self.rightisdown  = false

  self.dragthreshold = { x = 0, y = 0 }

  self.musicdata = {}

  self.mousewasdragged = false

  self.game:getDrawManager():clear()

  self:loadMap( mapName, mapFile )
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

  self:drawNavMesh()

  self:drawGrid()

  self.game:getCamera():unset()

  love.graphics.setColor( colors.WHITE )

  for i = 1, #generalOptions do
    love.graphics.print( generalOptions[i], 1050, (i * 16) )
  end

  for i = 1, #optionsToShow do
    love.graphics.print( optionsToShow[i], 1050, (i * 16) + 100 )
  end

  love.graphics.print( "Inc Modifier: " .. self.incModifier, 1050, 700 )
  self.game:getCamera():drawPosition( 1050, 680 )

  self:drawMapName()

  self:drawLastMessage()

end

function MapEditor:drawMapName()
  if ( self.map ) then

    love.graphics.print( "Map: " .. self.map:getName(), 10, 680 )

    if ( self.area ) then
      love.graphics.print( "Area: " .. self.area:getName(), 310, 680 )
    end

  end

  love.graphics.print( "Layer: " .. self.currentLayer, 610, 680 )

end

function MapEditor:selectArea( inc )
  self.areaindex = self.areaindex + inc

  if ( self.areaindex > self.map:getAreaCount() ) then
    self.areaindex = 1
  end

  if ( self.areaindex == 0 ) then
    self.areaindex = self.map:getAreaCount()
  end

  if ( self.map:getAreaCount() > 0 ) then

    self.area = self.map:getAreaByIndex( self.areaindex )

    local nm = self.area:getNavMesh()

    if ( nm ) then
      self.navmesh = nm

      self:getNavMeshToNavPoints()
    end

  end

end

--- SELECT OBJECTS -------------------------------------------------------------

function MapEditor:selectObject( objectToSelect )

  local done = false

  local i = 1

  while not done do

    done = self.allobjects[i].object:getInstanceName() == objectToSelect:getInstanceName()

    if ( done ) then
      self.allobjects[i].selected = not self.allobjects[i].selected

      if ( self.allobjects[i].selected ) then
        self.selectedCount = self.selectedCount + 1
      else
        self.selectedCount = self.selectedCount - 1
      end
    end

    i = i + 1
  end

end

function MapEditor:objectIsSelected( object )
  local index = 0

  local sell = false

  for i = 1, #self.allobjects do

    if ( self.allobjects[i].object:getInstanceName() == object:getInstanceName() ) then
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

    if ( self.allobjects[i].layer == layerindex ) then

      self.allobjects[i].selected = trueToSelect

      if ( trueToSelect ) then
        self.selectedCount = self.selectedCount + 1
      else
        self.selectedCount = self.selectedCount - 1
      end

    end

  end

  if ( not trueToSelect )  then
    self.selectedCount = 0
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
          self.allobjects[i].selbox[1], self.allobjects[i].selbox[2],
          self.allobjects[i].selbox[3], self.allobjects[i].selbox[4] ) then

          table.insert( sl, self.allobjects[i] )
          wasselected = true

      end

    end

  end -- for

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

  if ( key == "kp+" or key == "kp-") then
    self:changeIncModifier( key )
  end

  if ( key == "f9" ) then
    self:saveMap( )

    return
  end

  self:keypressfunction( key )
end

function MapEditor:onMousePress( x, y, button, istouch )

  local cx, cy = self.game:getCamera():getPositionXY()

  self.leftisdown   = button == 1
  self.rightisdown  = button == 2
  self.middleisdown = button == 3

  if ( self.editNavMesh ) and ( #self.navinsets > 0 ) then

    for i = 1, #self.navinsets do

      local ptx = self.navinsets[i]

      if ( pointInRect( x + cx, y + cy, ptx[1], ptx[2], ptx[3], ptx[4] ) ) then
        self.navindexclick = i
      end

    end
  end

end

function MapEditor:onMouseRelease( x, y, button, istouch )

  if ( not self.mousewasdragged ) then

    if ( self.editNavMesh ) then
      self:mouseClickNavMesh( button, x, y )
    elseif ( self.leftisdown ) then
      self:selectOnClick( x, y )
    end

  end

  self.navindexclick = 0

  if ( button == 1 ) then
    self.leftisdown = false
  end

  if ( button == 2 ) then
    self.rightisdown = false
  end

  if ( button == 3 ) then
    self.middleisdown = false
  end

end

function MapEditor:onMouseMove( x, y, dx, dy )

  self.mousewasdragged = false

  if ( self.editNavMesh ) then
    self:mouseMovedNavMesh( x, y, dx, dy )

    if ( self.leftisdown ) then
      self.mousewasdragged = true
    end
  else

    if ( self.leftisdown ) then
      self:moveSelected( dx, dy )

      self.mousewasdragged = true
    end

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

function MapEditor:saveMap()
  if ( self.musicdata.resname ) then
    self.map:setBackgroundMusicResource( self.musicdata.resname, self.musicdata.volume )
  end

  self.game:getMapManager():saveMap( self.mapname, self.filename, self.map )
end

function MapEditor:loadMap()

  self.map = self.game:getMapManager():loadMap( self.mapname, self.filename )

  if ( self.map ) then

    local lls = self.map:getLayers()

    for i = 1, #lls do
      self:addLayer( lls[i].name )
      self.game:getDrawManager():addLayer( lls[i].name )
    end

    self.game:getDrawManager():getObjectsFromMap( self.map )

    self:getMapObjectsIntoAllObjects()

  else

    self.map = Map( self.mapname, self.filename )

    self.map:addLayer( "default", 1 )
    self.game:getDrawManager():addLayer( "default" )
    self:addLayer( "default" )

  end

  self:selectArea( 0 )

  self.currentLayer = 1
  self.layerCount   = self.map:getLayerCount()

end

function MapEditor:getMapObjectsIntoAllObjects()
  local areas = self.map:getAreas()

  for _,aa in pairs( areas ) do
    local objects = aa:getObjects()

    for _,oo in pairs( objects ) do
      self:addObject( oo, false, oo:getLayer() )
    end

    for _,ss in pairs( aa:getSpawnPoints() ) do
      self:addObject( ss, false, ss:getLayer() )
    end
  end

end

--- OBJECT MANAGEMENT ----------------------------------------------------------

function MapEditor:addObject( objectToAdd, addSelected, addToLayer )

  addToLayer = addToLayer or self.currentLayer

  if ( addSelected == nil ) then
    addSelected = false
  end

  local vpts = objectToAdd:getPosition()

  local w, h = objectToAdd:getDimensions()

  local qd = { vpts.x, vpts.y, w, h }

  local obj = {
    object   = objectToAdd,
    layer    = addToLayer,
    selected = addSelected,
    selbox   = qd
  }

  --objectToAdd:setLayer( addToLayer )

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

function MapEditor:removeObject( objectindex, layerindex )

  if ( self.layers[layerindex].locked ) then
    return
  end

  local obj = self.allobjects[objectindex].object

  if ( obj ) then
    self.area:removeObject( obj:getInstanceName() )
    self.area:removeSpawnPoint( obj:getInstanceName() )

    self.game:getDrawManager():removeObject( obj:getInstanceName(), self.allobjects[objectindex].layer )
    self.game:getDrawManager():removeSpawnPoint( obj:getInstanceName(), self.allobjects[objectindex].layer )

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

      local instancename = self.map:getNextGeneratedName()

      local dp = self.allobjects[i].object:clone( self.allobjects[i].object:getName(), instancename )

      if ( self.incModifier > 4 ) then
        dp:changePosition( Vec( self.incModifier, self.incModifier ) )
      else
        dp:changePosition( Vec( 40, 40 ) )
      end

      dp:setLayer( self.currentLayer )

      index = self:addObject( dp, true )

      self:selectObject( dp )

      self.area:addObject( dp )

      self.game:getDrawManager():addObject( dp, self.currentLayer )

    end

  end -- for

end

function MapEditor:changeSolidCollider()
  local oc = #self.allobjects

  for i = 1, oc do

    if ( self.allobjects[i].selected ) then

      local coll = self.allobjects[i].object:getCollider()

      if ( coll ) then
        coll:setSolid( not coll:isSolid() )
      end

    end

  end
end

function MapEditor:moveSelected( dx, dy, forceApply )

  if ( forceApply == nil ) then
    forceApply = true
  end

  local willapply = false

  local v = Vec ( dx, dy )

  if ( ( self.incModifier == 1 ) or ( forceApply == true ) ) then
    willapply = true
  else
    self.dragthreshold.x = self.dragthreshold.x + dx
    self.dragthreshold.y = self.dragthreshold.y + dy

    if ( absfun( self.dragthreshold.x ) > self.incModifier ) then
      if ( self.dragthreshold.x < 0 ) then
        v.x = -self.incModifier
      else
        v.x = self.incModifier
      end

      self.dragthreshold.x = 0

      willapply = true
    end

    if ( absfun( self.dragthreshold.y )  > self.incModifier ) then
      if ( self.dragthreshold.y < 0 ) then
        v.y = -self.incModifier
      else
        v.y = self.incModifier
      end

      self.dragthreshold.y = 0

      willapply = true
    end

  end

  if ( willapply ) then

    local c = #self.allobjects

    for i = 1, c do

      if ( self.allobjects[i].selected ) then
        self.allobjects[i].object:changePosition( v )

        self.allobjects[i].selbox[1] = self.allobjects[i].selbox[1] + v.x
        self.allobjects[i].selbox[2] = self.allobjects[i].selbox[2] + v.y
      end

    end -- for

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
      if ( self.allobjects[i].layer + incLayer > 0 and self.allobjects[i].layer + incLayer <= #self.layers ) then
        self.game:getDrawManager():swapObjectLayer(
            self.allobjects[i].object:getInstanceName(),
            self.allobjects[i].layer,
            self.allobjects[i].layer + incLayer )

        self.allobjects[i].layer = self.allobjects[i].layer + incLayer
        self.allobjects[i].object:setLayer( self.allobjects[i].layer )

        self.allobjects[i].selected = false
        self.selectedCount = self.selectedCount - 1
      end
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

  self:moveSelected( self.incModifier * xd, self.incModifier * yd, true )

end

function MapEditor:removeSelected()

  local dd = #self.allobjects

  local remindexes = {}

  for i = 1, dd do

    if ( self.allobjects[i].selected ) then
      table.insert( remindexes, { index = i, layer = self.allobjects[i].layer } )
    end

  end

  table.sort( remindexes, function(a, b) return a.index > b.index end ) -- desc

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

function MapEditor:changeIncModifier( key )
  if ( key == "kp+" ) then

    if ( self.incModifier == 1 ) then
      self.incModifier = 4
    else
      self.incModifier = self.incModifier * 2

      if ( self.incModifier > 512 ) then
        self.incModifier = 1
      end
    end

  end

  if ( key == "kp-" ) then

    if ( self.incModifier == 1 ) then
      self.incModifier = 512
    elseif ( self.incModifier == 4 ) then
      self.incModifier = 1
    else
      self.incModifier = self.incModifier / 2
    end

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

      self:setLastMessage("Area Added '" .. areaname .. "' ")

      self.area = area

      if ( self.areaindex == 0 ) then
        self.areaindex = 1
      end

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

  if ( key == ";" ) then --//TODO fix zoom
    self.game:getCamera():setScale( 0.1 , 0.1 )
  end

  if ( ( key == "k" ) and ( Input:isKeyDown( "lctrl" ) ) ) then
    self:lockLayer( self.currentLayer )
  end

  if ( ( key == "j" ) and ( Input:isKeyDown( "lctrl" ) ) ) then
    self.textInput        = TextInput( "Script Name:" )
    self.updatefunction   = self.updateSetScript
    self.keypressfunction = self.keypressSetScript
  end

  if ( ( key == "n" ) and ( Input:isKeyDown( "lctrl" ) ) ) then
    if ( self.selectedCount > 0 ) then
      local index = 0

      local i = 1

      while ( index == 0 ) do
        if ( self.allobjects[i].selected ) then
          index = i
        end

        i = i + 1
      end

      self.textInput = TextInput("New Name: ", self.allobjects[index].object:getInstanceName() )

      self.updatefunction   = self.updateRenameObject
      self.keypressfunction = self.keypressRenameObject
    end
  end

  if ( ( key == "i" ) and ( Input:isKeyDown( "lctrl" ) ) ) then
    local enabled = self.map:getCollisionEnabledForLayer( self.currentLayer )
    self.map:enableCollisionForLayer( self.currentLayer, not enabled )
    self:setLastMessage( "Layer Collision Set To " .. tostring( not enabled ) )
  end

  if ( ( key == "h" ) and ( Input:isKeyDown( "lshift" ) ) ) then
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

  if ( (key == "m")  and ( Input:isKeyDown( "lalt" ) ) ) then
    self.textInput        = TextInput( "Music Resource Name:" )
    self.updatefunction   = self.updateSetMusic
    self.keypressfunction = self.keypressSetMusic
  end

  if ( (key == "m")  and ( Input:isKeyDown( "lalt" ) ) and ( Input:isKeyDown( "lshift" ) ) ) then
    self.textInput        = TextInput( "Music Volume:" )
    self.updatefunction   = self.updateSetMusicVolume
    self.keypressfunction = self.keypressSetMusicVolume
  end

  if ( (key == "p")  and ( Input:isKeyDown( "lctrl" ) ) ) then
    self:createSpawnPoint()
  end

end

function MapEditor:keypressForAreas( key )

  if ( key == "f1" ) then
    self.textInput        = TextInput( "Area Name:" )
    self.updatefunction   = self.updateAddArea
    self.keypressfunction = self.keypressAddArea
  end

  if ( key == "f2" ) then
    if ( Input:isKeyDown( "lctrl" ) ) then
      self:selectArea( -1 )
    else
      self:selectArea( 1 )
    end
  end

  if ( ( key == "f1" ) and ( Input:isKeyDown( "lctrl" ) ) ) then

    self.textInput        = TextInput( "Area Name: ", self.area:getName() )

    self.updatefunction   = self.updateRenameArea
    self.keypressfunction = self.keypressRenameArea

  end

  if ( ( key == "f1" ) and ( Input:isKeyDown( "lctrl" ) ) and ( Input:isKeyDown( "lalt" ) ) ) then
    --//TODO remove current area
    self:setLastMessage("Ctrl+Alt+F1 ( Remove Current Area ) Not implemented")
  end

  if ( key == "f3" ) and ( self.editNavMesh == false ) then

    self:selectAll( false, self.currentLayer )

    optionsToShow = editNavMeshOptions

    self:getNavMeshToNavPoints()

    self.editNavMesh = true

    self.updatefunction   = self.updateNavMesh
    self.keypressfunction = self.keypressNavMesh

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

  if ( (key == "b")  and ( Input:isKeyDown( "lctrl" ) ) ) then
    self:changeSolidCollider( self.currentLayer )
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

    local lx, ly = px + cx, py + cy

    if ( self.incModifier > 1 ) then
      lx = floorfun( lx / self.incModifier ) * self.incModifier - self.incModifier
      ly = floorfun( ly / self.incModifier ) * self.incModifier - self.incModifier
    end

    local instancename =  self.map:getNextGeneratedName()

    local fromLibrary = self.map:getObjectFromLibrary ( objectname )

    if ( fromLibrary ) then
      object = fromLibrary:clone( objectname, instancename )

      object:setLayer( self.currentLayer )
    else
      tolibrary = self.game:getObjectManager():loadObject( objectname, instancename, lx, ly )

      if ( tolibrary ) then
        self.map:addToLibrary( objectname, tolibrary )

        instancename =  self.map:getNextGeneratedName()

        object = tolibrary:clone( objectname, instancename )

        object:setLayer( self.currentLayer )
      else
        self:setLastMessage( "Object not found: " .. objectname )
      end
    end

    if ( object ) then
      object:setPosition( Vec( lx, ly ) )

      self.area:addObject( object )

      self.game:getDrawManager():addObject( object, self.currentLayer )

      self:addObject( object, true )
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

    self.map:addLayer( layername, self.map:getLayerCount() + 1 )
    self.game:getDrawManager():addLayer( layername )

    self:addLayer( layername )

    self.textInput = nil

    self.updatefunction   = self.updateEditMap
    self.keypressfunction = self.keypressEditMap

  end
end

function MapEditor:keypressCreateLayer( key )
  self.textInput:keypressed( key )
end

--- RENAME OBJECT --------------------------------------------------------------

function MapEditor:renameSelectedObjects( newname )
  --//TODO check if name already exists

  local counter = 1

  for i = 1, #self.allobjects do
    if ( self.allobjects[i].selected ) then

      print("Renaming: " .. self.allobjects[i].object:getInstanceName())

      if ( self.selectedCount == 1 ) then
        self.allobjects[i].object:setInstanceName( newname )
      else
        self.allobjects[i].object:setInstanceName( newname ..tostring( counter ) )

        counter = counter + 1
      end

    end
  end

end

function MapEditor:updateRenameObject( dt )
  if ( self.textInput:isFinished() ) then

    local newname = self.textInput:getText()

    self:renameSelectedObjects( newname )

    self.textInput = nil

    self.updatefunction   = self.updateEditMap
    self.keypressfunction = self.keypressEditMap

  end
end

function MapEditor:keypressRenameObject( key )
  self.textInput:keypressed( key )
end

--- SET SCRIPT -----------------------------------------------------------------

function MapEditor:setScriptForSelectedObjects( scriptname )

  for i = 1, #self.allobjects do
    if ( self.allobjects[i].selected ) then
      self.allobjects[i].object:setScript( scriptname, "" )
    end
  end

end

function MapEditor:updateSetScript( dt )
  if ( self.textInput:isFinished() ) then

    local scriptname = self.textInput:getText()

    self:setScriptForSelectedObjects( scriptname )

    self.textInput = nil

    self.updatefunction   = self.updateEditMap
    self.keypressfunction = self.keypressEditMap

  end
end

function MapEditor:keypressSetScript( key )
  self.textInput:keypressed( key )
end

--- CREATE SPAWN POINT ---------------------------------------------------------

function MapEditor:createSpawnPoint( )
    local spawnname =  self.map:getNextGeneratedName()

    local px, py = Input.mousePosition()

    local cx, cy = self.game:getCamera():getPositionXY()

    local spawn = SpawnPoint( spawnname, px + cx, py + cy )

    spawn:setLayer( self.currentLayer )

    self:addObject( spawn, true )

    self.area:addSpawnPoint( spawn )

    self.game:getDrawManager():addSpawnPoint( spawn )

    self.updatefunction = self.updateEditMap
    self.keypressfunction = self.keypressEditMap
end

----- NAV MESH -----------------------------------------------------------------

function MapEditor:getNavMeshToNavPoints()

  self.navpoints = {}
  self.navinsets = {}

  if ( self.area:getNavMesh() ) then
    self.navmesh = self.area:getNavMesh()
  else
    self.navmesh = NavMesh()
  end

  local points = self.navmesh:getPoints()

   if ( #points > 0 ) then

     for i = 1, #points do
       local point = { points[i][1], points[i][2] }

       local inset = { points[i][1] - 4, points[i][2] - 4, 8, 8 }

       table.insert( self.navpoints, point )
       table.insert( self.navinsets, inset )
     end

   end
end

function MapEditor:drawNavMesh()

  if ( self.navmesh ) then
    self.navmesh:draw()
  end

  for i=1, #self.navinsets do
    local inx = self.navinsets[i]

    love.graphics.rectangle( "line", inx[1], inx[2], inx[3], inx[4] )
  end

end

function MapEditor:drawGrid()

  if ( self.incModifier < 4 ) then
    return
  end

  --//TODO draw a simpler grid (according to camera position)
  --local sw, sh = love.graphics.getDimensions()

  --local cx, cy = self.game:getCamera():getPositionXY()

  --local sx, sy = sw / 2 + cx, sh / 2 + cy

  love.graphics.setColor( 0, 255, 0, 40 )

  local hi = floorfun ( 10000 / self.incModifier ) * self.incModifier
  local lo = - hi

  for i = lo, hi, self.incModifier do
    love.graphics.line( i, -10000, i, 10000 )
    love.graphics.line( -10000, i, 10000, i )
  end

  love.graphics.setColor( colors.WHITE )
end

function MapEditor:updateNavMesh( dt )

end

function MapEditor:keypressNavMesh( key )

  if ( key == "f3" ) then
    optionsToShow = mapOptions

    self.editNavMesh = false

    self.area:setNavMesh( self.navmesh )

    self.updatefunction = self.updateEditMap
    self.keypressfunction = self.keypressEditMap
  end

end

function MapEditor:mouseClickNavMesh( button, x, y )
  local cx, cy = self.game:getCamera():getPositionXY()

  if ( button == 1 ) then
    local point = { x + cx, y + cy }

    local inset = { x + cx - 4, y + cy - 4, 8, 8 }

    if ( #self.navpoints > 1 ) then

      local isbetween = false
      local pointindex = #self.navpoints + 1

      for i = 1, #self.navpoints - 1 do
        local ptA = self.navpoints[i]
        local ptB = self.navpoints[i + 1]

        if ( not isbetween ) then

          if ( pointBetweenLines( point[1], point[2], ptA[1], ptA[2], ptB[1], ptB[2] ) ) then
            pointindex = i + 1
            isbetween  = true
          end

        end

      end

      local ptA = self.navpoints[1]
      local ptB = self.navpoints[#self.navpoints]

      if ( pointBetweenLines( point[1], point[2], ptA[1], ptA[2], ptB[1], ptB[2] ) ) then
        pointindex = 1
        isbetween  = true
      end

      table.insert( self.navpoints, pointindex, point )
      table.insert( self.navinsets, pointindex, inset )

      if ( isbetween ) then -- overkill, but simpler
        self.navmesh:clear()

        self.navmesh:addAllPoints( self.navpoints )
      else
        self.navmesh:addPoint( point[1], point[2] )
      end

    else
      table.insert( self.navpoints, point )
      table.insert( self.navinsets, inset )

      self.navmesh:addPoint( point[1], point[2] )
    end

  end

  if ( button == 2 ) then
    table.remove( self.navpoints, self.navindexclick )
    table.remove( self.navinsets, self.navindexclick )

    self.navmesh:clear()
    self.navmesh:addAllPoints( self.navpoints )
  end

end

function MapEditor:mouseMovedNavMesh( x, y, dx, dy )

  if ( self.leftisdown ) then

    if ( self.navindexclick > 0 ) then
      self.navpoints[self.navindexclick][1] = self.navpoints[self.navindexclick][1] + dx
      self.navpoints[self.navindexclick][2] = self.navpoints[self.navindexclick][2] + dy

      self.navinsets[self.navindexclick][1] = self.navinsets[self.navindexclick][1] + dx
      self.navinsets[self.navindexclick][2] = self.navinsets[self.navindexclick][2] + dy

      self.navmesh:clear()
      self.navmesh:addAllPoints( self.navpoints )
    end

  end

end

--- SET MUSIC ------------------------------------------------------------------

function MapEditor:updateSetMusic( dt )
  if ( self.textInput:isFinished() ) then

    local str = self.textInput:getText()

    local resname, restype, respath = self.game:getResourceManager():getResourceByName( str )

    if ( restype == "audio" ) then
      if ( resname ) then
        self.musicdata.resname = resname
        self.musicdata.volume  = 1
      end
    else
      self:setLastMessage("Resource is not Audio")
    end

    self.textInput = nil

    self.updatefunction   = self.updateEditMap
    self.keypressfunction = self.keypressEditMap

  end
end

function MapEditor:keypressSetMusic( key )
  self.textInput:keypressed( key )
end

--- SET MUSIC VOLUME -----------------------------------------------------------

function MapEditor:updateSetMusicVolume( dt )
  if ( self.textInput:isFinished() ) then

    local str = self.textInput:getText()

    if ( self.musicdata.resname ) then
      self.musicdata.volume  = tonumber( str )
    end

    self.textInput = nil

    self.updatefunction   = self.updateEditMap
    self.keypressfunction = self.keypressEditMap

  end
end

function MapEditor:keypressSetMusicVolume( key )
  self.textInput:keypressed( key )
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function MapEditor:setLastMessage( str )
  self.lastMessage = str
  print( self.lastMessage )
end

function MapEditor:drawLastMessage()
  love.graphics.setColor( 225, 175, 255, 255 )
  love.graphics.print( "# # " .. self.lastMessage .. " # #", 10, 700 )
  love.graphics.setColor( colors.WHITE )
end

function MapEditor:drawHelp()
  --draws all editor commands and shortcuts
  --//TODO allways update

  local column1 = {
    "/ - Help/Command List",
    "Numpad '+/-' - Change Inc Modifier",
    "F9 - Save",
    "F11 - Back",
    "",
    "Alt + M - Set Music",
    "",
    "F12 - Developer Options Shortcuts"
  }

  local column2 = {
    "F1 - Add Area",
    "F2 - Select Next Area (Ctrl:Previous)",
    "Ctrl + F1 - Rename Area ** ",
    "Ctrl + Alt + F1 - Remove Area ** ",
    "F3 - Edit NavMesh",
    "",
    "F5 - Load Object From Library",
    "Ctrl + A - Select All",
    "Ctrl + D - Duplicate",
    "Ctrl + N - Rename",
    "Ctrl + B - Change Solid Collider",
    "Ctrl + J - Set Script",
    "DEL - Remove Object",
    "Alt + PgDown - Change To Layer Below",
    "Alt + PgUp - Change To Layer Above",
    "",
    "Ctrl + P - Create Spawn Point"
  }

  column3 = {
    "Alt + L - Add Layer",
    "Ctrl + L - Change Active Layer",
    "Ctrl + I - Enable/Disable Collision for Layer",
    "Ctrl + I - Change Layer Visibility",
    "Ctrl + K - Lock/Unlock Layer",
    "Shift + H - Hide/Show Layer",
    "Alt + PgUp - Object Layer Up",
    "Alt + PgDown - Object Layer Down",
  }

  for i = 1, #column1 do
    love.graphics.print( column1[i], 10, (i * 16) )
  end

  for i = 1, #column2 do
    love.graphics.print( column2[i], 300, (i * 16) )
  end

  for i = 1, #column3 do
    love.graphics.print( column3[i], 600, (i * 16) )
  end

end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
