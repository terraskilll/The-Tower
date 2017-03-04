--[[

an animation editor


--//TODO allow reorder frames

]]

require("../engine/lclass")
require("../engine/input")
require("../engine/io/io")
require("../engine/utl/funcs")

local Vec = require("../engine.math.vector")

local absfun = math.abs
local minfun = math.min
local maxfun = math.max

local generalOptions = {
  "Numpad '+/-' - Change Inc Modifier",
  "F9 - Save",
  "F11 - Back"
}

local editingOptions = {
  "F1 - Load Image",
  "F2 - Create Frame",
  "F3 - Set By Mouse",
  "F4 - Change Duration (Ctrl: All)",
  "",
  "PgUp/PgDown - Previous/Next Frame",
  "Ctrl+Del - Delete Frame",
  "",
  "F8 - View Animation",
  "",
  "Numpad 5 - Use all image",
  "Numpad 2,4,6,8 - Increase on direction",
  "Numpad+Ctrl - Decrease on direction",
  "Up,Down,Left, Right - Move"
}

local viewingOptions = {

}

local optionsToShow = editingOptions

class "AnimationEditor"

function AnimationEditor:AnimationEditor( animationListOwner, animationIndex, animationName, thegame )
  self.game          = thegame
  self.animationList = animationListOwner
  self.index         = animationIndex
  self.name          = animationName

  self.textInput = nil

  self.incModifier = 1

  self.image = nil

  self.animation  = Animation( animationName )
  self.frame      = nil
  self.frameIndex = 1

  self.viewing = false

  self.applytoall = false

  self.updatefunction   = self.updategeneral
  self.keypressfunction = self.keypressgeneral

  self.middleisdown = false
  self.leftisdown   = false

  self.mousepoint1 = nil

  self.mousewasdragged = false

  self:loadAnimation( animationName )
end

function AnimationEditor:onEnter()
  print("Entered AnimationEditor")
end

function AnimationEditor:onExit()
  self.game:getCamera():setPosition( 0, 0 )
end

function AnimationEditor:update( dt )
  self:updatefunction( dt )
end

function AnimationEditor:draw()

  if ( self.textInput ) then
    self.textInput:draw()
    return
  end

  if ( self.viewing ) then
    self:drawViewing()
  else
    self:drawEditing()
  end

end

function AnimationEditor:drawEditing()
  self.game:getCamera():set()

  if ( self.image ) then

    love.graphics.draw( self.image, 0, 0, 0 )

  end

  if ( self.frame ) then
    self.frame:drawRect( 0, 0 )
  end

  if ( self.mousepoint1 ) then
    local cx, cy = self.game:getCamera():getPositionXY()

    local mx, my = Input:mousePosition()

    local px = minfun ( self.mousepoint1[1], mx + cx )
    local py = minfun ( self.mousepoint1[2], my + cy )

    local pw = maxfun ( self.mousepoint1[1], mx + cx ) - px
    local ph = maxfun ( self.mousepoint1[2], my + cy ) - py

    love.graphics.rectangle( "line", px, py, pw, ph )

  end

  self.game:getCamera():unset()

  love.graphics.setColor( glob.defaultColor )

  for i = 1, #generalOptions do
    love.graphics.print( generalOptions[i], 1000, (i * 16) )
  end

  for i = 1, #optionsToShow do
    love.graphics.print( optionsToShow[i], 1000, (i * 16) + 100 )
  end

  love.graphics.print( "Inc Modifier: " .. self.incModifier, 1000, 700 )

  self.game:getCamera():drawPosition( 1000, 680 )
end

function AnimationEditor:drawViewing()

  self.game:getCamera():set()

  if ( self.animation ) then
    self.animation:draw( 0, 0 )
  end

  self.game:getCamera():unset()

  for i = 1, #generalOptions do
    love.graphics.print( generalOptions[i], 1000, (i * 16) )
  end

end

function AnimationEditor:setFrameQuadByMouse( x1, y1, x2, y2 )
  local w, h = self.image:getWidth(), self.image:getHeight()

  local newquad = love.graphics.newQuad(x1, y1, x2 - x1, y2 - y1, w, h)

  self.frame:setQuad ( newquad )
