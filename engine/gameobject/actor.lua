--[[

an actor is a interactive object (player, npc, enemy)

]]
require("../engine/lclass")

require("../engine/navigation/navagent")
require("../engine/collision/boxcollider")
require("../engine/collision/circlecollider")
require("../engine/render/boundingbox")

local Vec = require("../engine/math/vector")

class "Actor" ("GameObject")

function Actor:Actor( actorName, positionX, positionY )
  self.name = actorName
  self.position  = Vec( positionX, positionY )

  self.navagent = nil
  self.navmap = nil
end

function Actor:getName()
  return self.name
end

function Actor:getPositionXY()
  return self.position.x, self.position.y
end

function Actor:getPosition()
  return self.position
end

function Actor:getNavAgent()
  return self.navagent
end

function Actor:setNavAgent( agentToSet, agentSpeed )
  self.navagent = agentToSet
  self.navagent:setSpeed( agentSpeed )
end

function Actor:setNavMap( navmapToSet )
  self.navmap = navmapToSet
end
