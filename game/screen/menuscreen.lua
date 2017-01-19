require("../engine/lclass")

require("../engine/input")
require("../editor/editor")
require("../engine/ui/uigroup")
require("../engine/ui/button/button")
require("../engine/ui/selector/selector")
require("../engine/screen/screen")
require("../engine/light/light")
require("../engine/gameobject/gameobject")
require("../engine/gameobject/staticimage")

require("../resources")

require("../game/screen/playscreen")

class "MenuScreen" ("Screen")

function MenuScreen:MenuScreen(theGame)
  self.game = theGame

  self.inMainMenu = true

  self.mainMenu = UIGroup()

  local startButton = Button(0, 0, "INICIAR", ib_uibutton1, 0.375)
  startButton:setAnchor(4, 15, 185)
  startButton.onButtonClick = self.startButtonClick

  local continueButton = Button(0, 0, "CONTINUAR", ib_uibutton1, 0.375)
  continueButton:setEnabled(false)
  continueButton:setAnchor(4, 15, 130)

  local optionsButton = Button(0, 0, "OPÇÕES", ib_uibutton1, 0.375)
  optionsButton:setAnchor(4, 15, 75)
  optionsButton.onButtonClick = self.optionsButtonClick

  local exitButton = Button(0, 0, "SAIR", ib_uibutton1, 0.375)
  exitButton:setAnchor(4, 15, 20)
  exitButton.onButtonClick = self.exitButtonClick

  self.mainMenu:addButton(startButton)
  self.mainMenu:addButton(continueButton)
  self.mainMenu:addButton(optionsButton)
  self.mainMenu:addButton(exitButton)

  -- options menu

  self.configMenu = UIGroup()

  self.resolutionChange = Selector(0, 0, "RESOLUÇÃO", ib_uibutton1, 0.375)
  self.resolutionChange:setAnchor(4, 15, 185)

  self.resolutionChange:addOption("1024 x 768", {1024, 768})
  self.resolutionChange:addOption("1280 x 720", {1280, 720})
  self.resolutionChange:addOption("1600 x 900", {1600, 900})
  self.resolutionChange:addOption("1440 x 960", {1440, 960})
  self.resolutionChange:addOption("1920 x 1080", {1920, 1080})

  self.resolutionChange:setDefaultOptionIndex(2)
  self.resolutionChange.onSelectorChange  = self.selectorOnChange

  self.fullscreenMode = Selector(0, 0, "TELA CHEIA", ib_uibutton1, 0.375)
  self.fullscreenMode:setAnchor(4, 15, 130)
  self.fullscreenMode:addOption("SIM", true)
  self.fullscreenMode:addOption("NÃO", false)

  self.fullscreenMode:setDefaultOptionIndex(2)
  self.fullscreenMode.onSelectorChange  = self.selectorOnChange

  self.applyOptionsButton = Button(0, 0, "APLICAR", ib_uibutton1, 0.375)
  self.applyOptionsButton:setEnabled(false)
  self.applyOptionsButton:setAnchor(4, 15, 75)
  self.applyOptionsButton.onButtonClick = self.applyOptionsButtonClick

  self.exitOptionsButton = Button(0, 0, "VOLTAR", ib_uibutton1, 0.375)
  self.exitOptionsButton:setAnchor(4, 15, 20)
  self.exitOptionsButton.onButtonClick = self.exitOptionsButtonClick

  self.configMenu:addButton(self.resolutionChange)
  self.configMenu:addButton(self.fullscreenMode)
  self.configMenu:addButton(self.applyOptionsButton)
  self.configMenu:addButton(self.exitOptionsButton)
end

function MenuScreen:onEnter()
  self.game:getCamera():setPosition(0, 0)
end

function MenuScreen:onExit()

end

function MenuScreen:onKeyPress(key, scancode, isrepeat)

  if ( self.inMainMenu == true ) then

    if ( key == "return" or key == "kpenter") then
      self.mainMenu:keyPressed( key, self )
    end

  else

    if ( key == "return" or key == "kpenter" or key == "left" or key == "right") then
      self.configMenu:keyPressed( key, self )
    end

  end

end

function MenuScreen:onKeyRelease(key, scancode, isrepeat)
  -- DO NOTHING?
end

function MenuScreen:update(dt)
  self:checkEditor()

  if ( self.inMainMenu == true) then
    self.mainMenu:update(dt)
  else
    self.configMenu:update(dt)

    if ( ( self.resolutionChange:haveChanged() == true ) or ( self.fullscreenMode:haveChanged() == true ) ) then
      self.applyOptionsButton:setEnabled(true)
    end

  end
end

function MenuScreen:draw()
  if (self.backgroundImage) then
    self.backgroundImage:draw(self.light)
  end

  if ( self.inMainMenu == true) then
    self.mainMenu:draw()
  else
    self.configMenu:draw()
  end
end

function MenuScreen:joystickPressed(joystick, button)
   if (self.inMainMenu) then
     self.mainMenu:joystickPressed(joystick, button, self)
   else
	   self.configMenu:joystickPressed(joystick, button, self)
   end
end

function MenuScreen:setIsInMainMenu(isInMainMenu)
  self.inMainMenu = isInMainMenu
end

function MenuScreen:startButtonClick(sender)
  local play = PlayScreen(sender.game)

  sender.game:setScreen(play)
end

function MenuScreen:exitButtonClick(sender)
  love.event.push("quit")
end

function MenuScreen:optionsButtonClick(sender)
  sender:setIsInMainMenu(false)
end

function MenuScreen:applyOptionsButtonClick(sender)
  --//TODO save configuration and load it next time

  local resValues = sender.resolutionChange:getValue()
  sender.game:changeResolution( resValues[1], resValues[2], false)
end

function MenuScreen:exitOptionsButtonClick(sender)
  sender:setIsInMainMenu(true)
end

function MenuScreen:selectorOnChange(sender)
  sender.applyOptionsButton:setEnabled(true)
end


function MenuScreen:checkEditor()
  if ( Input:isKeyDown("lctrl") and Input:isKeyDown("f8") ) then

    local editor = Editor()

    self.game:setScreen( editor )

  end
end
