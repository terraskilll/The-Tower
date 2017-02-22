--[[

the engine game editor

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

local generalOptions = {
  "Numpad '+/-' - Change Inc Modifier",
  --"F8 - Toogle View All/View Quad",
  "F9 - Save",
  "F11 - Back"
}

class "MapEditor"

function MapEditor:MapEditor( mapListOwner, mapIndex, mapName )
  self.mapList = mapListOwner
  self.index   = mapIndex
  self.name    = mapName

  self.incModifier = 1

  self.map = Map( mapName )

  self.updatefunction   = self.updategeneral
  self.keypressfunction = self.keypressgeneral

  self.textInput = nil
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

  if ( key == "f11" ) then

    if (self.mode ~= 0) then
      self.mode = 0

      options = mainOptions

      self.updatefunction   = self.updategeneral
      self.keypressfunction = self.keypressgeneral

      return
    end

  end

  self:keypressfunction( key )
end

function MapEditor:draw()

  for i = 1, #generalOptions do
    love.graphics.print( generalOptions[i], 1050, (i * 16) )
  end

  love.graphics.print("Inc Modifier: " .. self.incModifier, 1050, 700)
end

function MapEditor:updategeneral( dt )

end

function MapEditor:keypressgeneral( key )

  if ( self.mode == 1 ) then
    self.textInput:keypressed( key )
    return
  end

  if ( key == "f1" ) then

  end

  if ( key == "f2" ) then

  end

  if ( key == "f4" ) then

  end

  if ( key == "f5" ) then

  end

  if ( key == "f11") then
    self.mapList:backFromEdit()
    return
  end

end

function MapEditor:doTextInput ( t )

  if ( self.textInput ) then
    self.textInput:input( t )
  end

end

function MapEditor:saveMap( mapFileName)
  print("TODO save")
end
