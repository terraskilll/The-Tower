require("../engine/lclass")
require("../engine/input")
require("../engine/io/io")
require("../engine/resourcemanager")

require("../editor/textinput")

local absfun = math.abs

class "ObjectEditor"

local generalOptions = {
  "Numpad '+/-' - Change Inc Modifier",
  "F8 - Toogle View All/View Quad",
  "F9 - Save",
  "F11 - Back"
}

local mainOptions = {
  "F1 - Select Resource",
  "F2 - Edit Quad",
  "F3 - Edit Bounding Box",
  "F4 - Edit Nav Box",
  "F5 - Edit Collider",
  "F6 - Set Animation"
}

local quadOptions = {
  "Numpad 5 - Use all image",
  "Numpad 2,4,6,8 - Increase on direction",
  "Numpad+Ctrl - Decrease on direction",
  "Up,Down,Left, Right - Move"
}

local boundingboxOptions = {
  "Numpad 5 - Use all image",
  "Numpad 2,4,6,8 - Increase on direction",
  "Numpad+Ctrl - Decrease on direction"
}

local navboxOptions = {
  "Numpad 5 - Use all image",
  "Numpad 2,4,6,8 - Increase on direction",
  "Numpad+Ctrl - Decrease on direction"
}

local colliderOptions = {
  "Numpad 5 - Use all image",
  "Numpad 2,4,6,8 - Increase on direction",
  "Numpad+Ctrl - Decrease on direction",
  "C - Change collider type",
  "R - Change radius (circle only)"
}

local options = mainOptions

function ObjectEditor:ObjectEditor( objectListOwner, objectIndex, objectName, thegame )
  self.game = thegame

  self.objectList = objectListOwner

  self.index = objectIndex
  self.name  = objectName

  self.showQuad = true

  self.mode = 0

  self.incModifier = 1

  self.object = nil

  self.textInput = nil

  self:loadObjectWithName( objectName )

  self.updatefunction = self.updategeneral
  self.keypressfunction = self.keypressgeneral
end

function ObjectEditor:onEnter()
  print("Entered ObjectEditor")

  self.game:getCamera():move( -300, -100 )
end

function ObjectEditor:onExit()
  self.game:getCamera():setPosition( 0, 0 )
end

function ObjectEditor:draw()
  if ( self.textInput ) then
    self.textInput:draw()
    return
  end

  for i = 1, #options do
    love.graphics.print( options[i], 16, (i * 16) + 40 )
  end

  for i = 1, #generalOptions do
    love.graphics.print( generalOptions[i], 16, (i * 16) + 350 )
  end

  love.graphics.print( "Inc Modifier: " .. self.incModifier, 16, 300 )

  love.graphics.setColor( 150, 150, 255, 100 )

  love.graphics.line( 299, 0, 299, 2000 )
  love.graphics.line( 299, 99, 2000, 99 )

  love.graphics.setColor( glob.defaultColor )

  self:drawObject()
end

function ObjectEditor:drawObject()
  if ( self.object == nil ) then
    return
  end

  self.game:getCamera():set()

  if ( self.showQuad == true ) then
    if ( self.object.quad ) then
      love.graphics.draw( self.image, self.object.quad, 0, 0, 0, self.object.scale, self.object.scale )

      local x, y = self.object.quaddata[1], self.object.quaddata[2]
      local w, h = self.object.quaddata[3], self.object.quaddata[4]

      love.graphics.setColor( 255, 100, 100, 200 )
      love.graphics.rectangle( "line", x, y, w, h )
      love.graphics.setColor( glob.defaultColor )
    else
      love.graphics.draw( self.image, 0, 0, 0, self.object.scale, self.object.scale )
    end

  else
    love.graphics.draw( self.image, 0, 0, 0, self.object.scale, self.object.scale )
  end

  if  ( self.object.boundingbox ) then
    self.object.boundingbox:draw()
  end

  if  ( self.object.navbox ) then
    self.object.navbox:draw()
  end

  if  ( self.object.collider ) then
    self.object.collider:draw()
  end

  self.game:getCamera():unset()

