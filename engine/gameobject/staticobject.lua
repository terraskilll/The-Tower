--[[

a simple object class, for imovable things like walls,
tables, chairs, trees and the like

TODO add shaders

]]--

require ("../engine/lclass")

local Vec = require("../engine/math/vector")

class "StaticObject" ("GameObject")

function StaticObject:StaticObject(positionX, positionY, objectSprite, drawQuad, objectScale)
  self.position = Vec(positionX, positionY)
  self.image    = objectSprite
  self.quad     = drawQuad or nil
  self.scale    = objectScale or 1

  self.animation   = nil

  self.collider    = nil
  self.boundingbox = nil
end

function StaticObject:update(dt)

  if ( self.animation ~= nil ) then
    self.animation:update(dt)
  end

end

function StaticObject:draw()
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
end

function StaticObject:drawStatic()

  if ( self.quad ) then
    love.graphics.draw(self.image, self.quad, self.position.x, self.position.y, 0, self.scale, self.scale)
  else
    love.graphics.draw(self.image, self.position.x, self.position.y, 0, self.scale, self.scale)
  end

end

function StaticObject:drawAnimated()
  self.animation:draw(self.position.x, self.position.y)
end

function StaticObject:setCollider(colliderToSet)
  self.collider = colliderToSet
  self.collider:setScale(self.scale)
end

function StaticObject:getCollider()
  return self.collider
end

function StaticObject:setBoundingBox(boundingboxToSet)
  self.boundingbox = boundingboxToSet
  self.boundingbox:setScale(self.scale)
end

function StaticObject:getBoundingBox()
  return self.boundingbox
end

function StaticObject:setAnimation(animationToSet)
  self.animation = animationToSet
end
