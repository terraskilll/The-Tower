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

require("../editor/objectselector")

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


}

local groundOptions = {

}

local spawnPtOptions = {

}

local enemyOptions = {

}

local optionsToShow = mapOptions

class "MapEditor"

function MapEditor:MapEditor( mapListOwner, mapIndex, mapName )
  self.mapList = mapListOwner
  self.index   = mapIndex
  self.name    = mapName

  self.incModifier = 1

  self.map   = nil
  self.floor = nil
  self.area  = nil

  self.objectSelector = ObjectSelector()

  self.updatefunction   = self.updategeneral
  self.keypressfunction = self.keypressgeneral

  self.textInput = nil

  self:loadMap( mapName )
end

function MapEditor:onEnter()
  print("Entered MapEditor")
end

function MapEditor:onExit()
  self.resourceManager = nil
end

function MapEditor:update( dt )
  self:updatefunction( dt )
end

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

function MapEditor:draw()

  if ( self.textInput ) then
    self.textInput:draw()
    return
  end

  for i = 1, #generalOptions do
    love.graphics.print( generalOptions[i], 1050, (i * 16) )
  end

  for i = 1, #optionsToShow do
    love.graphics.print( optionsToShow[i], 1050, (i * 16) + 100)
  end

  self.objectSelector:draw()

  love.graphics.print("Inc Modifier: " .. self.incModifier, 1050, 700)
end

function MapEditor:onMousePress( x, y, button, istouch )

  self.objectSelector:mousePressed( x, y, button, 1, 1, self )

end

function MapEditor:onMouseRelease( x, y, button, istouch )

end

function MapEditor:onMouseMove( x, y, dx, dy )

  self.objectSelector:mouseMoved( x, y, dx, dy, 1, 1, self )

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

--- GENERAL UPDATE AND KEYPRESS ------------------------------------------------

function MapEditor:updategeneral( dt )

end

function MapEditor:keypressgeneral( key )

  if ( self.textInput ) then
    self.textInput:keypressed( key )
    return
  end

  if ( key == "f1" ) then

    self.textInput        = TextInput("Floor Name:")
    self.updatefunction   = self.updateAddFloor
    self.keypressfunction = self.keypressAddFloor

  end

  if ( key == "f2" ) then
    optionsToShow         = floorOptions

    self.textInput        = TextInput("Floor Name (Edit):")
    self.updatefunction   = self.updateSelectFloor
    self.keypressfunction = self.keypressSelectFloor

  end

  if ( (Input:isKeyDown("lctrl") ) and ( key == "f1" ) ) then

    self.textInput        = TextInput("Floor Name (Remove):")
    self.updatefunction   = self.updateRemoveFloor
    self.keypressfunction = self.keypressRemoveFloor

  end

  if ( key == "f11") then

    self.mapList:backFromEdit()
    return

  end

end

--- ADD FLOOR -------------------------------------------------------------------

function MapEditor:updateAddFloor( dt )
  if ( self.textInput:isFinished() ) then

    local floorname = self.textInput:getText()

    local floor = Floor( floorname )

    self.map:addFloor( floor )

    print("Floor Added '" .. floorname .. "' ")

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

      optionsToShow = floorOptions

      self.updatefunction = self.updateEditFloor
      self.keypressfunction = self.keypressEditFloor

    else

      optionsToShow = mapOptions

      self.updatefunction = self.updategeneral
      self.keypressfunction = self.keypressgeneral

      print("No floor was selected . Wrong name '" .. floorname .. "' ? ")

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
    self.textInput        = TextInput("Area Name:")
    self.updatefunction   = self.updateAddArea
    self.keypressfunction = self.keypressAddArea
  end

  if ( key == "f2" ) then
    self.textInput        = TextInput("Area Name:")
    self.updatefunction   = self.updateSelectArea
    self.keypressfunction = self.keypressSelectArea
  end

  if ( ( Input:isKeyDown("lctrl") ) and ( key == "f1" ) ) then
    self.textInput        = TextInput("Area Name (Remove):")
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
      print("No floor was deleted . Wrong name '" .. floorname .. "' ? ")
    end

    self.textInput = nil

    self.updatefunction = self.updategeneral
    self.keypressfunction = self.keypressgeneral
  end

end

function MapEditor:keypressRemoveFloor( key )
  self.textInput:keypressed( key )
end

--------------------------------------------------------------------------------