end

function ObjectEditor:update(dt)

  self:updatefunction( dt )

end

function ObjectEditor:updategeneral(dt)

end

function ObjectEditor:updateGetResource( dt )
  if ( self.textInput:isFinished() ) then

    local resname, restype, respath = self.game:getResourceManager():getResourceByName( self.textInput:getText() )

    if ( restype == "image" ) then
      self.image = self.game:getResourceManager():loadImage( respath )

      self.object = {}
      self.object.resourcename = resname

      self.object.scale       = 1
      self.object.quad        = nil
      self.object.boundingbox = nil
      self.object.navbox      = nil
      self.object.collider    = nil

      local w, h = self.image:getWidth(), self.image:getHeight()

      self.object.quaddata = { 0, 0, w, h, w, h }

      self.object.bboxdata = { 0, 0, w, h, 0, 0, 0, 1 }

      self.object.navboxdata = { 0, 0, w, h, 0, 0, 1 }

      self.object.colldata = { 0, 0, w, h, 0, 0, 1, w / 2 } -- last parameter is radius for circle

      self.object.colltype = "box"
    end

    self.textInput = nil

    self.mode = 0

    self.updatefunction   = self.updategeneral
    self.keypressfunction = self.keypressgeneral
  end
end

function ObjectEditor:updateEditQuad( dt )
end

function ObjectEditor:updateEditBoundingBox( dt )

end

function ObjectEditor:updateEditNavBox( dt )

end

function ObjectEditor:updateEditCollider( dt )

end

function ObjectEditor:doTextInput ( t )

  if ( self.textInput ) then
    self.textInput:input( t )
  end

end

function ObjectEditor:onKeyPress( key, scancode, isrepeat )

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

  if ( key == "f8" ) then
    self.showQuad = not self.showQuad

    return
  end

  if ( key == "f9" ) then
    self:saveObject( self.name )

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

function ObjectEditor:keypressgeneral( key )

  if ( self.mode == 1 ) then
    self.textInput:keypressed( key )
    return
  end

  if ( key == "f1" ) then
    self.mode = 1

    self.textInput = TextInput("Resource Name: ")

    self.updatefunction = self.updateGetResource

    return
  end

  if ( key == "f2" ) then
    self.mode = 2

    options = quadOptions

    local d = self.object.quaddata

    self.object.quad = love.graphics.newQuad( d[1], d[2], d[3], d[4], d[5], d[6] )

    self.updatefunction   = self.updateEditQuad
    self.keypressfunction = self.keypressEditQuad

    return
  end

  if ( key == "f3" ) then
    self.mode = 4

    options = boundingboxOptions

    local bb = self.object.bboxdata

    if ( self.object.quad ) then
      self.object.boundingbox = BoundingBox( bb[1], bb[2], self.object.quaddata[3], self.object.quaddata[4], bb[5], bb[6], bb[7], bb[8] )
    else
      self.object.boundingbox = BoundingBox( bb[1], bb[2], bb[3], bb[4], bb[5], bb[6], bb[7], bb[8] )
    end

    self.updatefunction   = self.updateEditBoundingBox
    self.keypressfunction = self.keypressEditBoundingBox

    return
  end

  if ( key == "f4" ) then
    self.mode = 7

    options = navboxOptions

    local nb = self.object.navboxdata

    --local nb = NavBox(1,2,3,4,5,6,7)

    if ( self.object.quad ) then
      self.object.navbox = NavBox( nb[1], nb[2], self.object.quaddata[3], self.object.quaddata[4], nb[5], nb[6], nb[7] )
    else
      self.object.navbox = NavBox( nb[1], nb[2], nb[3], nb[4], nb[5], nb[6], nb[7] )
    end

    self.updatefunction   = self.updateEditNavBox
    self.keypressfunction = self.keypressEditNavBox

    return
  end

  if ( key == "f5" ) then
    self.mode = 5

    options = colliderOptions

    local cd = self.object.colldata

    if ( self.object.colltype == "box" ) then

      if ( self.object.quad ~= nil) then
        self.object.collider = BoxCollider(cd[1], cd[2], self.object.quaddata[3], self.object.quaddata[4], cd[5], cd[6], cd[7])
      else
        self.object.collider = BoxCollider(cd[1], cd[2], cd[3], cd[4], cd[5], cd[6], cd[7])
      end

    else

      if ( self.object.quad ) then
        self.object.collider = CircleCollider( cd[1], cd[2], self.object.quaddata[3], self.object.quaddata[4], cd[5], cd[6], cd[7] )
      else
        self.object.collider = CircleCollider( cd[1], cd[2], cd[3], cd[4], cd[5], cd[6], cd[7] )
      end

    end

    self.updatefunction   = self.updateEditCollider
    self.keypressfunction = self.keypressEditCollider

    return
  end

  if ( key == "f6" ) then

    self.mode = 6

    self.textInput = TextInput("Animation Name: ")

    self.updatefunction   = self.updateSetAnimation
    self.keypressfunction = self.keypressSetAnimation

    return
  end

  if ( key == "f11") then
    self.objectList:backFromEdit()
    return
  end

