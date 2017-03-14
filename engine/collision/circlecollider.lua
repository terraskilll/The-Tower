require("..engine.lclass")

require("..engine.globalconf")

class "CircleCollider"

function CircleCollider:CircleCollider( x, y, r, offX, offY, s )
  self.positionX = x
  self.positionY = y
  self.radius    = r
  self.offsetX   = offX or 0
  self.offsetY   = offY or 0
  self.scale     = s or 1

  self.solid = true

  self.owner = nil

  self.name = "Circle Collider "
end

function CircleCollider:update( dt )
  local xo, yo = self.owner:getPositionXY()

  self.positionX = xo
  self.positionY = yo
end

function CircleCollider:setOwner( newOwner )
  self.owner = newOwner
end

function CircleCollider:getOwner()
  return self.owner
end

function CircleCollider:setScale( newScale )
  self.scale = newScale
end

function CircleCollider:setSolid( isSolidCollider )
  self.solid = isSolidCollider
end

function CircleCollider:isSolid()
  return self.solid
end

function CircleCollider:draw()
  if ( glob.devMode.drawColliders ) then
    love.graphics.setColor(0, 255, 0)

    love.graphics.circle( "line",
      self.positionX + self.offsetX * self.scale,
      self.positionY + self.offsetY * self.scale,
      self.radius * self.scale)

    love.graphics.setColor( glob.defaultColor )
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

function CircleCollider:collisionEnter( otherCollider )

  if ( self:getOwner() == nil )  then
    print(self.name .. " has no owner")
    return
  end

  if ( self.owner.onCollisionEnter ) then
    self.owner:onCollisionEnter( otherCollider )
  end

end

function CircleCollider:getBounds()
  return
      self.positionX + self.offsetX - self.radius * self.scale,
      self.positionY + self.offsetY - self.radius * self.scale,
      self.radius * 2,
      self.radius * 2
end

function CircleCollider:clone()
  local colld = CircleCollider( self.positionX, self.positionY, self.radius, self.offsetX, self.offsetY, self.scale )
  colld:setSolid( self:isSolid() )
  return colld
end
