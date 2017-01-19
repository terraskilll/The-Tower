require("../engine/lclass")

require("../engine/fsm/state")

class "FSM"

function FSM:FSM()
  self.states = {}
  self.currentState = nil
end

function FSM:getCurrent()
  return self.currentState
end

function FSM:pushState(newState)
  table.insert(self.states, newState)
  newState:setFSM(self)
  return newState
end

function FSM:popState()
  local state = self.states[#self.states]
  table.remove(self.states, #self.states)
  return state
end

function FSM:setCurrentState(newCurrentState)
  self.currentState = newCurrentState
end

function FSM:start()
  self.currentState:onEnter()
end