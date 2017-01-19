require("../engine/lclass")

class "State"

function State:State()
  self.animation = nil
  self.transitionRules = {}  
  self.fsm = nil
end

function State:setFSM(newFSM)
  self.fsm = newFSM
end

function State:onEnter()
end

function State:onUpdate(dt)
end

function State:onExit()
end

function State:onMessage(message)
end

function State:addTransitionRule(newRule)
  table.insert(self.transitionRules, newRule)
end

function State:setAnimation(newAnimation)
  self.animation = newAnimation
end

function State:getAnimation()
  return self.animation
end