end

function AnimationEditor:deleteFrame()

  if ( self.animation:getFrameCount() > 0 ) then

    self.animation:removeFrame( self.frameIndex )

    self.frameIndex = 1

    if ( self.animation:getFrameCount() > 0) then
      self.frame = self.animation:getFrame( self.frameIndex )
    end

  end

end

function AnimationEditor:onKeyPress( key, scancode, isrepeat )

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
    self:saveAnimation( self.name )

    return
  end

  if ( key == "f11" ) then

    if (self.mode ~= 0) then
      self.mode = 0

      options = generalOptions

      self.updatefunction   = self.updategeneral
      self.keypressfunction = self.keypressgeneral

      return
    end

  end

  self:keypressfunction( key )

end

function AnimationEditor:onMousePress( x, y, button, istouch )

  self.leftisdown   = button == 1
  self.middleisdown = button == 3

end

function AnimationEditor:onMouseRelease( x, y, button, istouch )

  if ( button == 1 ) then

    if ( self.framebymouse ) then

      local cx, cy = self.game:getCamera():getPositionXY()

      if ( self.mousepoint1 ) then

        self:setFrameQuadByMouse( self.mousepoint1[1], self.mousepoint1[2], x + cx, y + cy )

        self.mousepoint1 = nil

        self.framebymouse = false

      else

        self.mousepoint1 = { x + cx, y + cy }

      end

    end

    self.leftisdown = false
  end

  if ( button == 3 ) then
    self.middleisdown = false
  end

end

function AnimationEditor:onMouseMove( x, y, dx, dy )

  self.mousewasdragged = false

  if ( self.leftisdown ) then

    self.mousewasdragged = true

  end

  if ( self.middleisdown ) then
    self.game:getCamera():move( -dx, -dy )

    self.mousewasdragged = true
  end

end

function AnimationEditor:doTextInput ( t )

  if ( self.textInput ) then
    self.textInput:input( t )
  end

end

function AnimationEditor:saveAnimation( animationFileName )

  self.game:getAnimationManager():saveAnimation( animationFileName, self.animation )

end

function AnimationEditor:loadAnimation( animationFileName )

  self.animation, self.image = self.game:getAnimationManager():loadAnimation( animationFileName )

  if ( self.animation ) then

    self.frame = self.animation:getFrame( 1 )

  else

    self.animation = Animation( self.name )

  end

end

function AnimationEditor:updategeneral( dt )

  if ( self.viewing ) then
    self.animation:update( dt )
  end

end

function AnimationEditor:keypressgeneral( key )

  if ( self.textInput ) then
    self.textInput:keypressed( key )
    return
  end

  if ( key == "f1" ) then
    self.textInput = TextInput( "Resource Name:" )

    self.updatefunction = self.updateSelectImage
    self.keypressfunction = self.keypressSelectImage
  end

  if ( key == "f2" ) then

    local frame = Frame()

    self.frame = frame

    local w, h = self.image:getWidth(), self.image:getHeight()

    local quad = love.graphics.newQuad(0, 0, w, h, w, h)

    self.frame:setQuad( quad )
    self.frame:setDuration( 0.5 )
    self.animation:addFrame( frame )

    self.frameIndex = self.animation:getFrameCount()

  end

  if ( self.frame ) then

    self:keypressFrameQuad( key )

    self:keypressSelectFrame( key )

  end

  if ( key == "f3" ) then -- set by mouse

    self.animation:start()

    self.framebymouse = true

    self.mousepoint1 = nil

  end

  if ( key == "f4" ) then

    self.textInput = TextInput( "Frame Duration :" )

    self.updatefunction = self.updateSetFrameDuration
    self.keypressfunction = self.keypressSetFrameDuration

    if ( Input:isKeyDown("lctrl") ) then
      self.applytoall = true
    end

  end

  if ( ( key == "delete" ) and ( Input:isKeyDown("lctrl") ) ) then

    self:deleteFrame()

  end

  if ( key == "f8" ) then

    self.animation:start()

    self.viewing = not self.viewing

  end

  if ( key == "f11") then
    self:onExit()
    self.animationList:backFromEdit()
    return

  end

