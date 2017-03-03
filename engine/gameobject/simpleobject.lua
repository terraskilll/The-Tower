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

  self.width  = objectSprite:getWidth()
  self.height = objectSprite:getHeight()

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

  if ( self.animation ) then
    self:drawAnimated()
  else
    self:drawStatic()
  end

  if ( self.collider ) then
    self.collider:draw()
  end

  if ( self.boundingbox ) then
    self.boundingbox:draw()
  end

end

function SimpleObject:drawStatic()

  if ( self.quad ) then
    love.graphics.draw( self.image, self.quad, self.position.x, self.position.y, 0, self.scale, self.scale )
  else
    love.graphics.draw( self.image, self.position.x, self.position.y, 0, self.scale, self.scale )
  end

end

function SimpleObject:drawAnimated()
  self.animation:draw( self.position.x, self.position.y )
end

function SimpleObject:getDimensions()
  return self.width, self.height
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
  self.boundingbox:setScale( self.scale )
end

function SimpleObject:getBoundingBox()
  return self.boundingbox
end

function SimpleObject:setAnimation( animationToSet )
  self.animation = animationToSet
end

function SimpleObject:setScale( scaleToSet )
  self.scale = scaleToSet or 1

  self.boundingbox:setScale( self.scale )
  self.collider:setScale( self.scale )
end

function SimpleObject:setPosition( positionVector )
  self.position.x = positionVector.x
  self.position.y = positionVector.y

  if ( self.collider ) then
    self.collider:setPosition( self.position.x, self.position.y )
  end

  if ( self.boundingbox ) then
    self.boundingbox:setPosition( self.position.x, self.position.y )
  end
end

function SimpleObject:changePosition( movementVector )
  self.position = self.position + movementVector

  if ( self.collider ) then
    self.collider:changePosition( movementVector.x, movementVector.y )
  end

  if ( self.boundingbox ) then
    self.boundingbox:setPosition( self.position.x, self.position.y )
  end

end

function SimpleObject:onCollisionEnter( otherCollider )
  -- nothing
end

function SimpleObject:clone( newName )

  local qd = nil

  if ( self.quad ) then
    local qx, qy, lx, ly = self.quad:getViewport()
    local qw, qh = self.quad:getTextureDimensions()

    qd = love.graphics.newQuad( qx, qy, lx, ly, qw, qh )
  end

  local cloned = SimpleObject( newName, self.position.x, self.position.y, self.image, qd, self.scale )

  if ( self.boundingbox ) then
    local bdbox = self.boundingbox:clone()
    cloned:setBoundingBox( bdbox )
  end

  if ( self.collider ) then
    local colld = self.collider:clone()
    cloned:setCollider( colld )
  end

  return cloned

end
