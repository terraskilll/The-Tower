-------------------------------------------------------------------------------
-- gamescreen base class
-------------------------------------------------------------------------------

require ("lclass")

require("resources")
require("../input")

class "Screen"

function Screen:Screen()
  self.game = nil
  self.backgroundImage = nil
end

function Screen:onEnter()
  print("default Scren onenter function: need override")
end

function Screen:onExit()
  print("default Scren onexit function: need override")
end

function Screen:update(dt)
  print("default Scren update function: need override")
end

function Screen:draw()
  print("default Scren draw function: need override")
end

function Screen:onEnter()
  print("default Scren onenter function: need override")
end

function Screen:onExit()
  print("default Scren onexit function: need override")
end

function Screen:setBackgroundImage(newImage)
  self.backgroundImage = newImage
end

