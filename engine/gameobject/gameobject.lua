-------------------------------------------------------------------------------
-- gameobject base class
-------------------------------------------------------------------------------
require ("../engine/lclass")

local Vec = require("../engine/math/vector")

class "GameObject"

function GameObject:GameObject( positionX, positionY )
  self.position = Vec( positionX, positionY )
  self.name = "Unnamed Game Object"
  self.tag  = "None"
end

function GameObject:getName()
  return self.name
end

function GameObject:setName( newName )
  self.name = newName
end

function GameObject:getTag()
  return self.tag
end

function GameObject:setTag( newTag )
  self.tag = newTag
end

function GameObject:getPositionXY()
  return self.position.x, self.position.y
end

function GameObject:getPosition()
  return self.position
end

function GameObject:setPosition( newPosition )
  self.position:set( newPosition.x, newPosition.y )
end

function GameObject:update( dt )
  print("default gameboject update method : need override")
end

function GameObject:draw()
  print("default gameboject draw method : need override")
end
