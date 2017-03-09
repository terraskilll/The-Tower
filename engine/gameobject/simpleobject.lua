--[[

a simple object class, for things like walls,
tables, chairs, trees and the like

TODO add shaders

]]--

require ("..engine.lclass")

local Vec = require("..engine.math/vector")

class "SimpleObject" ("GameObject")

function SimpleObject:SimpleObject( objectName, instName, positionX, positionY, objectSprite, drawQuad, objectScale )
  self.name         = objectName
  self.instancename = instName

  self.position = Vec( positionX, positionY )
  self.image    = objectSprite
  self.quad     = drawQuad or nil
  self.scale    = objectScale or 1

  self.width  = objectSprite:getWidth()
  self.height = objectSprite:getHeight()

  if ( self.quad ) then
    local _x, _y, ww, hh = self.quad:getViewport()

    self.width  = ww
    self.height = hh
  end

  self.animation   = nil

  self.collider    = nil
  self.boundingbox = nil
  self.navbox      = nil

  self.onCollisionEnter = nil
end

function SimpleObject:getKind()
  return "SimpleObject"
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

  if ( self.navbox ) then
    self.navbox:draw()
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

function SimpleObject:getScale()
  return self.scale
end

function SimpleObject:getQuad()

  if ( self.quad ) then
    local qx, qy, lx, ly = self.quad:getViewport()
    local qw, qh = self.quad:getTextureDimensions()

    return love.graphics.newQuad( qx, qy, lx, ly, qw, qh )
  else
    return nil
  end

end

function SimpleObject:getImage()
  return self.image
end

function SimpleObject:getAnimation()
  return self.animation
end

function SimpleObject:setCollider( colliderToSet )

  if ( colliderToSet ) then

    self.collider = colliderToSet

    self.collider:setOwner( self )
    self.collider:setScale( self.scale )

  end

end

function SimpleObject:getCollider()
  return self.collider
end

function SimpleObject:setBoundingBox( boundingboxToSet )
  if ( not boundingboxToSet) then
    return
  end

  self.boundingbox = boundingboxToSet
  self.boundingbox:setScale( self.scale )

end

function SimpleObject:getBoundingBox()
  return self.boundingbox
end

function SimpleObject:setNavBox( navboxToSet )
  if ( not navboxToSet) then
    return
  end

  self.navbox = navboxToSet
  self.navbox:setScale( self.scale )

end

function SimpleObject:getNavBox()
  return self.navbox
end

function SimpleObject:setAnimation( animationToSet )
  self.animation = animationToSet
end

function SimpleObject:setScale( scaleToSet )
  self.scale = scaleToSet or 1

  self.boundingbox:setScale( self.scale )
  self.navbox:setScale( self.scale )
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

  if ( self.navbox ) then
    self.navbox:setPosition( self.position.x, self.position.y )
  end

end

function SimpleObject:changePosition( movementVector )

  self.position = self.position + movementVector

  if ( self.collider ) then
    self.collider:changePosition( movementVector.x, movementVector.y )
  end

  if ( self.boundingbox ) then
    self.boundingbox:changePosition( movementVector )
  end

  if ( self.navbox ) then
    self.navbox:changePosition( movementVector )
  end

end

function SimpleObject:onCollisionEnter( otherCollider )
  -- nothing
end

function SimpleObject:clone( objectName, newInstanceName )

  local qd = nil

  if ( self.quad ) then
    local qx, qy, lx, ly = self.quad:getViewport()
    local qw, qh = self.quad:getTextureDimensions()

    qd = love.graphics.newQuad( qx, qy, lx, ly, qw, qh )
  end

  local cloned = SimpleObject( objectName, newInstanceName, self.position.x, self.position.y, self.image, qd, self.scale )

  if ( self.boundingbox ) then
    local bdbox = self.boundingbox:clone()
    cloned:setBoundingBox( bdbox )
  end

  if ( self.navbox ) then
    local navbox = self.navbox:clone()
    cloned:setNavBox( navbox )
  end

  if ( self.collider ) then
    local colld = self.collider:clone()
    cloned:setCollider( colld )
  end

  if ( self.animation ) then
    local animd = self.animation:clone()
    cloned:setAnimation( animd )
  end

  return cloned

end
