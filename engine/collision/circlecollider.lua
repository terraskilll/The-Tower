require("../engine/lclass")

require("../engine/globalconf")

class "CircleCollider"

function CircleCollider:CircleCollider(x, y, r, offX, offY, s)
  self.positionX = x
  self.positionY = y
  self.radius    = r
  self.offsetX   = offX or 0
  self.offsetY   = offY or 0
  self.scale     = s or 1
end

function CircleCollider:update(dt, ownerX, ownerY)
  self.positionX = ownerX
  self.positionY = ownerY
end

function CircleCollider:setScale(newScale)
  self.scale = newScale
end

function CircleCollider:draw()
  if ( glob.devMode.drawColliders ) then
    love.graphics.setColor(0, 255, 0)

    love.graphics.circle( "line",
      self.positionX + self.offsetX * self.scale,
      self.positionY + self.offsetY * self.scale,
      self.radius * self.scale)

    love.graphics.setColor(glob.defaultColor)
  end
end

function CircleCollider:changePosition( movementX, movementY )
  self.positionX = self.positionX + movementX
  self.positionY = self.positionY + movementY
end

function CircleCollider:setPosition( newX, newY )
  self.positionX = newX
  self.positionY = newY
end

function CircleCollider:getKind()
  return "circle"
end

function CircleCollider:getCenter()
  return
    self.positionX + self.offsetX * self.scale,
    self.positionY + self.offsetY * self.scale
end

function CircleCollider:getRadius()
  return self.radius * self.scale
end

function CircleCollider:addTrigger(newTrigger)
  table.insert(self.notifyList, newTrigger)
end

function CircleCollider:clone()
  return CircleCollider( self.positionX, self.positionY, self.radius, self.offsetX, self.offsetY, self.scale )
end
