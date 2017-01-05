require("lclass")

require("../resources")
require("../input")
require("../engine/ui/button/button")
require("../engine/ui/button/buttongroup")
require("../engine/screen/screen")
require("../engine/light/light")
require("../engine/gameobject/gameobject")
require("../engine/gameobject/staticimage")

require("../game/screen/playscreen")

class "MenuScreen" ("Screen")

function MenuScreen:MenuScreen(theGame)
  self.game = theGame
  self.menu = ButtonGroup()

  local startButton = Button(0, 0, "INICIAR", ib_uibutton1, 0.375)
  startButton:setAnchor(4, 15, 185)
  startButton.onButtonClick = self.startButtonClick

  local continueButton = Button(0, 0, "CONTINUAR", ib_uibutton1, 0.375)
  continueButton:setEnabled(false)
  continueButton:setAnchor(4, 15, 130)

  local optionsButton = Button(0, 0, "OPÇÕES", ib_uibutton1, 0.375)
  optionsButton:setAnchor(4, 15, 75)

  local exitButton = Button(0, 0, "SAIR", ib_uibutton1, 0.375)
  exitButton:setAnchor(4, 15, 20)
  exitButton.onButtonClick = self.exitButtonClick

  self.menu:addButton(startButton)
  self.menu:addButton(continueButton)
  self.menu:addButton(optionsButton)
  self.menu:addButton(exitButton)
end

function MenuScreen:onEnter()

end

function MenuScreen:onExit()
  
end

function MenuScreen:onKeyPress(key, scancode, isrepeat)

  if ( key == "return" or key == "kpenter") then
    self.menu:keyPressed( key, self )
  end

end

function MenuScreen:onKeyRelease(key, scancode, isrepeat)
	
end

function MenuScreen:update(dt)
  self.menu:update(dt)
end

function MenuScreen:draw()
  if (self.backgroundImage) then
    self.backgroundImage:draw(self.light)
  end

  self.menu:drawButtons()
end

function MenuScreen:joystickPressed(joystick, button)
	self.menu:joystickPressed(joystick, button, self)
end

function MenuScreen:startButtonClick(sender)
  local play = PlayScreen(sender.game)

  sender.game:setScreen(play)
end

function MenuScreen:exitButtonClick(sender)
  love.event.push("quit")
end