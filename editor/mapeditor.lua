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
require("../engine/gameobject/ground")
require("../engine/light/light")
require("../engine/map/map")
require("../engine/map/area")
require("../engine/map/floor")
require("../engine/map/spawnpoint")
require("../engine/collision/collision")
require("../engine/navigation/navmesh")
require("../engine/navigation/navmap")
require("../engine/utl/funcs")

require("../editor/objectselector")

local Vec = require("../engine.math.vector")

local generalOptions = {
  "Numpad '+/-' - Change Inc Modifier",
  --"F8 - Toogle View All/View Quad",
  "F9 - Save",
  "F11 - Back"
}

local mapOptions = {
  "F1 - Add Floor",
  "F2 - Edit Floor",
  "",
  "CTRL + F1 - Delete Floor"

}

local floorOptions = {
  "F1 - Add Area",
  "F2 - Edit Area",
  "",
  "CTRL + F1 - Delete Area"
}

local areaOptions = {
  "F1 - Edit Objects",
  "F2 - Edit NavMesh"
}

local objectsOptions = {
  "F1 - Select Object",
  "Ctrl+D - Duplicate",
  "F4 - Load Object from Library",
  "DEL - Remove Object"
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

  self.textInput = nil

  self.incModifier = 1

  self.objectNameIndex = 0

  self.map   = nil
  self.floor = nil
  self.area  = nil

  self.objectSelector = ObjectSelector()

  self.updatefunction   = self.updategeneral
  self.keypressfunction = self.keypressgeneral

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
  
end

function MapEditor:update( dt )
  self:updatefunction( dt )
end

function MapEditor:draw()

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

  love.graphics.print( "Inc Modifier: " .. self.incModifier, 1000, 700 )

  self.game:getCamera():drawPosition( 1000, 680 )
end

--- SELECT OBJECTS -------------------------------------------------------------

function MapEditor:selectObject( objectToSelect )
  --local vpts = object:getPosition()

  --local w, h = object:getDimensions()

  --local qd = { vpts.x, vpts.y, w, h, index }

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

function MapEditor:unselectObject( object )
  local selected, index  = self:objectIsSelected( object )

  if ( index > 0 ) then

    self.allobjects[index].selected = false

    self.selectedCount = self.selectedCount - 1

  end

end

function MapEditor:selectAll( trueToSelect )

  for i = 1, #self.allobjects do

    self.allobjects[i].selected = trueToSelect

  end

  if ( trueToSelect ) then
    self.selectedCount = #self.allobjects
  else
    self.selectedCount = 0
  end

end

function MapEditor:selectOnClick( cx, cy )
  local wasselected = false

  local sl = {}

  local ox, oy = self.game:getCamera():getPositionXY()

  for i = 1, #self.allobjects do

    if pointInRect(
        cx + ox, cy + oy,
        self.allobjects[i].selbox[1] + ox, self.allobjects[i].selbox[2],
        self.allobjects[i].selbox[3] + oy, self.allobjects[i].selbox[4] ) then

      table.insert( sl, self.allobjects[i] )
      wasselected = true

    end

  end

  if ( not Input:isKeyDown("lctrl") ) then
    self:selectAll( false )
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

end

function MapEditor:getNextGeneratedName()
  self.objectNameIndex = self.objectNameIndex + 1

  return "obj" .. self.objectNameIndex
end

--- OBJECT MANAGEMENT ----------------------------------------------------------

function MapEditor:addObject( objectToAdd, addSelected )

  local vpts = objectToAdd:getPosition()

  local w, h = objectToAdd:getDimensions()

  local qd = { vpts.x, vpts.y, w, h }

  local obj = {
    object   = objectToAdd,
    selected = addSelected,
    selbox   = qd
  }

  if ( addSelected ) then
    self.selectedCount = self.selectedCount + 1
  end

  table.insert( self.allobjects, obj )

end

function MapEditor:removeObject( objectToRemove )
  local index = 0

  for i = 1, #self.allobjects do

    if ( self.allobjects[i].object:getName() == objectToRemove:getName() ) then
      index = i
    end

  end

  if ( index > 0 ) then
    area:removeSimpleObject( objectToRemove:getName() )
    area:removeGround( objectToRemove:getName() )
    area:removeSpawnPoint( objectToRemove:getName() )

    table.remove( self.allobjects, index )
  end

end

function MapEditor:duplicateSelectedObjects()
  local oc = #self.allobjects

  for i = 1, oc do
    local newname = self:getNextGeneratedName()

    local dp = self.allobjects[i].object:clone( newname )

    dp:changePosition( Vec( 20, 20) )

    index = self:addObject( dp, true )

    self:selectObject( dp )

    self.area:addSimpleObject( dp )

    self.game:getDrawManager():addObject( dp )

  end
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

function MapEditor:turnSelectedIntoObject()
  --//TODO
end

function MapEditor:turnSelectedIntoGround()
  --//TODO
end

function MapEditor:removeSelected()

  local dd = #self.allobjects


  for i = dd, 1 do

    if ( self.allobjects[i].selected ) then
      self:removeObject( self.allobjects[i] )
    end

  end

  self:selectAll( false ) -- unnecessary?

end

--- GENERAL UPDATE AND KEYPRESS ------------------------------------------------

function MapEditor:updategeneral( dt )

end

function MapEditor:keypressgeneral( key )

  if ( self.textInput ) then
    self.textInput:keypressed( key )
    return
  end

  if ( key == "f1" ) then

    self.textInput        = TextInput( "Floor Name:" )
    self.updatefunction   = self.updateAddFloor
    self.keypressfunction = self.keypressAddFloor

  end

  if ( key == "f2" ) then
    optionsToShow         = floorOptions

    self.textInput        = TextInput( "Floor Name (Edit):" )
    self.updatefunction   = self.updateSelectFloor
    self.keypressfunction = self.keypressSelectFloor

  end

  if ( (Input:isKeyDown("lctrl") ) and ( key == "f1" ) ) then

    self.textInput        = TextInput( "Floor Name (Remove):" )
    self.updatefunction   = self.updateRemoveFloor
    self.keypressfunction = self.keypressRemoveFloor

  end

  if ( key == "f11") then

    self.mapList:backFromEdit()
    return

  end

end

--- ADD FLOOR ------------------------------------------------------------------

function MapEditor:updateAddFloor( dt )
  if ( self.textInput:isFinished() ) then

    local floorname = self.textInput:getText()

    if ( floorname ~= "") then

      local floor = Floor( floorname )

      self.map:addFloor( floor )

      print("Floor Added '" .. floorname .. "' ")
    end

    self.textInput = nil

    self.updatefunction = self.updategeneral
    self.keypressfunction = self.keypressgeneral
  end

end

function MapEditor:keypressAddFloor( key )
  self.textInput:keypressed( key )
end

---- SELECT FLOOR --------------------------------------------------------------

function MapEditor:updateSelectFloor( dt )

  if ( self.textInput:isFinished() ) then

    local floorname = self.textInput:getText()

    local selected = self.map:getFloorByName( floorname )

    if ( selected ) then

      self.floor = selected

      optionsToShow = floorOptions

      self.updatefunction = self.updateEditFloor
      self.keypressfunction = self.keypressEditFloor

    else

      optionsToShow = mapOptions

      self.updatefunction = self.updategeneral
      self.keypressfunction = self.keypressgeneral

      print( "No floor was selected . Wrong name '" .. floorname .. "' ? " )

    end

    self.textInput = nil

  end

end

function MapEditor:keypressSelectFloor( key )
  self.textInput:keypressed( key )
end

--- EDIT FLOOR -----------------------------------------------------------------

function MapEditor:updateEditFloor( dt )

end

function MapEditor:keypressEditFloor( key )
  if ( self.textInput ) then
    self.textInput:keypressed( key )
    return
  end

  if ( key == "f1" ) then
    self.textInput        = TextInput( "Area Name:" )
    self.updatefunction   = self.updateAddArea
    self.keypressfunction = self.keypressAddArea
  end

  if ( key == "f2" ) then
    self.textInput        = TextInput( "Area Name:" )
    self.updatefunction   = self.updateSelectArea
    self.keypressfunction = self.keypressSelectArea
  end

  if ( ( Input:isKeyDown( "lctrl" ) ) and ( key == "f1" ) ) then
    self.textInput        = TextInput( "Area Name (Remove):" )
    self.updatefunction   = self.updateRemoveArea
    self.keypressfunction = self.keypressRemoveArea
  end

  if ( key == "f11") then

    self.updatefunction   = self.updategeneral
    self.keypressfunction = self.keypressgeneral

    optionsToShow = mapOptions
    return

  end

end

--- REMOVE FLOOR ----------------------------------------------------------------

function MapEditor:updateRemoveFloor( dt )
  if ( self.textInput:isFinished() ) then

    local floorname = self.textInput:getText()

    local removed = self.map:removeFloorByName( floorname )

    if ( not removed ) then
      print( "No floor was deleted . Wrong name '" .. floorname .. "' ? " )
    end

    self.textInput = nil

    self.updatefunction = self.updategeneral
    self.keypressfunction = self.keypressgeneral
  end

end

function MapEditor:keypressRemoveFloor( key )
  self.textInput:keypressed( key )
end

--- ADD AREA -------------------------------------------------------------------

function MapEditor:updateAddArea( dt )
  if ( self.textInput:isFinished() ) then

    local areaname = self.textInput:getText()

    if ( areaname ~= "") then

      local area = Area( areaname )

      self.floor:addArea( area )

      print( "Area Added '" .. areaname .. "' " )

    end

    self.textInput = nil

    self.updatefunction = self.updateEditFloor
    self.keypressfunction = self.keypressEditFloor
  end

end

function MapEditor:keypressAddArea( key )
  self.textInput:keypressed( key )
end

---- SELECT AREA --------------------------------------------------------------

function MapEditor:updateSelectArea( dt )

  if ( self.textInput:isFinished() ) then

    local areaname = self.textInput:getText()

    local selected = self.floor:getAreaByName( areaname )

    if ( selected ) then

      self.area = selected

      optionsToShow = areaOptions

      self.updatefunction = self.updateEditArea
      self.keypressfunction = self.keypressEditArea

    else

      optionsToShow = floorOptions

      self.updatefunction = self.updateEditFloor
      self.keypressfunction = self.keypressEditFloor

      print( "No area was selected . Wrong name '" .. areaname .. "' ? " )

    end

    self.textInput = nil

  end

end

function MapEditor:keypressSelectArea( key )
  self.textInput:keypressed( key )
end

--- EDIT AREA -----------------------------------------------------------------

function MapEditor:updateEditArea( dt )

end

function MapEditor:keypressEditArea( key )
  if ( self.textInput ) then
    self.textInput:keypressed( key )
    return
  end

  if ( key == "f1" ) then
    optionsToShow         = objectsOptions
    self.updatefunction   = self.updateObjects
    self.keypressfunction = self.keypressObjects
  end

  if ( key == "f2" ) then
    self.textInput        = TextInput( "Object Name:" )
    self.updatefunction   = self.updateSelectFromLibrary
    self.keypressfunction = self.keypressSelectFromLibrary
  end

  if ( key == "f7" ) then
    optionsToShow         = editNavMeshOptions
    self.updatefunction   = self.updateNavMesh
    self.keypressfunction = self.keypressNavMesh
  end

  if ( key == "f11") then

    self.updatefunction   = self.updateEditFloor
    self.keypressfunction = self.keypressEditFloor

    optionsToShow = floorOptions

    return

  end

end

--- REMOVE AREA ----------------------------------------------------------------

function MapEditor:updateRemoveArea( dt )
  if ( self.textInput:isFinished() ) then

    local areaname = self.textInput:getText()

    local removed = self.floor:removeAreaByName( areaname )

    if ( not removed ) then
      print("No area was deleted . Wrong name '" .. areaname .. "' ? ")
    end

    self.textInput = nil

    self.updatefunction = self.updateEditFloor
    self.keypressfunction = self.keypressEditFloor
  end

end

function MapEditor:keypressRemoveArea( key )
  self.textInput:keypressed( key )
end

--- SELECT OBJECT --------------------------------------------------------------

function MapEditor:updateObjects( dt )

end

function MapEditor:keypressObjects( key )
  if ( self.textInput ) then
    self.textInput:keypressed( key )
    return
  end

  if ( (key == "a")  and ( Input:isKeyDown( "lctrl" ) )  ) then
    if ( self.selectedCount > 0 ) then
      self:selectAll( false )
    else
      self:selectAll( true )
    end

  end

  if ( key == "f1" ) then
    --self.updatefunction   = self.updateObjects
    --self.keypressfunction = self.keypressObjects
  end

  if ( key == "f4" ) then
    self.textInput        = TextInput("Object Name:")
    self.updatefunction   = self.updateSelectFromLibrary
    self.keypressfunction = self.keypressSelectFromLibrary
  end

  if ( (key == "d")  and ( Input:isKeyDown( "lctrl" ) ) ) then
    self:duplicateSelectedObjects()
  end

  if ( key == "end" ) then
    self:turnSelectedIntoGround()
  end

  if ( key == "home" ) then
    self:turnSelectedIntoObject()
  end

  if ( key == "delete" ) then
    self:removeSelected()
  end

  if ( key == "up" or key == "down" or key == "left" or key == "right" ) then
    self:moveSelectedByKeys( key )
  end

  if ( key == "f11") then

    self.updatefunction   = self.updateEditArea
    self.keypressfunction = self.keypressEditArea

    optionsToShow = floorOptions

    return

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

      object = self.game:getObjectManager():loadSimpleObject( objectname, instancename, px + cx, py + cy )

      self.library[objectname] = object

    end

    if ( object ) then

      self.area:addSimpleObject( object )

      self.game:getDrawManager():addObject( object )

      self:addObject( object, true )

    end

    self.textInput = nil

    self.updatefunction = self.updateObjects
    self.keypressfunction = self.keypressObjects
  end
end

function MapEditor:keypressSelectFromLibrary( key )
  self.textInput:keypressed( key )
end
