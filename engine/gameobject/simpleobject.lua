--[[

a simple object class, for things like walls,
tables, chairs, trees and the like

TODO add shaders

]]--

require ("../engine/lclass")

local Vec = require("../engine/math/vector")

class "SimpleObject" ("GameObject")

function SimpleObject:SimpleObject( objectName, positionX, positionY, objectSprite, drawQuad, objectScale )
  self.name     = objectName

  self.position = Vec(positionX, positionY)
  self.image    = objectSprite
  self.quad     = drawQuad or nil
  self.scale    = objectScale or 1

  self.animation   = nil

  self.collider    = nil
  self.boundingbox = nil

  self.onCollisionEnter = nil
end

function SimpleObject:update( dt )

  if ( self.animation ~= nil ) then
    self.animation:update( dt )
  end

end

function SimpleObject:draw()

  if ( self.animation ~= nil ) then
    self:drawAnimated()
  else
    self:drawStatic()
  end

  if ( self.collider ~= nil ) then
    self.collider:draw()
  end

  if ( self.boundingbox ~= nil) then
    self.boundingbox:draw()
  end

  if ( self.navmesh ~= nil) then
    self.navmesh:draw()
  end
end

function SimpleObject:drawStatic()

  if ( self.quad ) then
    love.graphics.draw(self.image, self.quad, self.position.x, self.position.y, 0, self.scale, self.scale)
  else
    love.graphics.draw(self.image, self.position.x, self.position.y, 0, self.scale, self.scale)
  end

end

function SimpleObject:drawAnimated()
  self.animation:draw(self.position.x, self.position.y)
end

function SimpleObject:setCollider( colliderToSet )
  self.collider = colliderToSet

  self.collider:setOwner( self )
  self.collider:setScale( self.scale )
end

function SimpleObject:getCollider()
  return self.collider
end

function SimpleObject:setBoundingBox( boundingboxToSet )
  self.boundingbox = boundingboxToSet
  self.boundingbox:setScale(self.scale)
end

function SimpleObject:getBoundingBox()
  return self.boundingbox
end

function SimpleObject:setAnimation( animationToSet )
  self.animation = animationToSet
end

function SimpleObject:changePosition( movementVector )
  self.position = self.position + movementVector

  if ( self.collider ~= nil ) then
    self.collider:changePosition( movementVector.x, movementVector.y )
  end

  if ( self.boundingbox ~= nil) then
    self.boundingbox:setPosition( self.position.x, self.position.y )
  end

end

function SimpleObject:onCollisionEnter( otherCollider )

end
