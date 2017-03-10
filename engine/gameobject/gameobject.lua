-------------------------------------------------------------------------------
-- gameobject base class
-------------------------------------------------------------------------------
require ("..engine.lclass")

local Vec = require("..engine.math/vector")

class "GameObject"

function GameObject:GameObject( instName, positionX, positionY )
  self.instancename = instName

  self.name = "Unnamed Game Object"
  self.tag  = "None"

  self.position = Vec( positionX, positionY )

  self.layer  = 1

  self.width  = 0
  self.height = 0
end

function GameObject:getName()
  return self.name
end

function GameObject:setName( nameToSet )
  self.name = nameToSet
end

function GameObject:getInstanceName()
  return self.instancename
end

function GameObject:setInstanceName( nameToSet )
  self.instancename = nameToSet
end

function GameObject:getTag()
  return self.tag
end

function GameObject:setTag( tagToSet )
  self.tag = tagToSet
end

function GameObject:getLayer()
  return self.layer
end

function GameObject:setLayer( layerToSet )
  self.layer = layerToSet
end

function GameObject:getKind()
  return "GameObject"
end

function GameObject:getPositionXY()
  return self.position.x, self.position.y
end

function GameObject:getPosition()
  return self.position
end

function GameObject:getDimensions()
  return self.width, self.height
end

function GameObject:setPosition( positionToSet )
  self.position:set( positionToSet.x, positionToSet.y )
end

function GameObject:update( dt )
  print("default gameboject update method : need override")
end

function GameObject:draw()
  print("default gameboject draw method : need override")
end
