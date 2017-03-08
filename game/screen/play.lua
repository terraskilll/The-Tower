require("../engine/lclass")

require("../engine/input")
require("../engine/ui/uigroup")
require("../engine/ui/button/button")
require("../engine/screen/screen")
require("../engine/gameobject/gameobject")
require("../engine/gameobject/staticimage")
require("../engine/gameobject/simpleobject")
require("../engine/gameobject/movingobject")
require("../engine/light/light")
require("../engine/map/map")
require("../engine/map/area")
require("../engine/map/spawnpoint")
require("../engine/collision/collision")
require("../engine/navigation/navmesh")
require("../engine/navigation/navmap")

require("../resources")

require("../game/actors/spider/spider")

local Vec = require("../engine/math/vector")

local sepiaShader = love.graphics.newShader("engine/shaders/sepia.glsl")

class "PlayScreen" ("Screen")

function PlayScreen:PlayScreen( game )
  self.game   = game
  self.paused = false

  self.enemies = {}

  self.tree   = nil

  self.camera = game:getCamera()
  self.camera:setTarget( self.game:getPlayer() )
  self.currentMap = nil

  self.navmaps = {}

  self:createPauseMenu()
end

function PlayScreen:onEnter()
  self:createTestMap()
end

function PlayScreen:onExit()

end

function PlayScreen:update(dt)

  if ( self.paused ) then
    self:updatePaused( dt )
  else
    self:updateInGame( dt )
  end

end

function PlayScreen:draw()
  if ( self.paused ) then
    love.graphics.setShader( sepiaShader )
  end

  self.camera:set()

  self.game:getDrawManager():draw()

  for i=1, #self.navmaps do
    self.navmaps[i]:draw()
  end

  love.graphics.setShader()

  self.camera:unset()

  self.pauseMenu:draw()
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
    self:handleInPauseMenu( joystick, button, self )
  else
    self:handleInGame( joystick, button, self )
  end

end

function PlayScreen:changeMap( newMap, newArea, newSpawnPoint )
  self.currentMap = newMap
  self.game:getPlayer():setMap( newMap, newArea, newSpawnPoint )
end

function PlayScreen:createPauseMenu()
  self.pauseMenu = UIGroup()

  local continueButton = Button( 0, 0, "CONTINUAR", ib_uibutton1, 0.375 )
  continueButton:setAnchor( 4, 15, 130 )

  local exitButton = Button( 0, 0, "SAIR", ib_uibutton1, 0.375 )
  exitButton:setAnchor( 4, 15, 75 )
  exitButton.onButtonClick = self.exitButtonClick

  self.pauseMenu:addButton( continueButton )
  self.pauseMenu:addButton( exitButton )

  self.pauseMenu:setVisible( self.paused )
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

function PlayScreen:handleInPauseMenu( joystick, button )
  self.pauseMenu:joystickPressed( joystick, button, self )
end

function PlayScreen:handleInGame( joystick, button, sender )
  self.game:getPlayer():joystickPressed( joystick, button, self )
end

function PlayScreen:updatePaused( dt )
  self.pauseMenu:update(dt)
end

function PlayScreen:updateInGame( dt )
  self.game:getPlayer():update( dt, self.game )

  for i=1, #self.enemies do
    self.enemies[i]:update( dt, self.game )
  end

  self.camera:update( dt )

  self.currentMap:update( dt )

  self.game:getCollisionManager():checkCollisions()

end

function PlayScreen:exitButtonClick( sender )

  sender.game:setCurrentScreen( "MenuScreen" )

end

