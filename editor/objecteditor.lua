require("../engine/lclass")
require("../engine/io/io")
require("../engine/resourcemanager")

require("../editor/textinput")

class "ObjectEditor"

local generalOptions = {
  "F1 - Select Resource",
  "F2 - Edit Quad",
  "F3 - Edit Scale",
  "",
  "F4 - Edit Bounding Box",
  "F5 - Edit Collider",
  "F8 - Toogle View All/View Quad",
  "F9 - Save",
  "F11 - Back"
}

local quadOptions = {
  "Numpad 5 - Use all image",
  "Numpad 2,4,6,8 - Increase on direction",
  "Numpad+Ctrl - Decrease on direction",
  "Numpad+Ctrl - Increase/Decrease by 10",
  "Up,Down,Left, Right - Move"
}

local scaleOptions = {
  "Numpad 1 - 1:1 Scale",
  "Numpad 2 - Double Current",
  "Numpad 0 - Half Current",
  "F1 - Set Specific Value",
}

local boundingboxOptions = {
  "Numpad 5 - Use all image",
  "Numpad 2,4,6,8 - Increase on direction",
  "Numpad+Ctrl - Decrease on direction",
  "Numpad+Ctrl - Increase/Decrease by 10"
}

local colliderOptions = {
  "Numpad 5 - Use all image",
  "Numpad 2,4,6,8 - Increase on direction",
  "Numpad+Ctrl - Decrease on direction",
  "Numpad+Ctrl - Increase/Decrease by 10"
}

local options = generalOptions

function ObjectEditor:ObjectEditor( objectListOwner, objectIndex, objectName, objectData )
  self.objectList = objectListOwner

  self.index = objectIndex
  self.name  = objectName
  self.data  = objectData

  self.showQuad = false

  self.mode = 0

  self.resourceManager = ResourceManager()

  self.object = nil

  self.textInput = nil

  self.updatefunction = self.updateNone
  self.keypressfunction = self.keypressNone
end

function ObjectEditor:onEnter()
  print("Entered ObjectEditor")
end

function ObjectEditor:onExit()
  self.resmanager = nil
end

function ObjectEditor:draw()
  if ( self.mode == 1 ) then
    self.textInput:draw()
    return
  end

  for i = 1, #options do
    love.graphics.print(options[i], 16, (i * 16) + 40)
  end

  love.graphics.line(299, 0, 299, 2000)
  love.graphics.line(299, 99, 2000, 99)

  if ( self.object ~= nil ) then
    if ( self.showQuad == true ) then

      if ( self.object.quad ~= nil ) then
        love.graphics.draw(self.object.image, self.object.quad, 300, 100, 0, self.object.scale, self.object.scale)

        local x, y = self.object.quadrect[1], self.object.quadrect[2]
        local w, h = self.object.quadrect[3], self.object.quadrect[4]

        love.graphics.setColor(255, 80, 80, 80)
        love.graphics.rectangle("line", x, y, w, h)
        love.graphics.setColor(glob.defaultColor)
      else
        love.graphics.draw(self.object.image, 300, 100, 0, self.object.scale, self.object.scale)
      end

    else
      love.graphics.draw(self.object.image, 300, 100, 0, self.object.scale, self.object.scale)
    end

    if  ( self.object.boundingbox ~= nil ) then
      self.object.boundingbox:draw()
    end

    if  ( self.object.collider ~= nil ) then
      self.object.collider:draw()
    end

  end
end

function ObjectEditor:update(dt)
  self:updatefunction( dt )

--[[
  if ( self.mode == 1 ) then
    self:updateGetResource()
  end

  if ( self.mode == 2 ) then
    self:updateEditQuad()
  end

  if ( self.mode == 3 ) then
    self:updateEditScale()
  end

  if ( self.mode == 4 ) then
    self:updateEditBoundinBox()
  end

  if ( self.mode == 5 ) then
    self:updateEditCollider()
  end
]]

end

function ObjectEditor:updateNone(dt)

end

function ObjectEditor:updateGetResource(dt)
  if ( self.textInput:isFinished() ) then

    local resname, restype, respath = self.resourceManager:getResourceByName(self.textInput:getText())

    if ( restype == "image" ) then
      self.object = {}
      self.object.resourceName = resname
      self.object.resourceType = restype
      self.object.resourcePath = respath

      self.object.image       = self.resourceManager:loadImage(respath)
      self.object.scale       = 1
      self.object.quad        = nil
      self.object.quadrect    = nil
      self.object.boundingbox = nil
      self.object.collider    = nil
    end

    self.textInput = nil

    self.mode = 0

    self.updatefunction   = self.updateNone
    self.keypressfunction = self.keypressNone
  end
end

function ObjectEditor:updateEditQuad(dt)

end

function ObjectEditor:updateEditScale(dt)

end

function ObjectEditor:updateEditBoundinBox(dt)

end

function ObjectEditor:updateEditCollider(dt)

end

function ObjectEditor:doTextInput ( t )

  if ( self.textInput ~= nil ) then
    self.textInput:input( t )
  end

end

function ObjectEditor:onKeyPress(key, scancode, isrepeat)

  self:keypressfunction( key )

end

function ObjectEditor:keypressNone( key )

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

    local w, h = self.object.image:getWidth(), self.object.image:getHeight()

    self.object.quad = love.graphics.newQuad( 0, 0, w, h, w, h )

    self.object.quadrect = { 0, 0, w, h }

    self.updatefunction = self.updateEditQuad
    self.keypressfunction = self.keypressEditQuad

    return
  end

  if ( key == "f3" ) then
    self.mode = 3

    options = scaleOptions

    self.updatefunction = self.updateEditScale
    self.keypressfunction = self.keypressEditScale

    return
  end

  if ( key == "f4" ) then
    self.mode = 4

    options = boundingboxOptions

    self.updatefunction = self.updateEditBoundinBox
    self.keypressfunction = self.keypressEditBoundinBox

    return
  end

  if ( key == "f5" ) then
    self.mode = 5

    options = colliderOptions

    self.updatefunction = self.updateEditCollider
    self.keypressfunction = self.keypressEditCollider

    return
  end

  if ( key == "f8" ) then
    self.showQuad = not self.showQuad

    return
  end

  if ( key == "f9" ) then
    self:saveObject()

    return
  end

  if ( key == "f11") then
    self.objectList:backFromEdit()
    return
  end

end

function ObjectEditor:keypressEditQuad ( key )

end

function ObjectEditor:keypressEditScale ( key )

end

function ObjectEditor:keypressEditBoundinBox ( key )

end

function ObjectEditor:keypressEditCollider ( key )

end

function ObjectEditor:saveObject()
  print("save to a file")
end
