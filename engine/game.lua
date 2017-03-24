require("..engine.lclass")

require("..engine.input")
require("..engine.io.io")
require("..engine.globalconf")
require("..engine.colors")
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
require("..engine.inventory.inventory")
require("..engine.script.scriptmanager")
require("..engine.ui.messagebox.messagebox")

local Vec = require("..engine.math.vector")

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

  self:beforeUpdate( dt )

  Input:update(dt)

	self.currentScreen:update( dt )
  self.drawManager:update( dt ) --//TODO check is gets slow, skiplist is pending

  self:afterUpdate( dt )
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

function Game:queryObjectByName( instanceName )
  local c = #self.gameobjects

  for i = 1, c do
    if ( self.gameobjects[i]:getInstanceName() == instanceName ) then
      return self.gameobjects[i]
    end
  end

  return nil
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

function Game:onMouseWheelMoved( xm, ym )
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
  table.insert( self.deletedObjects , gameobject )
end

function Game:addObject( objectname, areaname, positionx, positiony, layer )
  table.insert( self.addedObjects, { name = objectname, areaname = areaname, positionx = positionx, positiony = positiony, layer = layer } )
end

function Game:createAndAddObject( objectname, areaname, positionx, positiony, layer )
  local area = self.map:getAreaByName( areaname )

  local instancename =  self.map:getNextGeneratedName()

  local fromLibrary = self.map:getObjectFromLibrary ( objectname )

  local object = nil

  if ( fromLibrary ) then
    object = fromLibrary:clone( objectname, instancename )
  else
    tolibrary = self:getObjectManager():loadObject( objectname, instancename, lx, ly )

    if ( tolibrary ) then
      self.map:addToLibrary( objectname, tolibrary )

      instancename =  self.map:getNextGeneratedName()

      object = tolibrary:clone( objectname, instancename )
    else
      self:setLastMessage( "Object not found: " .. objectname )
    end
  end

  if ( object ) then
    object:setLayer( layer )

    object:setPosition( Vec( positionx, positiony ) )

    area:addObject( object )

    self:getDrawManager():addObject( object, layer )

    self:addObject( object, true )

    --//TODO set script if exists
  end
end

function Game:addQueuedObjects()
  for i = 1, #self.addedObjects do
    self:createAndAddObject(
        self.addedObjects[i].name,
        self.addedObjects[i].areaname,
        self.addedObjects[i].positionx,
        self.addedObjects[i].positiony,
        self.addedObjects[i].layer )
  end

  self.addedObjects = {}
end

function Game:beforeUpdate( dt )

  self:addQueuedObjects()

end

function Game:afterUpdate( dt )

  --//TODO add more checks, test better

  if ( #self.deletedObjects == 0 ) then
    return
  end

  count = 0

  -- releasing destroyed objects on deletedObjects

  for i = 1, #self.deletedObjects do

    self:getDrawManager():removeObject( self.deletedObjects[i]:getInstanceName(), self.deletedObjects[i]:getLayer() )
    self:getCollisionManager():removeCollider( self.deletedObjects[i]:getCollider(), self.deletedObjects[i]:getLayer() )
    self.map:removeObjectByName( self.deletedObjects[i]:getInstanceName() )

    count = count + 1
  end

  self.deletedObjects = {}

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

function Game:getInventory()
  return self.inventory
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

      oo: loadScript()
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

  self.map:onEnter()
end

function Game:loadMapFoSaveGame( savegame )
  --//TODO use changemap function

  self.map = self:loadMap( nil, savegame:getMapName() )

  local area = self.map:getAreaByName( savegame:getAreaName() )

  local spawn = area:getSpawnPointByName( savegame:getSpawnName() )

  self:getPlayer():setMap( self.map, area, spawn )

  self:getDrawManager():addObject( self:getPlayer(), spawn:getLayer() )

  self.map:onEnter()
end

function Game:updateMap( dt )
  self.map:update( dt )
end

function Game:unloadMap()
  self.map:unloadScript()

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

  self.gameobjects    = {}
  self.addedObjects   = {}
  self.deletedObjects = {}

  self.currentMap = nil

  self.savegame = nil
  self.saveslot = 0

  self.newgame = true

  self:loadConfiguration()

  if ( config.setFullScreen == nil ) then
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

  self.inventory = Inventory()
  self.inventory:reset()

  self.camera = Camera()
  self.camera:setScale( ww / 1280, wh / 720 )

  self.drawManager = DrawManager( self.camera )
  self.drawManager:setScale( 1280 / ww, 720 / wh )

  self.messagebox = MessageBox()

  self.player = Player( self, "PLAYER", "PLAYER", 0, 0 )

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

  resolutionWidth, resolutionHeight = love.graphics.getDimensions()

  self.camera:setScale( resolutionWidth / 1280, resolutionHeight / 720 )
  self.drawManager:setScale( resolutionWidth / 1280, resolutionHeight / 720 )

  config.gameScreenWidth  = resolutionWidth
  config.gameScreenHeight = resolutionHeight
  config.gameIsFullScreen = setFullScreen

  self.messagebox = MessageBox()
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
