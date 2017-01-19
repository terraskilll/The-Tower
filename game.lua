require("../engine/lclass")

require("../engine/input")
require("../engine/io/io")
require("../engine/globalconf")
require("../engine/camera/camera")
require("../engine/render/drawmanager")

require("../game/screen/menuscreen")
require("../game/player/player")

local config = {
  gameScreenWidth = 1280,
  gameScreenHeight = 720,
  gameIsFullScreen = false
}

class "Game"

function Game:Game()
  --//TODO load configuration
  self:configure()

  self:setScreen(MenuScreen(self))
end

function Game:update(dt)
  Input:update(dt)
	self.currentScreen:update(dt)
  self.drawManager:update(dt) --//TODO rever se ficar lento
end

function Game:draw()
  self.currentScreen:draw()

  if ( glob.devMode.showFPS ) then
    love.graphics.print("Current FPS: ".. tostring( love.timer.getFPS() ), 10, 10)
  end
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

function Game:configure()
  self.player      = Player()
  self.camera      = Camera()
  self.drawManager = DrawManager(self.camera)

  Input.overallListener = Game
  Input.camera = self.camera

  local font = love.graphics.newFont("res/font/ubuntu.ttf", 12)
  love.graphics.setFont(font)
end

function Game:getPlayer()
  return self.player
end

function Game:getCamera()
  return  self.camera
end

function Game:getDrawManager()
  return self.drawManager
end

function Game:setScreen(newScreen)
  if (self.currentScreen) then
    self.currentScreen:onExit()
  end

  self.currentScreen = newScreen
  Input.currentScreenListener = newScreen

  newScreen:setCamera(self.camera)

  newScreen:onEnter()
end

function Game:changeResolution(resolutionWidth, resolutionHeight, setFullScreen)
  if (setFullScreen == nil) then
    setFullScreen = false
  end

  love.window.setMode(resolutionWidth, resolutionHeight, {fullscreen = setFullScreen})

  self.camera:setScale(resolutionWidth / 1280, resolutionHeight / 720)

  self:saveConfiguration()
end

function Game:saveConfiguration()
  --//TODO
  print("TODO")
end
