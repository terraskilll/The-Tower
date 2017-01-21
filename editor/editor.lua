require("../engine/lclass")

require("../engine/input")
require("../engine/ui/uigroup")
require("../engine/ui/button/button")
require("../engine/screen/screen")

require("../editor/resourcelist")
require("../editor/objectlist")
require("../editor/objecteditor")
require("../editor/maplist")
require("../editor/mapeditor")

local options = {
  "F1 - Edit Resources",
  "F2 - Edit Static Objects",
  "F3 - Edit Maps",
  "F4 - Edit Animations"
}

class "Editor" ("Screen")

function Editor:Editor()
  self.currentEditor = nil
end

function Editor:update(dt)
  if (self.currentEditor ~= nil) then
    self.currentEditor:update(dt)
  else
    self:localUpdate(dt)
  end
end

function Editor:draw()
  if (self.currentEditor ~= nil) then
    self.currentEditor:draw()
  else
    self:localDraw()
  end
end

function Editor:localUpdate(dt)

end

function Editor:localDraw()
  for i = 1, #options do
    love.graphics.print(options[i], 16, (i * 16) + 40)
  end
end

function Editor:onEnter()
  print("Entered Editor")
end

function Editor:onExit()

end

function Editor:onKeyPress(key, scancode, isrepeat)
  if ( self.currentEditor ~= nil ) then
    self.currentEditor:onKeyPress(key, scancode, isrepeat)
  else
    self:checkKey(key, scancode, isrepeat)
  end
end

function Editor:onKeyRelease(key, scancode, isrepeat)

end

function Editor:textInput( t )
  if (self.currentEditor ~= nil) then

    if ( self.currentEditor.doTextInput ~= nil) then
      self.currentEditor:doTextInput( t )
    end

  end
end

function Editor:checkKey(key, scancode, isrepeat)
  if ( key == "f1" ) then
    self.currentEditor = ResourceList()
    self.currentEditor:onEnter()
  end

  if ( key == "f2" ) then
    self.currentEditor = ObjectList()
    self.currentEditor:onEnter()
  end

  if ( key == "f3" ) then

  end

end