end

function ObjectEditor:keypressEditQuad ( key )
  if ( key == "kp5" ) then
    local w, h = self.image:getWidth(), self.image:getHeight()

    self.object.quaddata = { 0, 0, w, h, w, h }

    self.object.quad = love.graphics.newQuad( 0, 0, w, h, w, h )
  end

  local inc = 1

  if ( Input:isKeyDown("lctrl") ) then
    inc = -1
  end

  inc = inc * self.incModifier

  if  ( key == "kp2" ) then -- h
    self.object.quaddata[4] = self.object.quaddata[4] + inc
  end

  if  ( key == "kp4" ) then -- x, w
    self.object.quaddata[1] = self.object.quaddata[1] - inc
    self.object.quaddata[3] = self.object.quaddata[3] + inc
  end

  if  ( key == "kp6" ) then -- w
    self.object.quaddata[3] = self.object.quaddata[3] + inc
  end

  if  ( key == "kp8" ) then -- y, h
    self.object.quaddata[2] = self.object.quaddata[2] - inc
    self.object.quaddata[4] = self.object.quaddata[4] + inc
  end

  if  ( key == "left" ) then -- x
    inc = absfun(inc)

    self.object.quaddata[1] = self.object.quaddata[1] - inc
  end

  if  ( key == "right" ) then -- x
    inc = absfun(inc)

    self.object.quaddata[1] = self.object.quaddata[1] + inc
  end

  if  ( key == "up" ) then -- x
    inc = absfun(inc)

    self.object.quaddata[2] = self.object.quaddata[2] - inc
  end

  if  ( key == "down" ) then -- x
    inc = absfun(inc)

    self.object.quaddata[2] = self.object.quaddata[2] + inc
  end

  local qd = self.object.quaddata

  self.object.quad = love.graphics.newQuad( qd[1], qd[2], qd[3], qd[4], qd[5], qd[6] )
end