function PlayScreen:createTestMap()
  --//TODO remove
  local area = Area( "TestArea" )

  area:addGround( Ground( "grd1", 100, 100, i_deffloor ) )
  area:addGround( Ground( "grd2", 300, 100, i_deffloor ) )
  area:addGround( Ground( "grd3", 500, 100, i_deffloor ) )
  area:addGround( Ground( "grd4", 700, 100, i_deffloor ) )

  area:addGround( Ground( "grd5", 100, 300, i_deffloor ) )
  area:addGround( Ground( "grd6", 300, 300, i_deffloor ) )
  area:addGround( Ground( "grd7", 500, 300, i_deffloor ) )
  area:addGround( Ground( "grd8", 700, 400, i_deffloor ) )

  local nav = NavMesh()

  nav:addPoint( 110, 110 )
  nav:addPoint( 110, 490 )
  nav:addPoint( 710, 490 )
  nav:addPoint( 710, 590 )
  nav:addPoint( 890, 590 )

  nav:addPoint( 890, 410 )
  nav:addPoint( 690, 410 )
  nav:addPoint( 690, 290 )
  nav:addPoint( 890, 290 )
  nav:addPoint( 890, 110 )

  area:setNavMesh( nav )

  local collTree = BoxCollider( 400, 300, 20, 22, 23, 42 )

  self.tree = SimpleObject( "onetree", 400, 300, i__tree )
  self.tree:setBoundingBox( BoundingBox( 400, 300, 60, 64, 0, 2, 0 ) )
  self.tree:setCollider( collTree )

  area:addSimpleObject( self.tree )

  --local spawnpt = SpawnPoint( "Inicio", -550, 0 )
  local spawnpt = SpawnPoint( "Inicio", -500, -300 )

  area:addSpawnPoint( spawnpt )

  local floor = Floor( "TestFloor" )

  floor:addArea( area )

  local mapa = Map( "TestMap" )

  mapa:addFloor( floor )
  mapa:setCurrentFloorByName( "TestFloor" )

  local movingPlate = MovingObject( "Moving", -300, -100, i__mov )
  movingPlate:addPoint( Vec (-300, -100) )
  movingPlate:addPoint( Vec (200, -100) )
  movingPlate:addPoint( Vec (200, -5) )
  movingPlate:setSpeed( 150 )
  movingPlate:setDelays( 1, 1, 1 )

  local plateNav = NavMesh()
  plateNav:addPoint( -300, -100 )
  plateNav:addPoint( -172, -100 )
  plateNav:addPoint( -172, 28 )
  plateNav:addPoint( -300, 28 )

  plateNav:setMobile( true )

  movingPlate:setNavMesh( plateNav )

  floor:addMovingObject( movingPlate )

  -- another area
  local farArea = Area( "FarArea" )

  farArea:addGround( Ground( "grd100", -450, -100, i_deffloor ) )
  farArea:addGround( Ground( "grd101", -650, -100, i_deffloor ) )
  farArea:addGround( Ground( "grd103", -850, -100, i_deffloor ) )
  farArea:addGround( Ground( "grd104", -450, -300, i_deffloor ) )
  farArea:addGround( Ground( "grd105", -650, -300, i_deffloor ) )
  farArea:addGround( Ground( "grd106", -850, -300, i_deffloor ) )

  farArea:addGround( Ground( "grd107", -450, -500, i_deffloor ) )
  farArea:addGround( Ground( "grd108", -650, -500, i_deffloor ) )
  farArea:addGround( Ground( "grd109", -850, -500, i_deffloor ) )
  farArea:addGround( Ground( "grd110", -450, -700, i_deffloor ) )
  farArea:addGround( Ground( "grd111", -650, -700, i_deffloor ) )
  farArea:addGround( Ground( "grd112", -850, -700, i_deffloor ) )

  local farNav = NavMesh()

  farNav:addPoint( -840, -690 )
  farNav:addPoint( -260, -690 )
  farNav:addPoint( -260, 90 )
  farNav:addPoint( -840, 90 )

  farArea:setNavMesh( farNav )

  floor:addArea( farArea )

  --local m = nil
  -- lots of trees:
  --[[
  for i = -50, 50 do
    for j = -50, 50 do
      m = SimpleObject( i * 60, j * 60, i__tree)
      m:setBoundingBox( BoundingBox(i * 60, j * 60, 20, 20, 0, 23, 42) )
      area:addSimpleObject(m)
      self.game:getDrawManager():addObject(m)
    end
  end
  ]]

  movingPlate:start()

  local spider1 = Spider( "Spider1", 300, 200 )
  local spider2 = Spider( "Spider2", -590, -600 )

  spider1:getNavAgent():setNavMesh( nav )
  spider2:getNavAgent():setNavMesh( farNav )

  spider1:setTarget( self.game:getPlayer() )
  spider2:setTarget( self.game:getPlayer() )

  table.insert( self.enemies, spider1 )
  table.insert( self.enemies, spider2 )

  local navmap1 = NavMap( spider1, spider1:getNavAgent():getRadius() )
  spider1:getNavAgent():setNavMap( navmap1 )
  navmap1:generateFromNavMesh( nav, spider1:getNavAgent():getRadius() )

  local navmap2 = NavMap( spider2, spider2:getNavAgent():getRadius() )
  spider2:getNavAgent():setNavMap( navmap2 )
  navmap2:generateFromNavMesh( farNav, spider2:getNavAgent():getRadius() )

  spider1:setMap( mapa, floor, area, nil )
  spider2:setMap( mapa, floor, farArea, nil )

  table.insert( self.navmaps, navmap1 )
  table.insert( self.navmaps, navmap2 )

  self.game:getDrawManager():addObject( self.game:getPlayer() )
  self.game:getDrawManager():addObject( self.tree )
  self.game:getDrawManager():addObject( spider1 )
  self.game:getDrawManager():addObject( spider2 )
  self.game:getDrawManager():addAllAreas( floor:getAreas() )
  self.game:getDrawManager():addNavMesh( nav )
  self.game:getDrawManager():addNavMesh( farNav )
  self.game:getDrawManager():addAllMovingObjects( floor:getMovingObjects() )

  self.game:getCollisionManager():addCollider( self.game:getPlayer():getCollider() )
  self.game:getCollisionManager():addCollider( spider1:getCollider() )
  self.game:getCollisionManager():addCollider( spider2:getCollider() )
  self.game:getCollisionManager():addCollider( self.tree:getCollider() )

  self:changeMap( mapa, area, spawnpt )
end
