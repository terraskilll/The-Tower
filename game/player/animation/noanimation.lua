-- for testing purposes

require ("lclass")

require("../resources")
require("../engine/animation/animation")
require("../engine/animation/complexanimation")

class "NoAnimation" ("ComplexAnimation")

function NoAnimation:NoAnimation()
  self.animations = {}
  self:configure()
end

function NoAnimation:configure()
   local w = i_char:getWidth()
  local h = i_char:getHeight()
  
  local an = Animation()
  an:addFrame(1, 0, 0, 128, 128, w, h)

  self:addAnimation(an)

  self:setImage(i_char)
end