function ObjectEditor:keypressEditBoundingBox ( key )
  if ( key == "kp5" ) then
    local w, h = self.image:getWidth(), self.image:getHeight()

    if ( self.object.quad ) then
      self.object.bboxdata = {0, 0, self.object.quaddata[3], self.object.quaddata[4], 0, 0, 0, 1}
    else
      self.object.bboxdata = {0, 0, w, h, 0, 0, 0, 1}
    end

  end

  local inc = 1

  if ( Input:isKeyDown("lctrl") ) then
    inc = -1
  end

  inc = inc * self.incModifier

  if  ( key == "kp2" ) then -- h
    self.object.bboxdata[4] = self.object.bboxdata[1] + inc
  end

  if  ( key == "kp4" ) then -- off x, w
    self.object.bboxdata[6] = self.object.bboxdata[6] - inc
    self.object.bboxdata[3] = self.object.bboxdata[3] + inc
  end

  if  ( key == "kp6" ) then -- w
    self.object.bboxdata[3] = self.object.bboxdata[3] + inc
  end

  if  ( key == "kp8" ) then -- off y, h
    self.object.bboxdata[7] = self.object.bboxdata[7] - inc
    self.object.bboxdata[4] = self.object.bboxdata[4] + inc
  end

  if  ( key == "left" ) then -- off x
    inc = absfun(inc)

    self.object.bboxdata[6] = self.object.bboxdata[6] - inc
  end

  if  ( key == "right" ) then -- off x
    inc = absfun(inc)

    self.object.bboxdata[6] = self.object.bboxdata[6] + inc
  end

  if  ( key == "up" ) then -- off y
    inc = absfun(inc)

    self.object.bboxdata[7] = self.object.bboxdata[7] - inc
  end

  if  ( key == "down" ) then -- off y
    inc = absfun(inc)

    self.object.bboxdata[7] = self.object.bboxdata[7] + inc
  end

  local bb = self.object.bboxdata

  self.object.boundingbox = BoundingBox( unpack( bb ) )

  --self.object.boundingbox = BoundingBox( bb[1], bb[2], bb[3], bb[4], bb[5], bb[6], bb[7], bb[8] )
end

function ObjectEditor:keypressEditNavBox ( key )
  if ( key == "kp5" ) then
    local w, h = self.image:getWidth(), self.image:getHeight()

    if ( self.object.quad ) then
      self.object.navboxdata = {0, 0, self.object.quaddata[3], self.object.quaddata[4], 0, 0, 1}
    else
      self.object.navboxdata = {0, 0, w, h, 0, 0, 1}
    end

  end

  local inc = 1

  if ( Input:isKeyDown("lctrl") ) then
    inc = -1
  end

  inc = inc * self.incModifier

  if  ( key == "kp2" ) then -- h
    self.object.navboxdata[4] = self.object.navboxdata[1] + inc
  end

  if  ( key == "kp4" ) then -- off x, w
    self.object.navboxdata[5] = self.object.navboxdata[5] - inc
    self.object.navboxdata[3] = self.object.navboxdata[3] + inc
  end

  if  ( key == "kp6" ) then -- w
    self.object.navboxdata[3] = self.object.navboxdata[3] + inc
  end

  if  ( key == "kp8" ) then -- off y, h
    self.object.navboxdata[6] = self.object.navboxdata[6] - inc
    self.object.navboxdata[4] = self.object.navboxdata[4] + inc
  end

  if  ( key == "left" ) then -- off x
    inc = absfun(inc)

    self.object.navboxdata[5] = self.object.navboxdata[5] - inc
  end

  if  ( key == "right" ) then -- off x
    inc = absfun(inc)

    self.object.navboxdata[5] = self.object.navboxdata[5] + inc
  end

  if  ( key == "up" ) then -- off y
    inc = absfun(inc)

    self.object.navboxdata[6] = self.object.navboxdata[6] - inc
  end

  if  ( key == "down" ) then -- off y
    inc = absfun(inc)

    self.object.navboxdata[6] = self.object.navboxdata[6] + inc
  end

  local nb = self.object.navboxdata

  self.object.navbox = NavBox( unpack( nb ) )
end

