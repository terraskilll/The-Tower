-------------------------------------------------------------------------------
-- gameobject base class
-------------------------------------------------------------------------------
require ("..engine.lclass")

local Vec = require("..engine.math.vector")

class "GameObject"

function GameObject:GameObject( instName, positionX, positionY )
  self.instancename = instName

  self.name = "Unnamed Game Object"
  self.tag  = "None"

  self.property = nil

  self.position = Vec( positionX, positionY )

  self.layer  = 1

  self.width  = 0
  self.height = 0

  self.scriptname   = nil
  self.scriptpath   = nil
  self.scriptloaded = false
end

function GameObject:getKind()
  return "GameObject"
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

function GameObject:getProperty()
  return self.property
end

function GameObject:setProperty( propertyToSet )
  self.property = propertyToSet
end

function GameObject:getLayer()
  return self.layer
end

function GameObject:setLayer( layerToSet )
  self.layer = layerToSet
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

function GameObject:setScript( scriptName, scriptPath )
  if ( scriptName == nil or scriptName == "" ) then
    self.scriptname = nil
    self.scriptpath = nil
  else
    self.scriptname = scriptName
    self.scriptpath = scriptPath
  end
end

function GameObject:loadScript()
  --//TODO test loadScript
  if ( self.scriptpath ) then
    local script = require( self.scriptpath )
    scriptsetup( self )

    self.scriptloaded = true
  end
end

function GameObject:unloadScript()
  if ( self.scriptloaded ) then
    package.loaded[self.scriptpath] = nil
  end
end

function GameObject:getScript()
  return self.scriptname, self.scriptpath
end

function GameObject:update( dt )
  print("default gameboject update method : need override")
end

function GameObject:draw()
  print("default gameboject draw method : need override")
end
