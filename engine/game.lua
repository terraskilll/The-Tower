require("..engine.lclass")

require("..engine.input")
require("..engine.io.io")
require("..engine.globalconf")
require("..engine.camera.camera")
require("..engine.resourcemanager")
require("..engine.audio.audiomanager")
require("..engine.render.drawmanager")
require("..engine.collision.collisionmanager")
require("..engine.gameobject.objectmanager")
require("..engine.animation.animationmanager")
require("..engine.map.mapmanager")
require("..engine.savegame.savegame")
require("..engine.savegame.savemanager")
require("..engine.script.scriptmanager")
require("..engine.ui.messagebox.messagebox")

local config = {
  gameScreenWidth = 1280,
  gameScreenHeight = 720,
  gameIsFullScreen = false
}

class "Game"

function Game:Game()
 -- Empty?
end

function Game:update( dt )
  self.deltaTime = dt

  Input:update(dt)

	self.currentScreen:update( dt )
  self.drawManager:update( dt ) --//TODO check is gets slow, skiplist is pending

  self:postUpdate( dt )
end

function Game:getDeltaTime()
  return self.deltaTime
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

function Game:unregisterAll()
  --//TODO add more checks?

  for i = 1, #self.gameobjects do
    self.gameobjects[i]:unloadScript()
  end

  self.gameobjects = {}
end

function Game:destroy( gameobject )
  --//TODO
  table.insert( self.deletedObjects , gameobject )
end

function Game:postUpdate( dt )

  --//TODO releases destroyed objects on deletedObjects
  if ( #self.deletedObjects > 0 ) then

  end

end

function Game:getResourceManager()
  return self.resourceManager
end

function Game:getAudioManager()
  return self.audioManager
end

function Game:getDrawManager()
  return self.drawManager
end

function Game:getCollisionManager()
  return self.collisionManager
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

function Game:getCamera()
  return  self.camera
end

function Game:getPlayer()
  return self.player
end

function Game:getCurrentMap()
  return self.currentMap
end

function Game:getMessageBox()
  return self.messagebox
end

function Game:createEmptySave()
  return self:getSaveManager():createEmptySave()
end

function Game:setNewGame( trueToNewGame )
  self.newgame = trueToNewGame
end

function Game:isNewGame()
  return self.newgame
end

function Game:saveGame()
  self:getSaveManager():setSaveToSlot( self.savegame, self.saveslot )
  self:getSaveManager():saveGame( self.saveslot )
end

function Game:selectSaveSlot( slotNumber )
  self.saveslot = slotNumber
  self:setSaveGame( self:getSaveManager():getSaveSlot( slotNumber ) )
end

function Game:setSaveGame( savegame )
  self.savegame = savegame
end

function Game:getSaveGame( savegame )
  return self.savegame
end

function Game:loadMap( mapname, mapfilename )
  local map = self:getMapManager():loadMap( mapname, mapfilename )

  local lls = map:getLayers()

  for i = 1, #lls do
    self:getDrawManager():addLayer( lls[i].name )
    self:getCollisionManager():addLayer( lls[i].index, lls[i].name, lls[i].collision == 1 )
  end

  --//TODO add enemies to drawmanager

  self:getDrawManager():getObjectsFromMap( map )

  self:getCollisionManager():addCollider( self:getPlayer():getCollider() )

  --//TODO move to collisionmanager ?
  local areas = map:getAreas()

  for _,aa in pairs( areas ) do
    local objects = aa:getObjects()

    for _,oo in pairs( objects ) do
      self:getCollisionManager():addCollider( oo:getCollider(), oo:getLayer() )
      self:register( oo )
    end

  end

  local musicdata = map:getBackgroundMusicData()

  if ( musicdata.name ) then
    local resname, restype, respath = self:getResourceManager():getResourceByName( musicdata.name )
    local music = self:getResourceManager():loadAudio( respath )

    self:getAudioManager():addMusic( musicdata.name, music, tonumber( musicdata.volume ) )
    self:getAudioManager():playMusic( musicdata.name )

     --//TODO where to start audio?
  end

  return map
end

function Game:changeMap( newMapName, newAreaName, newSpawnName )

  self:unloadMap()
  self:getCamera():setTarget( nil )
  self:getDrawManager():clear()
  self:getCollisionManager():clear()
  self:unregisterAll()

  self.map = self:loadMap( nil, newMapName )

  local area = self.map:getAreaByIndex( 1 )
  local spawn = area:getSpawnPointByIndex( 1 )

  if ( newAreaName ) then
    area = self.map:getAreaByName( newAreaName )

    if ( newSpawnName ) then
      spawn = area:getSpawnPointByName( newSpawnName )
    else
      spawn = area:getSpawnPointByIndex( 1 )
    end

  end

  self:getCamera():setTarget( self:getPlayer() )

  self:getPlayer():setMap( self.map, area, spawn )
  self:getDrawManager():addObject( self:getPlayer(), spawn:getLayer() )
end

function Game:loadMapFoSaveGame( savegame )
  self.map = self:loadMap( nil, savegame:getMapName() )

  local area = self.map:getAreaByName( savegame:getAreaName() )

  local spawn = area:getSpawnPointByName( savegame:getSpawnName() )

  self:getPlayer():setMap( self.map, area, spawn )

  self:getDrawManager():addObject( self:getPlayer(), spawn:getLayer() )
end

function Game:updateMap( dt )
  self.map:update( dt )
end

function Game:unloadMap()
  self.map = nil
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
  self.screens = {}

  self.gameobjects = {}

  self.deletedObjects = {}

  self.currentMap = nil

  self.savegame = nil

  self.saveslot = 0

  self.newgame = true

  self:loadConfiguration()

  -- window configuration
  if (config.setFullScreen == nil) then
    config.setFullScreen = false
  end

  local ww, wh = config.gameScreenWidth, config.gameScreenHeight

  love.window.setMode( ww, wh, config.gameIsFullScreen )

  self.resourceManager = ResourceManager( self )

  self.audioManager = AudioManager( self )

  self.objectManager = ObjectManager( self )
  self.objectManager:load()

  self.animationManager = AnimationManager( self )
  self.animationManager:load()

  self.mapManager = MapManager( self )
  self.mapManager:loadList()

  self.saveManager = SaveManager( self )
  self.saveManager:load()

  self.scriptManager = ScriptManager( self )
  self.scriptManager:load()

  self.collisionManager = CollisionManager()

  self.camera = Camera()
  self.camera:setScale( ww / 1280, wh / 720 ) -- old version
  --self.camera:setScale( 1280 / ww, 720 / wh ) -- new test

  self.drawManager = DrawManager( self.camera )
  self.drawManager:setScale( ww / 1280, wh / 720 )
  --self.drawManager:setScale( 1280 / ww, 720 / wh ) -- new test

  self.messagebox = MessageBox()

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