function ObjectEditor:keypressEditCollider ( key )
  if ( key == "kp5" ) then
    local w, h = self.image:getWidth(), self.image:getHeight()

    if ( self.object.quad ) then
      self.object.colldata = {0, 0, self.object.quaddata[3], self.object.quaddata[4], 0, 0, 1, self.object.quaddata[3] / 2 } -- last parameter is radius for circle
    else
      self.object.colldata = {0, 0, w, h, 0, 0, 1, w / 2} -- last parameter is radius for circle
    end

  end

  local inc = 1

  if ( Input:isKeyDown("lctrl") ) then
    inc = -1
  end

  inc = inc * self.incModifier

  if  ( key == "kp2" ) then -- h
    self.object.colldata[4] = self.object.colldata[4] + inc
  end

  if  ( key == "kp4" ) then -- off x, w
    self.object.colldata[5] = self.object.colldata[5] - inc
    self.object.colldata[3] = self.object.colldata[3] + inc
  end

  if  ( key == "kp6" ) then -- w
    self.object.colldata[3] = self.object.colldata[3] + inc
  end

  if  ( key == "kp8" ) then -- off y, h
    self.object.colldata[6] = self.object.colldata[6] - inc
    self.object.colldata[4] = self.object.colldata[4] + inc
  end

  if  ( key == "left" ) then -- off x
    inc = absfun(inc)

    self.object.colldata[5] = self.object.colldata[5] - inc
  end

  if  ( key == "right" ) then -- off x
    inc = absfun(inc)

    self.object.colldata[5] = self.object.colldata[5] + inc
  end

  if  ( key == "up" ) then -- off y
    inc = absfun(inc)

    self.object.colldata[6] = self.object.colldata[6] - inc
  end

  if  ( key == "down" ) then -- off y
    inc = absfun(inc)

    self.object.colldata[6] = self.object.colldata[6] + inc
  end

  if  ( key == "c" ) then -- change type

    if ( self.object.colltype == "box" ) then
      self.object.colltype = "circle"
    else
      self.object.colltype = "box"
    end

  end

  if  ( key == "r" ) then -- radius
    self.object.colldata[8] = self.object.colldata[8] + inc
  end

  local cd = self.object.colldata

  if ( self.object.colltype == "box" ) then
    self.object.collider = BoxCollider(  cd[1], cd[2], cd[3], cd[4], cd[5], cd[6], cd[7] )
  else

    self.object.collider = CircleCollider( cd[1], cd[2], cd[8], cd[5], cd[6], cd[7] )
  end

end

function ObjectEditor:updateSetAnimation( dt )
  if ( self.textInput:isFinished() ) then

    local animationname = self.textInput:getText()

    if ( animationname ~= "" ) then

      if ( self.game:getAnimationManager():check( animationname ) ) then
        print("Added a animation")
        self.object.animationname = animationname
      end

    end

    self.textInput = nil

    self.mode = 0

    self.updatefunction   = self.updategeneral
    self.keypressfunction = self.keypressgeneral
  end
end

function ObjectEditor:keypressSetAnimation( key )
  self.textInput:keypressed( key )
end

---- LOAD / SAVE ---------------------------------------------------------------

function ObjectEditor:saveObject( objectFileName )
  saveFile( "__objects/" .. objectFileName, self.object )

  print( "Saved " .. self.name )
end

function ObjectEditor:loadObjectWithName( objectFileName )

  local obdata = self.game:getObjectManager():loadObjectData( objectFileName )

  if ( obdata ) then
    self.object = obdata

    local resname, restype, respath = self.game:getResourceManager():getResourceByName( self.object.resourcename )

    self.image = self.game:getResourceManager():loadImage( respath )

    if ( self.object.quaddata ) then
      local qd = self.object.quaddata

      self.object.quad = love.graphics.newQuad( qd[1], qd[2], qd[3], qd[4], qd[5], qd[6] )
    end

    if ( self.object.bboxdata ) then
      local bb = self.object.bboxdata

      self.object.boundingbox = BoundingBox( unpack( bb ) )
    end

    if ( self.object.navboxdata ) then
      local nb = self.object.navboxdata

      self.object.navbox = NavBox( unpack ( nb ) )
    end

    if ( self.object.colldata ) then
      local cd = self.object.colldata

      if ( self.object.colltype == "box" ) then
        self.object.collider = BoxCollider( cd[1], cd[2], cd[3], cd[4], cd[5], cd[6], cd[7] )
      else
        self.object.collider = CircleCollider( cd[1], cd[2], cd[8], cd[5], cd[6], cd[7] )
      end
    end

    print( "Loaded " .. objectFileName )
  end
end
