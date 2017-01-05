require("lclass")

require("input")
require("../engine/camera/camera")
require("../game/screen/menuscreen")
require("../game/player/player")

class "Game"

function Game:Game()
  self:configure()

  self:setScreen(MenuScreen(self))
end

function Game:update(dt)
  Input:update(dt)
	self.currentScreen:update(dt)
end

function Game:draw()  
  self.camera:set()

  self.currentScreen:draw()

  self.camera:unset()
  
  --//TODO remove or parametrize
  love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
end

function Game:onKeyPress(key, scancode, isrepeat)
	local consumed = false

	if key == "escape" then
		love.event.push("quit")
		consumed = true
	end

	return consumed
end

function Game:onKeyRelease(key, scancode, isrepeat)
	return false
end

function Game:getPlayer()
  return self.player
end

function Game:setScreen(newScreen)
  if (self.currentScreen) then
    self.currentScreen:onExit()
  end

  self.currentScreen = newScreen
  Input.currentScreenListener = newScreen

  newScreen:onEnter()
end

function Game:configure()
  Input.overallListener = Game

  self.player = Player()
  self.camera = Camera()

  Input.camera = self.camera

  local font = love.graphics.newFont("res/font/ubuntu.ttf", 12)
  love.graphics.setFont(font)
end