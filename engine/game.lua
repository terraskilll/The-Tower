require("../engine/lclass")

require("../engine/input")
require("../engine/io/io")
require("../engine/globalconf")
require("../engine/camera/camera")
require("../engine/render/drawmanager")
require("../engine/collision/collisionmanager")

local config = {
  gameScreenWidth = 1280,
  gameScreenHeight = 720,
  gameIsFullScreen = false
}

class "Game"

function Game:Game()
  self.screens = {}
end

function Game:update(dt)
  Input:update(dt)
	self.currentScreen:update( dt )
  self.drawManager:update( dt ) --//TODO check is gets slow
end

function Game:draw()
  self.currentScreen:draw()

  if ( glob.devMode.showFPS ) then
    love.graphics.print( "Current FPS: ".. tostring( love.timer.getFPS() ), 10, 10 )
  end

end

function Game:onKeyPress( key, scancode, isrepeat )
	local consumed = false

	if key == "escape" then
		love.event.push("quit")
		consumed = true
	end

	return consumed
end

function Game:onMousePress( x, y, button, scaleX, scaleY, istouch )
  return false
end

function Game:onMouseRelease( x, y, button, scaleX, scaleY, istouch )
  return false
end

function Game:onMouseMove( x, y, dx, dy, scaleX, scaleY, istouch )
  return false
end

function Game:onKeyRelease( key, scancode, isrepeat )
	return false
end

function Game:configure()
  self:loadConfiguration()

  if (config.setFullScreen == nil) then
    config.setFullScreen = false
  end

  local ww, wh = config.gameScreenWidth, config.gameScreenHeight

  love.window.setMode( ww, wh, config.gameIsFullScreen )

  self.player = Player( "PLAYER", 0, 0 )

  self.camera = Camera()
  self.camera:setScale( ww / 1280, wh / 720 )

  self.drawManager = DrawManager( self.camera )
  self.drawManager:setScale( ww / 1280, wh / 720 )

  self.collisionManager = CollisionManager()

  Input.overallListener = Game
  Input.camera = self.camera

  local font = love.graphics.newFont( "res/font/ubuntu.ttf", 12 )
  love.graphics.setFont( font )
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

function Game:getCollisionManager()
  return self.collisionManager
end

function Game:setCurrentScreen( screenName )
  local nextScreen = self.screens[screenName]

  if ( not nextScreen ) then
    print( "Screen not found: " .. screenName )
    return
  end

  if ( self.currentScreen ) then
    self.currentScreen:onExit()
  end

  self.currentScreen = nextScreen
  Input.currentScreenListener = nextScreen

  nextScreen:setCamera(self.camera)

  nextScreen:onEnter()
end

function Game:addScreen( screenName, screen )

  if ( self.screens[screenName] ) then

    print("Screen already exists: " .. screenName)

  else

    self.screens[screenName] = screen
    print("Screen Added: " .. screenName)

  end
end

function Game:changeResolution( resolutionWidth, resolutionHeight, setFullScreen )
  if (setFullScreen == nil) then
    setFullScreen = false
  end

  love.window.setMode( resolutionWidth, resolutionHeight, {fullscreen = setFullScreen} )

  self.camera:setScale( resolutionWidth / 1280, resolutionHeight / 720 )
  self.drawManager:setScale( resolutionWidth / 1280, resolutionHeight / 720 )

  config.gameScreenWidth  = resolutionWidth
  config.gameScreenHeight = resolutionHeight
  config.gameIsFullScreen = setFullScreen
end

function Game:saveConfiguration()
  saveFile("__config", config)
end

function Game:loadConfiguration()
  config, err = loadFile("__config")
end
