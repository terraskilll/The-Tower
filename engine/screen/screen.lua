-------------------------------------------------------------------------------
-- gamescreen base class
-------------------------------------------------------------------------------

require ("..engine.lclass")

require("..engine.input")

class "Screen"

function Screen:Screen()
  self.name   = "EmptyScreen"
  self.game   = nil
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

function Screen:getName()
  return self.name
end

function Screen:setCamera( cameraToSet )
  self.camera = cameraToSet
end
