require("..engine.lclass")
require("..engine.animation/animation")

require("../resources")

require("../game/actors/player/animation/iddleanimation")
require("../game/actors/player/animation/noanimation") --//TODO

class "IddleState" ("State")

function IddleState:IddleState()
  self:configure()
end

function IddleState:onEnter()
  self.animation:start()
end

function IddleState:onUpdate(dt)
  --self.animation:update(dt) --//TODO
end

function IddleState:onExit()

end

function IddleState:onMessage(message)

end

function IddleState:configure()
  --self.animation = IddleAnimation() //TODO
  self.animation = NoAnimation()
  self.animation:setCurrentAnimation(1)
end
