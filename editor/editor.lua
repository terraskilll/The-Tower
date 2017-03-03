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
  "F2 - Edit Simple Objects",
  "F3 - Edit Maps",
  "F4 - Edit Animations"
}

class "Editor" ("Screen")

function Editor:Editor( thegame )
  self.game = thegame
  self.name = "EditorScreen"
  self.currentEditor = nil

end

function Editor:update( dt )
  if ( self.currentEditor  ) then
    self.currentEditor:update( dt )
  else
    self:localUpdate( dt )
  end
end

function Editor:draw()
  if ( self.currentEditor ) then
    self.currentEditor:draw()
  else
    self:localDraw()
  end
end

function Editor:localUpdate( dt )

end

function Editor:localDraw()
  for i = 1, #options do
    love.graphics.print( options[i], 16, (i * 16) + 40 )
  end
end

function Editor:onEnter()
  print("Entered Editor")
end

function Editor:onExit()

end

function Editor:onKeyPress( key, scancode, isrepeat )
  if ( self.currentEditor ) then
    self.currentEditor:onKeyPress( key, scancode, isrepeat )
  else
    self:checkKey( key, scancode, isrepeat )
  end
end

function Editor:onKeyRelease( key, scancode, isrepeat )

end

function Editor:textInput( t )
  if (self.currentEditor ) then

    if ( self.currentEditor.doTextInput ) then
      self.currentEditor:doTextInput( t )
    end

  end
end

function Editor:onMousePress( x, y, button, istouch )
  if (self.currentEditor ) then

    if ( self.currentEditor.onMousePress ) then
      self.currentEditor:onMousePress( x, y, button, istouch )
    end

  end
end

function Editor:onMouseRelease( x, y, button, istouch )
  if (self.currentEditor ) then

    if ( self.currentEditor.onMouseRelease ) then
      self.currentEditor:onMouseRelease( x, y, button, istouch )
    end

  end
end

function Editor:onMouseMove( x, y, dx, dy )
  if (self.currentEditor ) then

    if ( self.currentEditor.onMouseMove ) then
      self.currentEditor:onMouseMove( x, y, dx, dy )
    end

  end
end

function Editor:checkKey( key, scancode, isrepeat )
  if ( key == "f1" ) then
    self.currentEditor = ResourceList( self, self.game )
    self.currentEditor:onEnter()
  end

  if ( key == "f2" ) then
    self.currentEditor = ObjectList( self, self.game )
    self.currentEditor:onEnter()
  end

  if ( key == "f3" ) then
    self.currentEditor = MapList( self, self.game )
    self.currentEditor:onEnter()
  end

end

function Editor:backFromEdit()
  self.currentEditor:onExit()
  self.currentEditor = nil
end
