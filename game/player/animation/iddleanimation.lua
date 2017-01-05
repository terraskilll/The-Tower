require ("lclass")

require("../resources")
require("../engine/animation/animation")
require("../engine/animation/complexanimation")

class "IddleAnimation" ("ComplexAnimation")

function IddleAnimation:IddleAnimation()
  self.animations = {}
  self:configure()
end

function IddleAnimation:configure()
  -- a big clunky method
  -- TODO: get better
 
  local w = i_character:getWidth()
  local h = i_character:getHeight()
  
  local toSouth = Animation()
  toSouth:addFrame(1, 60, 30, 158, 342, w, h)

  local toWest = Animation()
  toWest:addFrame(1, 268, 70, 158, 342, w, h)
  
  local toNorth = Animation()
  toNorth:addFrame(1, 476, 30, 158, 342, w, h)

  self:addAnimation(toSouth)
  self:addAnimation(toWest)
  self:addAnimation(toNorth)

  self:setImage(i_character)
end