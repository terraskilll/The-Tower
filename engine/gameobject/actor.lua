--[[

an actor is a interactive gameobject object (player, npc, enemy)

]]
require("../engine/lclass")

require("../engine/navigation/navagent")
require("../engine/collision/boxcollider")
require("../engine/collision/circlecollider")
require("../engine/render/boundingbox")

local Vec = require("../engine/math/vector")

class "Actor" ("GameObject")

function Actor:Actor( actorName, positionX, positionY )
  self.name      = actorName
  self.position  = Vec( positionX, positionY )

  self.map   = nil
  self.area  = nil
  self.floor = nil

  self.boundingbox = nil

  self.navagent = nil
  self.navmap   = nil
end

function Actor:setMap( newMap, newFloor, newArea, spawnPoint )
  self.map   = newMap
  self.floor = newFloor
  self.area  = newArea

  if ( self.navagent ) then
    self.navagent:setFloor( newFloor )
    self.navagent:setNavMesh( self.area:getNavMesh() )
  end

  if ( spawnPoint ~= nil ) then
    local pos = spawnPoint:getPosition()

    self:setPosition( pos.x, pos.y )
  end

end

function Actor:getMap()
  return self.map
end

function Actor:getArea()
  return self.area
end

function Actor:getFloor()
  return self.floor
end

function Actor:setFloor( floorToSet )
  self.floor = floorToSet
end

function Actor:getNavAgent()
  return self.navagent
end

function Actor:setNavAgent( agentToSet, agentSpeed )
  self.navagent = agentToSet
  self.navagent:setSpeed( agentSpeed )
end

function Actor:getBoundingBox()
  return self.boundingbox
end

function Actor:setBoundingBox( boundingBoxToSet )
  self.boundingbox = boundingBoxToSet
end

function Actor:setNavMap( navmapToSet )
  self.navmap = navmapToSet
end
