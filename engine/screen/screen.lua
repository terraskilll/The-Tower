-------------------------------------------------------------------------------
-- gamescreen base class
-------------------------------------------------------------------------------

require ("../engine/lclass")

require("../resources")
require("../engine/input")

class "Screen"

function Screen:Screen()
  self.game = nil
  self.backgroundImage = nil
  self.camera = nil
end

function Screen:onEnter()
  print("default Screen onenter function: need override")
end

function Screen:onExit()
  print("default Screen onexit function: need override")
end

function Screen:update(dt)
  print("default Screen update function: need override")
end

function Screen:draw()
  print("default Screen draw function: need override")
end

function Screen:onEnter()
  print("default Screen onenter function: need override")
end

function Screen:onExit()
  print("default Screen onexit function: need override")
end

function Screen:setBackgroundImage( imageToSet )
  self.backgroundImage = imageToSet
end

function Screen:setCamera( cameraToSet )
  self.camera = cameraToSet
end
