require("../engine/lclass")
require("../engine/animation/animation")
require("../game/actors/player/animation/walkinganimation")

require("../resources")

class "WalkingState" ("State")

function WalkingState:WalkingState(o)
  self:configure()
end

function WalkingState:onEnter()
  self.animation:start()
end

function WalkingState:onUpdate(dt)
  self.animation:update(dt)
end

function WalkingState:onExit()

end

function WalkingState:onMessage(message)

end

function WalkingState:configure()
  --self.animation = WalkingAnimation() --//TODO
  self.animation = NoAnimation()
  self.animation:setCurrentAnimation(1)
end
