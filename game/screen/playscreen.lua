require("lclass")

require("../resources")
require("../input")
require("../engine/ui/button/button")
require("../engine/ui/button/buttongroup")
require("../engine/screen/screen")
require("../engine/gameobject/gameobject")
require("../engine/gameobject/staticimage")
require("../engine/gameobject/floor")
require("../engine/map/map")
require("../engine/map/area")
require("../engine/collision/collisionchecker")

require("../game/spider/spider")

class "PlayScreen" ("Screen")

function PlayScreen:PlayScreen(theGame)
  self.game = theGame
  self.currentMap = nil
  self.paused = false
  self.spider = Spider(300, 200)

  self:createPauseMenu()
end

function PlayScreen:onEnter()
  self:createTestMap()
end

function PlayScreen:onExit()
  
end

function PlayScreen:update(dt)
  
  if ( self.paused ) then
    self:updatePaused(dt)
  else
    self:updateInGame(dt)
  end

end

function PlayScreen:draw()
  self.currentMap:draw()

  self.game:getPlayer():draw()
  
  self.spider:draw()

  self.pauseMenu:drawButtons()  
end

function PlayScreen:onKeyPress(key, scancode, isrepeat)

end

function PlayScreen:onKeyRelease(key, scancode, isrepeat)
	
end

function PlayScreen:joystickPressed(joystick, button)
  
  if ( button == 8 ) then
    self:checkPause()
  end
  
  if ( self.paused ) then
    self:handleInPauseMenu(joystick, button, self)
  else
    self:handleInGame(joystick, button, self)
  end

end

function PlayScreen:changeMap(newMap)
  self.currentMap = newMap
end

function PlayScreen:createPauseMenu()
  self.pauseMenu = ButtonGroup()

  local continueButton = Button(0, 0, "CONTINUAR", ib_uibutton1, 0.375)
  continueButton:setAnchor(4, 15, 130)

  local exitButton = Button(0, 0, "SAIR", ib_uibutton1, 0.375)
  exitButton:setAnchor(4, 15, 75)
  exitButton.onButtonClick = self.exitButtonClick
  
  self.pauseMenu:addButton(continueButton)
  self.pauseMenu:addButton(exitButton)

  self.pauseMenu:setVisible(self.paused)
end

function PlayScreen:checkPause()
  if ( self.paused ) then
    self.paused = false
  else
    self.paused = true
    self.pauseMenu:joystickPressed(joystick, button)
    self.pauseMenu:selectFirst()
  end

  self.pauseMenu:setVisible(self.paused)
end

function PlayScreen:handleInPauseMenu(joystick, button)
  self.pauseMenu:joystickPressed(joystick, button, self)
end

function PlayScreen:handleInGame(joystick, button, sender)
  self.game:getPlayer():joystickPressed(joystick, button, self)
end

function PlayScreen:updatePaused(dt)
  self.pauseMenu:update(dt)
end

function PlayScreen:updateInGame(dt)
  self.game:getPlayer():update(dt)
  self.spider:update(dt)

  local coll = checkCollision( self.game:getPlayer():getCollider(), self.spider:getCollider() )  
end

function PlayScreen:exitButtonClick(sender)
  print("exit the game")
end

function PlayScreen:createTestMap()
  --//TODO remove
  local mapa = Map()

  local area = Area()
  mapa:addArea(area)

  local fl = Floor(100, 100, i_deffloor)
  area:addFloor(fl)

  self:changeMap(mapa)
end