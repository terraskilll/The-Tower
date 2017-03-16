--[[

an animation editor

--//TODO allow reorder frames

]]

require("..engine.lclass")
require("..engine.input")
require("..engine.io.io")
require("..engine.utl.funcs")

local Vec = require("..engine.math.vector")

local absfun = math.abs
local minfun = math.min
local maxfun = math.max

local generalOptions = {
  "F9 - Save",
  "F11 - Back"
}

local editingOptions = {
  "Numpad '+/-' - Change Animation Count",
  "Ctrl+N - Set Base Name",
  "",
  "F1 - Load Image",
  "F2 - Set Start Position",
  "F3 - Set Frame Dimension ",
  "F4 - Set Frame Count ",
  "F5 - Set Padding Between Frames",
  "F6 - Change Frame Duration",
  "",
  "F7 - Preview Frames",
  "Ctrl+F7 - Create Animations Frames",
  "",
  "F8 - View Animations"
}

local viewingOptions = {
  "F8 - Back to Editing",
  "Left/Right - Change Current Animation"
}

local optionsToShow = editingOptions

class "AutoAnimator"

function AutoAnimator:AutoAnimator( animationListOwner, thegame )
  self.game          = thegame
  self.animationList = animationListOwner

  self.textInput = nil

  self.viewing = false

  self.cedit = { 0, 0 }
  self.cview = { 0, 0 }

  self.viewindex = 1

  self.applytoall = false

  self.imagew = 0
  self.imageh = 0

  self.animdata = {
    animcount  = 1,
    image      = nil,
    resname    = nil,
    basename   = "",
    startx     = 0,
    starty     = 0,
    paddx      = 0,
    paddy      = 0,
    framecount = 0,
    framew     = 0,
    frameh     = 0,
    framedur   = 1
  }

  self.mode = 0

  self.animations = {}

  self.rects = {}

  self.updatefunction   = self.updategeneral
  self.keypressfunction = self.keypressgeneral

  self.middleisdown = false
  self.leftisdown   = false
end

function AutoAnimator:onEnter()
  print( "Entered AutoAnimator" )
end

function AutoAnimator:onExit()
  self.game:getCamera():setPosition( 0, 0 )
end

function AutoAnimator:update( dt )
  self:updatefunction( dt )
end

function AutoAnimator:draw()

  if ( self.textInput ) then
    self.textInput:draw()
    return
  end

  if ( self.viewing ) then
    self:drawViewing()
  else
    self:drawEditing()
  end

  self.game:getCamera():drawPosition( 1000, 680 )

end

