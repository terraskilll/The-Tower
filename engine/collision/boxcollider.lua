--https://love2d.org/wiki/PointWithinShape

require("../engine/lclass")
require("../engine/globalconf")

class "BoxCollider"

function BoxCollider:BoxCollider(x, y, w, h, offX, offY, s)
  self.positionX = x --//TODO use vector?
  self.positionY = y
  self.width     = w
  self.height    = h
  self.offsetX   = offX or 0
  self.offsetY   = offY or 0

  self.scale = s or 1
end

function BoxCollider:update(dt, ownerX, ownerY)
  self.positionX = ownerX
  self.positionY = ownerY
end

function BoxCollider:setScale(newScale)
  self.scale = newScale
end

function BoxCollider:changePosition( movementX, movementY )
  self.positionX = self.positionX + movementX
  self.positionY = self.positionY + movementY
end

function BoxCollider:setPosition( newX, newY )
  self.positionX = newX
  self.positionY = newY
end

function BoxCollider:draw()
  if ( glob.devMode.drawColliders ) then
    love.graphics.setColor(0, 255, 0)

    love.graphics.rectangle("line",
      self.positionX + self.offsetX * self.scale,
      self.positionY + self.offsetY * self.scale,
      self.width * self.scale,
      self.height * self.scale)

    love.graphics.setColor(glob.defaultColor)
  end
end

function BoxCollider:getKind()
  return "box"
end

function BoxCollider:getBounds()
  return
    self.positionX + self.offsetX * self.scale,
    self.positionY + self.offsetY * self.scale,
    self.width * self.scale,
    self.height * self.scale
end

function BoxCollider:addTrigger(newTrigger)
  table.insert(self.notifyList, newTrigger)
end

function BoxCollider:clone()
  return BoxCollider(self.positionX, self.positionY, self.width, self.height, self.offsetX, self.offsetY, self.scale)
end
