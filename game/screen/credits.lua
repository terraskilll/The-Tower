require("..engine.lclass")

require("..engine.input")
require("..engine.ui.uigroup")
require("..engine.ui.button.button")
require("..engine.screen.screen")

require("..resources")

class "CreditsScreen" ("Screen")

function CreditsScreen:CreditsScreen( theGame )
  self.game = theGame

  self.menu = UIGroup()

  local exitButton = Button(0, 0, "SAIR", ib_uibutton1, 0.375)
  exitButton:setAnchor(4, 15, 20)
  exitButton.onButtonClick = self.exitButtonClick

  self.menu:addButton( exitButton )
end

function CreditsScreen:update(dt)

  self.menu:update( dt )

end

function CreditsScreen:draw()

  self.menu:draw()

end

function CreditsScreen:onKeyPress(key, scancode, isrepeat)

  if ( key == "return" or key == "kpenter") then
    self.menu:keyPressed( key, self )
  end

end

function CreditsScreen:joystickPressed( joystick, button )

   self.menu:joystickPressed( joystick, button, self )

end

function CreditsScreen:exitButtonClick( sender )

  sender.game:setCurrentScreen( "MenuScreen" )

end
