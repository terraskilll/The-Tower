require("..engine.lclass")

require("..engine.input")
require("../editor/editor")
require("..engine.ui/uigroup")
require("..engine.ui/button/button")
require("..engine.ui/selector/selector")
require("..engine.screen/screen")
require("..engine.light/light")
require("..engine.gameobject/gameobject")
require("..engine.gameobject/staticimage")

require("../resources")

require("../game/screen/play")

class "MenuScreen" ("Screen")

local mapShader = love.graphics.newShader( "engine/shaders/simplenormal.glsl" )

function MenuScreen:MenuScreen( theGame )
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

  self.mainMenu:addButton( startButton )
  self.mainMenu:addButton( continueButton )
  self.mainMenu:addButton( optionsButton )
  self.mainMenu:addButton( exitButton )

  -- options menu

  self.configMenu = UIGroup()

  self.resolutionChange = Selector(0, 0, "RESOLUÇÃO", ib_uibutton1, 0.375)
  self.resolutionChange:setAnchor(4, 15, 240)

  self.resolutionChange:addOption("1024 x 768", {1024, 768})
  self.resolutionChange:addOption("1280 x 720", {1280, 720})
  self.resolutionChange:addOption("1600 x 900", {1600, 900})
  self.resolutionChange:addOption("1440 x 960", {1440, 960})
  self.resolutionChange:addOption("1920 x 1080", {1920, 1080})

  self.resolutionChange:setDefaultOptionIndex(2)
  self.resolutionChange.onSelectorChange  = self.selectorOnChange

  self.fullscreenMode = Selector(0, 0, "TELA CHEIA", ib_uibutton1, 0.375)
  self.fullscreenMode:setAnchor(4, 15, 185)
  self.fullscreenMode:addOption("SIM", true)
  self.fullscreenMode:addOption("NÃO", false)

  self.fullscreenMode:setDefaultOptionIndex(2)
  self.fullscreenMode.onSelectorChange  = self.selectorOnChange

  self.applyOptionsButton = Button(0, 0, "APLICAR", ib_uibutton1, 0.375)
  self.applyOptionsButton:setEnabled(false)
  self.applyOptionsButton:setAnchor(4, 15, 130)
  self.applyOptionsButton.onButtonClick = self.applyOptionsButtonClick

  self.creditsButton = Button(0, 0, "CRÉDITOS", ib_uibutton1, 0.375)
  self.creditsButton:setAnchor(4, 15, 75)
  self.creditsButton.onButtonClick = self.creditsButtonClick

  self.exitOptionsButton = Button(0, 0, "VOLTAR", ib_uibutton1, 0.375)
  self.exitOptionsButton:setAnchor(4, 15, 20)
  self.exitOptionsButton.onButtonClick = self.exitOptionsButtonClick

  self.configMenu:addButton(self.resolutionChange)
  self.configMenu:addButton(self.fullscreenMode)
  self.configMenu:addButton(self.applyOptionsButton)
  self.configMenu:addButton(self.creditsButton)
  self.configMenu:addButton(self.exitOptionsButton)

  self.currentmenu = self.mainMenu
end

function MenuScreen:onEnter()
  self.game:getCamera():setPosition(0, 0)
end

function MenuScreen:onExit()

end

function MenuScreen:onKeyPress(key, scancode, isrepeat)

  if ( key == "return" or key == "kpenter" or key == "left" or key == "right") then
    self.currentmenu:keyPressed( key, self )
  end

end

function MenuScreen:onKeyRelease( key, scancode, isrepeat )
  -- DO NOTHING
end

function MenuScreen:update(dt)
  self:checkEditor()

  self.currentmenu:update( dt )

  if ( ( self.resolutionChange:haveChanged() == true ) or ( self.fullscreenMode:haveChanged() == true ) ) then
    self.applyOptionsButton:setEnabled( true )
  end

end

function MenuScreen:draw()

  if (self.backgroundImage) then
    self.backgroundImage:draw(self.light)
  end

  self.currentmenu:draw()

end

function MenuScreen:joystickPressed(joystick, button)
   self.currentmenu:joystickPressed( joystick, button, self )
end

function MenuScreen:startButtonClick(sender)

  sender.game:setCurrentScreen("PlayScreen")

end

function MenuScreen:exitButtonClick( sender )
  love.event.push( "quit" )
end

function MenuScreen:optionsButtonClick( sender )
  sender.currentmenu = sender.configMenu
end

function MenuScreen:applyOptionsButtonClick( sender )
  --//TODO save configuration and load it next time

  local resValues = sender.resolutionChange:getValue()
  sender.game:changeResolution( resValues[1], resValues[2], false)
  sender.game:saveConfiguration()
end

function MenuScreen:creditsButtonClick( sender )
  sender.game:setCurrentScreen("CreditsScreen")
end

function MenuScreen:exitOptionsButtonClick( sender )
  sender.currentmenu = sender.mainMenu
end

function MenuScreen:selectorOnChange( sender )
  sender.applyOptionsButton:setEnabled( true )
end

function MenuScreen:onMousePress( x, y, button, scaleX, scaleY, istouch )

  self.currentmenu:mousePressed( x, y, button, scaleX, scaleY, self )

  return false
end

function MenuScreen:onMouseRelease( x, y, button, scaleX, scaleY, istouch )

  self.currentmenu:mouseReleased( x, y, button, scaleX, scaleY, self )

  return false
end

function MenuScreen:onMouseMove( x, y, dx, dy, scaleX, scaleY )

  self.currentmenu:mouseMoved( x, y, dx, dy, scaleX, scaleY, self )

  return false
end

function MenuScreen:checkEditor()
  if ( Input:isKeyDown("lctrl") and Input:isKeyDown("f8") ) then

    self.game:setCurrentScreen( "EditorScreen" )

  end
end