end

---- SELECT IMAGE --------------------------------------------------------------

function AnimationEditor:updateSelectImage( dt )
  if ( self.textInput:isFinished() ) then

    local resname, restype, respath = self.game:getResourceManager():getResourceByName( self.textInput:getText() )

    if ( restype == "image" ) then

      self.image = self.game:getResourceManager():loadImage( respath )

    end

    self.animation:setImage( self.image, resname )

    self.textInput = nil

    self.mode = 0

    self.updatefunction   = self.updategeneral
    self.keypressfunction = self.keypressgeneral
  end
end

function AnimationEditor:keypressSelectImage( key )

  if ( self.textInput ) then
    self.textInput:keypressed( key )
    return
  end

end

function AnimationEditor:keypressFrameQuad( key )
  local applyToQuad = false

  local w, h = self.image:getWidth(), self.image:getHeight()

  local quad = self.frame:getQuad()

  local qx, qy, lx, ly = quad:getViewport()
  local qw, qh = quad:getTextureDimensions()

  if ( key == "kp5" ) then

    qx, qy, lx, ly, qw, qh = 0, 0, w, h, w, h

    applyToQuad = true

  end

  local inc = 1

  if ( Input:isKeyDown("lctrl") ) then
    inc = -1
  end

  inc = inc * self.incModifier

  if  ( key == "kp2" ) then -- h
    ly = ly + inc

    applyToQuad = true
  end

  if  ( key == "kp4" ) then -- x, w
    qx = qx - inc
    lx = lx + inc

    applyToQuad = true
  end

  if  ( key == "kp6" ) then -- w
    lx = lx + inc

    applyToQuad = true
  end

  if  ( key == "kp8" ) then -- y, h
    qy = qy - inc
    ly = ly + inc

    applyToQuad = true
  end

  if  ( key == "left" ) then -- x
    inc = absfun( inc )

    qx = qx - inc

    applyToQuad = true
  end

  if  ( key == "right" ) then -- x
    inc = absfun( inc )

    qx = qx + inc

    applyToQuad = true
  end

  if  ( key == "up" ) then -- y
    inc = absfun( inc )

    qy = qy - inc

    applyToQuad = true
  end

  if  ( key == "down" ) then -- y
    inc = absfun( inc )

    qy = qy + inc

    applyToQuad = true
  end

  if ( applyToQuad ) then
    local newquad = love.graphics.newQuad( qx, qy, lx, ly, qw, qh )

    self.frame:setQuad( newquad )
  end
end

function AnimationEditor:keypressSelectFrame( key )

  if ( key == "pageup" and self.animation:getFrameCount() > 1 ) then

    self.frameIndex = self.frameIndex - 1

    if ( self.frameIndex == 0 ) then
      self.frameIndex = self.animation:getFrameCount()
    end

    self.frame = self.animation:getFrame( self.frameIndex )

  end

  if ( key == "pagedown" and self.animation:getFrameCount() > 1 ) then

    self.frameIndex = self.frameIndex + 1

    if ( self.frameIndex > self.animation:getFrameCount() ) then
      self.frameIndex = 1
    end

    self.frame = self.animation:getFrame( self.frameIndex )

  end

end

----- FRAME DURATION  ----------------------------------------------------------

function AnimationEditor:updateSetFrameDuration( dt )

  if ( self.textInput:isFinished() ) then

    local strdur = self.textInput:getText()

    if not tonumber(strdur) then
      print("Invalid duration value : " + strdur)
    else
      self.frame:setDuration( tonumber( strdur ) )

      if ( self.applytoall ) then

        for i = 1, self.animation:getFrameCount() do
          self.animation:getFrame(i):setDuration( tonumber( strdur ) )
        end

      end
    end

    self.applytoall = false

    self.textInput = nil

    self.updatefunction   = self.updategeneral
    self.keypressfunction = self.keypressgeneral
  end

end

function AnimationEditor:keypressSetFrameDuration( key )

  if ( self.textInput ) then
    self.textInput:keypressed( key )
    return
  end

end