function AutoAnimator:drawEditing()
  self.game:getCamera():set()

  if ( self.animdata.image ) then
    love.graphics.draw( self.animdata.image, 0, 0, 0 )

    love.graphics.line( 0, 0, self.imagew, 0 )
    love.graphics.line( 0, 0, 0, self.imageh )

    love.graphics.line( self.imagew, 0, self.imagew,  self.imageh )
    love.graphics.line( 0,  self.imageh, self.imagew, self.imageh )

    if ( #self.rects > 0 ) then

      for i = 1, #self.rects do
        love.graphics.rectangle("line", self.rects[i][1], self.rects[i][2], self.rects[i][3], self.rects[i][4] )

        love.graphics.print( tostring( i ), self.rects[i][1] + 5, self.rects[i][2] + 5 )
      end

    end

  end

  self.game:getCamera():unset()

  for i = 1, #generalOptions do
    love.graphics.print( generalOptions[i], 1000, (i * 16) )
  end

  for i = 1, #optionsToShow do
    love.graphics.print( optionsToShow[i], 1000, (i * 16) + 100 )
  end

  -- anim data ---
  love.graphics.setColor( 100, 255, 100 )
  love.graphics.print( " * * Parameters * * ", 10, 640 )
  love.graphics.setColor( glob.defaultColor )
  love.graphics.print( "Base Name: " .. self.animdata.basename, 10, 660 )
  love.graphics.print( "Anim. Count: " .. self.animdata.animcount, 10, 690 )

  love.graphics.print( "Start X: " .. self.animdata.startx, 250, 660 )
  love.graphics.print( "Start Y: " .. self.animdata.starty, 250, 690 )

  love.graphics.print( "Frame Width : " .. self.animdata.framew, 400, 660 )
  love.graphics.print( "Frame Height: " .. self.animdata.frameh, 400, 690 )

  love.graphics.print( "Padding X: " .. self.animdata.paddx, 650, 660 )
  love.graphics.print( "Padding Y: " .. self.animdata.paddy, 650, 690 )

  love.graphics.print( "Frame Count: " .. self.animdata.framecount, 800, 660 )
  love.graphics.print( "Frame Duration: " .. self.animdata.framedur, 800, 690 )
end

function AutoAnimator:drawViewing()

  self.game:getCamera():set()

  if ( #self.animations > 0 ) then
    self.animations[self.viewindex]:draw( 0, 0 )
  end

  self.game:getCamera():unset()

  for i = 1, #generalOptions do
    love.graphics.print( generalOptions[i], 1000, (i * 16) )
  end

  for i = 1, #viewingOptions do
    love.graphics.print( viewingOptions[i], 1000, (i * 16) + 100 )
  end

  love.graphics.print( "Current Animation: " .. self.viewindex, 1000, 640 )
end

function AutoAnimator:onKeyPress( key, scancode, isrepeat )

  if ( key == "f9" ) then
    self:saveAnimations()

    return
  end

  if ( key == "f11" ) then
    self:onExit()
    self.animationList:backFromEdit()
    return
  end

  self:keypressfunction( key )

end

function AutoAnimator:onMousePress( x, y, button, istouch )

  self.leftisdown   = button == 1
  self.middleisdown = button == 3

end

function AutoAnimator:onMouseRelease( x, y, button, istouch )

  if ( button == 1 ) then
    self.leftisdown = false
  end

  if ( button == 3 ) then
    self.middleisdown = false
  end

end

function AutoAnimator:onMouseMove( x, y, dx, dy )

  self.mousewasdragged = false

  if ( self.leftisdown ) then

    self.mousewasdragged = true

  end

  if ( self.middleisdown ) then
    self.game:getCamera():move( -dx, -dy )

    local cx, cy = self.game:getCamera():getPositionXY()

    if ( self.viewing ) then
      self.cview = { cx, cy }
    else
      self.cedit = { cx, cy }
    end

    self.mousewasdragged = true
  end

end

function AutoAnimator:doTextInput ( t )

  if ( self.textInput ) then
    self.textInput:input( t )
  end

end

function AutoAnimator:saveAnimations()
  if ( #self.animations == 0 ) then
    print( "No animation was created" )
    return
  end

  for i=1, #self.animations do
    self.game:getAnimationManager():saveAnimation( self.animations[i]:getName(), self.animations[i] )

    self.animationList:addToList( self.animations[i]:getName(), 1 )
  end

  self:onExit()
  self.animationList:backFromEdit()

end

function AutoAnimator:updategeneral( dt )

end

function AutoAnimator:updateViewing( dt )
  self.animations[self.viewindex]:update( dt )
end

function AutoAnimator:keypressgeneral( key )

  if ( self.textInput ) then
    self.textInput:keypressed( key )
    return
  end

  if ( key == "kp+" ) then
    self.animdata.animcount = self.animdata.animcount + 1

    return
  end

  if ( key == "kp-" ) then
    self.animdata.animcount = self.animdata.animcount - 1

    if ( self.animdata.animcount < 1 ) then
      self.animdata.animcount = 1
    end

    return
  end

  if ( ( key == "n" ) and ( Input:isKeyDown("lctrl") ) ) then
    self.textInput = TextInput( "Animation Base Name:" )

    self.updatefunction = self.updateSetName
    self.keypressfunction = self.keypressForTextInput
  end

  if ( key == "f1" ) then
    self.textInput = TextInput( "Image Resource Name:" )

    self.updatefunction = self.updateSelectImage
    self.keypressfunction = self.keypressForTextInput
  end

  if ( key == "f2" ) then
    self.mode = 1

    self.textInput = TextInput( "Start Position X:", self.animdata.startx )

    self.updatefunction = self.updateSetStartPosition
    self.keypressfunction = self.keypressForTextInput
  end

  if ( key == "f3" ) then
    self.mode = 1

    self.textInput = TextInput( "Frame Width:", self.animdata.framew )

    self.updatefunction = self.updateSetFrameSize
    self.keypressfunction = self.keypressForTextInput
  end

  if ( key == "f4" ) then
    self.textInput = TextInput( "Frames per Animation:", self.animdata.framecount )

    self.updatefunction = self.updateSetFrameCount
    self.keypressfunction = self.keypressForTextInput
  end

  if ( key == "f5" ) then
    self.mode = 1

    self.textInput = TextInput( "Padding X ( space between frames ):", self.animdata.paddx )

    self.updatefunction = self.updateSetPadding
    self.keypressfunction = self.keypressForTextInput
  end

  if ( key == "f6" ) then
    self.textInput = TextInput( "Frame Duration:", self.animdata.framedur )

    self.updatefunction = self.updateSetFrameDuration
    self.keypressfunction = self.keypressForTextInput
  end

  if ( key == "f7" ) then
    if ( Input:isKeyDown( "lctrl" ) ) then
      self:createAnimations()
    else
      self:createRects()
    end
  end

  if ( key == "f8" ) then
    self:showAnimations()
  end

  if ( key == "f11" ) then
    self:onExit()
    self.animationList:backFromEdit()
    return
  end

end

function AutoAnimator:keypressViewing( key )

  if ( key == "f8" ) then
    self.viewing = false
    self.viewindex = 1

    local cx, cy = self.game:getCamera():getPositionXY()

    self.cview = { cx, cy }

    self.game:getCamera():setPosition( self.cedit[1], self.cedit[2] )

    self.updatefunction = self.updategeneral
    self.keypressfunction = self.keypressgeneral
  end

  if ( key == "left" ) then
    self.viewindex = self.viewindex - 1

    if ( self.viewindex == 0 ) then
      self.viewindex = #self.animations
    end
  end

  if ( key == "right" ) then
    self.viewindex = self.viewindex + 1

    if ( self.viewindex > #self.animations ) then
      self.viewindex = 1
    end
  end

end

function AutoAnimator:createRects()
  self.rects = {}

  for i = 1, self.animdata.animcount do

    local posi = i - 1

    for j = 1, self.animdata.framecount do
      posj = j - 1

      local sx = self.animdata.startx + ( posj * self.animdata.framew ) + ( posj * self.animdata.paddx )
      local sy = self.animdata.starty + ( posi * self.animdata.frameh ) + ( posi * self.animdata.paddy )

      table.insert( self.rects,  { sx, sy, self.animdata.framew, self.animdata.frameh } )

    end

  end

end

function AutoAnimator:createAnimations()
  self.animations = {}

  if ( self.animdata.basename == "" )  then
    print( "Base Name not set" )
  end

  if ( #self.rects == 0 ) then
    return
  end

  local index = 1

  for i = 1, #self.rects, self.animdata.framecount do

    local anim = Animation( self.animdata.basename .. tostring( index ) )
    anim:setImage( self.animdata.image, self.animdata.resname )

    index = index + 1

    for j = i, i + self.animdata.framecount - 1 do

       anim:createFrame(
         self.animdata.framedur,
         self.rects[j][1],
         self.rects[j][2],
         self.rects[j][3],
         self.rects[j][4],
         self.imagew,
         self.imageh
       )
    end

    anim:start()

    table.insert( self.animations, anim )

  end

end

function AutoAnimator:showAnimations()
  if ( #self.animations == 0 ) then
    return
  end

  self.viewing = true
  self.viewindex = 1

  local cx, cy = self.game:getCamera():getPositionXY()

  self.cedit = { cx, cy }

  self.game:getCamera():setPosition( self.cview[1], self.cview[2] )

  self.updatefunction = self.updateViewing
  self.keypressfunction = self.keypressViewing
end

function AutoAnimator:clearInput()
  self.textInput = nil

  self.mode = 0

  self.updatefunction   = self.updategeneral
  self.keypressfunction = self.keypressgeneral
end

function AutoAnimator:keypressForTextInput( key )
  self.textInput:keypressed( key )
end

---- SET NAME ------------------------------------------------------------------

function AutoAnimator:updateSetName( dt )
  if ( self.textInput:isFinished() ) then

    local name = self.textInput:getText()

    if ( name ) then
      self.animdata.basename = name
    end

    self:clearInput()

  end
end

---- SELECT IMAGE --------------------------------------------------------------

function AutoAnimator:updateSelectImage( dt )
  if ( self.textInput:isFinished() ) then

    local resname, restype, respath = self.game:getResourceManager():getResourceByName( self.textInput:getText() )

    if ( restype == "image" ) then
      self.animdata.image   = self.game:getResourceManager():loadImage( respath )
      self.animdata.resname = resname

      self.imagew = self.animdata.image:getWidth()
      self.imageh = self.animdata.image:getHeight()
    end

    self:clearInput()
  end
end

----- ANIMATION START ----------------------------------------------------------

function AutoAnimator:updateSetStartPosition( dt )
  if ( self.textInput:isFinished() ) then

    local value = self.textInput:getText()

    if ( self.mode == 2 ) then
      if ( value ) then
        self.animdata.starty = tonumber( value )
      end

      self:clearInput()
    end

    if ( self.mode == 1 ) then
      if ( value ) then
        self.animdata.startx = tonumber( value )
      end

      self.textInput = TextInput( "Start Position Y:", self.animdata.starty )

      self.mode = 2
    end

  end
end

----- FRAME SIZE  --------------------------------------------------------------

function AutoAnimator:updateSetFrameSize( dt )
  if ( self.textInput:isFinished() ) then

    local value = self.textInput:getText()

    if ( self.mode == 2 ) then
      if ( value ) then
        self.animdata.frameh = tonumber( value )
      end

      self:clearInput()
    end

    if ( self.mode == 1 ) then
      if ( value ) then
        self.animdata.framew = tonumber( value )
      end

      self.textInput = TextInput( "Frame Height:", self.animdata.frameh )

      self.mode = 2
    end

  end
end

----- FRAMES PER ANIMATION -----------------------------------------------------

function AutoAnimator:updateSetFrameCount( dt )

  if ( self.textInput:isFinished() ) then

    local value = self.textInput:getText()

    if not tonumber( value ) then
      print( "Invalid duration value : " + strdur )
    else
      self.animdata.framecount = tonumber( value )
    end

    self:clearInput()
  end

end

----- PADDING  -----------------------------------------------------------------

function AutoAnimator:updateSetPadding( dt )
  if ( self.textInput:isFinished() ) then

    local value = self.textInput:getText()

    if ( self.mode == 2 ) then
      if ( value ) then
        self.animdata.paddy = tonumber( value )
      end

      self:clearInput()
    end

    if ( self.mode == 1 ) then
      if ( value ) then
        self.animdata.paddx = tonumber( value )
      end

      self.textInput = TextInput( "Padding Y:", self.animdata.paddy )

      self.mode = 2
    end

  end
end

----- FRAME DURATION  ----------------------------------------------------------

function AutoAnimator:updateSetFrameDuration( dt )

  if ( self.textInput:isFinished() ) then

    local value = self.textInput:getText()

    if not tonumber( value ) then
      print( "Invalid duration value : " + value )
    else
      self.animdata.framedur = tonumber( value )
    end

    self:clearInput()
  end

end
