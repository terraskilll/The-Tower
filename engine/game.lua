require("..engine.lclass")

require("..engine.input")
require("..engine.io.io")
require("..engine.globalconf")
require("..engine.camera.camera")
require("..engine.render.drawmanager")
require("..engine.collision.collisionmanager")
require("..engine.resourcemanager")
require("..engine.gameobject.objectmanager")
require("..engine.animation.animationmanager")
require("..engine.map.mapmanager")
require("..engine.savegame.savegame")
require("..engine.savegame.savemanager")
require("..engine.script.scriptmanager")

local config = {
  gameScreenWidth = 1280,
  gameScreenHeight = 720,
  gameIsFullScreen = false
}

class "Game"

function Game:Game()

  self.screens = {}

  self.savegame = nil

  self.gameobjects = {}

  self.deletedObjects = {}

end

function Game:update(dt)
  Input:update(dt)

	self.currentScreen:update( dt )
  self.drawManager:update( dt ) --//TODO check is gets slow, skiplist is pending

  self:postUpdate( dt )
end

function Game:updateRegisteredObjects( dt )
  local c = #self.gameobjects

  for i = 1, c do
    self.gameobjects[i]:update( dt )
  end
end

function Game:draw()
  self.currentScreen:draw()

  if ( glob.devMode.showFPS ) then
    love.graphics.print( "Current FPS: " .. tostring( love.timer.getFPS() ), 10, 10 )
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

function Game:register( gameobject )
  table.insert( self.gameobjects, gameobject )
end

function Game:unregister( gameobject )
  --//TODO
end

function Game:destroy( gameobject )
  --//TODO
  table.insert( self.deletedObjects , gameobject )
end

function Game:postUpdate( dt )
  --//TODO releases destroyed objects
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

function Game:getResourceManager()
  return self.resourceManager
end

function Game:getObjectManager()
  return self.objectManager
end

function Game:getAnimationManager()
  return self.animationManager
end

function Game:getMapManager()
  return self.mapManager
end

function Game:getSaveManager()
  return self.saveManager
end

function Game:getScriptManager()
  return self.scriptManager
end

function Game:getSaveGame()
  return self.savegame
end

function Game:createEmptySave()
  local gamedata = loadFile( "__gameplay" )

  self.savegame = SaveGame( "Save " .. tostring( self.saveManager:getSaveCount() + 1 ) )

  self.savegame:setMapName( gamedata.startmap )
  self.savegame:setAreaName( gamedata.startarea )
  self.savegame:setSpawnName( gamedata.startspawn )
  self.savegame:save()

  self.saveManager:addSave( self.savegame:getName(), self.savegame )
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
  end

end

function Game:configure()
  self:loadConfiguration()

  -- window configuration
  if (config.setFullScreen == nil) then
    config.setFullScreen = false
  end

  local ww, wh = config.gameScreenWidth, config.gameScreenHeight

  love.window.setMode( ww, wh, config.gameIsFullScreen )

  self.resourceManager = ResourceManager( self )

  self.objectManager = ObjectManager( self )
  self.objectManager:load()

  self.animationManager = AnimationManager( self )
  self.animationManager:load()

  self.mapManager = MapManager( self )
  self.mapManager:loadList()

  self.saveManager = SaveManager( self )

  self.scriptManager = ScriptManager( self )
  self.scriptManager:load()

  self.collisionManager = CollisionManager()

  self.camera = Camera()
  self.camera:setScale( ww / 1280, wh / 720 )

  self.drawManager = DrawManager( self.camera )
  self.drawManager:setScale( ww / 1280, wh / 720 )

  self.player = Player( "PLAYER", "PLAYER", 0, 0 )

  Input.overallListener = Game
  Input.camera = self.camera

  local font = love.graphics.newFont( "res/font/ubuntu.ttf", 12 )
  love.graphics.setFont( font )
end

function Game:changeResolution( resolutionWidth, resolutionHeight, setFullScreen )
  if ( setFullScreen == nil ) then
    setFullScreen = false
  end

  love.window.setMode( resolutionWidth, resolutionHeight, { fullscreen = setFullScreen } )

  self.camera:setScale( resolutionWidth / 1280, resolutionHeight / 720 )
  self.drawManager:setScale( resolutionWidth / 1280, resolutionHeight / 720 )

  config.gameScreenWidth  = resolutionWidth
  config.gameScreenHeight = resolutionHeight
  config.gameIsFullScreen = setFullScreen
end

function Game:saveConfiguration()
  saveFile( "__config", config )
end

function Game:loadConfiguration()
  config, err = loadFile( "__config" )
end

function Game:Message( str )
  print( str )
end
