--[[

a drawmanager manages all the drawing calls of in-game objects.
it orders the objects based z-index and lowest y position,
and call the drawing method of each one, checking its visibility (on-screen position)

all objects MUST have a draw() function with no parameters (for now). each
object handles its own drawing. this class only orders the objects and
calls their draw methods

all objects MUST have a BoundingBox, so this manager can  call
getLowY() function and a getZ() function. these functions are called
in the ordering algorithm

objects not in-game (ui elements, menu buttons) are not affected by this

--//TODO add Area support, instead of drawing the whole map

--//TODO method to remove spawn points, lights, layers and moving objects

--//TODO use skiplist

]]--

require("...engine.lclass")

local lightShader = love.graphics.newShader("engine/shaders/lightspot.glsl")

class "DrawManager"

local function sortByY(o1, o2)
  return o1:getBoundingBox():getLowY() < o2:getBoundingBox():getLowY()
end

local function sortByZ(o1, o2)
  return o1:getBoundingBox():getZ() < o2:getBoundingBox():getZ()
end

local function isInside(x, y, bounds)
  return (
    x > bounds[1] and
    y > bounds[2] and
    x < bounds[1] + bounds[3] and
    y < bounds[2] + bounds[4]
  )
end

function DrawManager:DrawManager( gameCamera )
  self.camera = gameCamera

  self.layers     = {}
  self.layerCount = 0

  self.scaleX = 1
  self.scaleY = 1

  self.objectCount = 0
  self.objects     = {} -- objects currently being managed

  self.areaCount  = 0
  self.areas      = {} -- areas

  self.spawnCount  = 0
  self.spawns      = {} -- spawn points

  self.navCount   = 0
  self.navmeshes  = {}

  self.drawLayerFunction = self.drawLayerNormal
end

function DrawManager:addLayer( layerName )

  local layer = {
    name        = layerName,
    visible     = true,
    objects     = {},
    objectCount = 0
  }

  table.insert( self.layers, layer )

  self.layerCount = self.layerCount + 1
end

function DrawManager:getLayerCount()
  return self.layerCount
end

function DrawManager:setScale( newScaleX, newScaleY )
  self.scaleX = newScaleX or 1
  self.scaleY = newScaleY or 1
end

function DrawManager:clear()
  -- removes all objects in lists

  --//TODO check if this is expensive
  --//TODO refactor for layers

  self.movingCount = 0
  self.areaCount   = 0
  self.spawnCount  = 0
  self.navCount    = 0

  self.layers = {}

  self.areas         = {}
  self.spawnPoints   = {}
  self.navmeshes     = {}
end

function DrawManager:update( dt )
  --//TODO sort less times, use skiplist

  if ( self.layerCount == 0 ) then
    return
  end

  for i = 1, #self.layers do
    table.sort( self.layers[i].objects, sortByY )
  end
end

function DrawManager:forceUpdate()

  --// TODO use skiplist
  for i = 1, #self.layers do
    table.sort( self.objects[i].objects, sortByY )
  end

end

function DrawManager:toogleLayerVisible( layerIndex )
  if ( layerIndex == nil ) then
    return
  end

  self.layers[layerIndex].visible = self.layers[layerIndex].visible

  print( "Layer " .. layerIndex ..  " visibility changed to " .. tostring( self.layers[layerIndex].visible ) )
end

function DrawManager:swapLayers( layerIndex1, layerIndex2 )
  self.layers[layerIndex1], self.layers[layerIndex2] = self.layers[layerIndex2], self.layers[layerIndex1]
end

function DrawManager:addObject( objectToAdd, layerIndex )
  table.insert( self.layers[layerIndex].objects, objectToAdd )
  self.layers[layerIndex].objectCount = #self.layers[layerIndex].objects
end

function DrawManager:removeObject( instanceName, layerIndex )
  local index = 0

  local object = nil

  for i = 1, #self.layers[layerIndex].objects do

    if ( self.layers[layerIndex].objects[i]:getInstanceName() == instanceName ) then
      index = i
    end

  end

  if ( index > 0 ) then
    object = self.layers[layerIndex].objects[index]
    table.remove( self.layers[layerIndex].objects, index )
  end

  self.layers[layerIndex].objectCount = #self.layers[layerIndex].objects

  return object
end

function DrawManager:swapObjectLayer( objectName, currentLayer, newLayer )

  -- if ( newLayer > #self.layers ) then
  --   return
  -- end

  local object = self:removeObject( objectName, currentLayer )

  if ( object ) then
    self:addObject( object, newLayer )
  end

end

function DrawManager:addSpawnPoint( spawnToAdd )
  table.insert( self.spawns, spawnToAdd )
  self.spawnCount = #self.spawns
end

function DrawManager:addAllSpawns( spawnsToAdd )

  for _,s in pairs( spawnsToAdd ) do
    self:addSpawnPoint( s )
  end

end

function DrawManager:removeSpawnPoint( instanceName, layerIndex )
  local index = 0

  local spawn = nil

  for i = 1, #self.spawns do

    if ( self.spawns[i]:getInstanceName() == instanceName ) then
      index = i
    end

  end

  if ( index > 0 ) then
    spawn = self.spawns[index]
    table.remove( self.spawns, index )
  end

  self.spawnCount = #self.spawns

  return spawn
end

function DrawManager:addArea( areaToAdd ) --//TODO remove ?
  table.insert( self.areas, areaToAdd )
  self.areaCount = #self.areas

  self:addAllSpawns( areaToAdd:getSpawnPoints() )
end

function DrawManager:addAllAreas( areasToAdd )

  for _,f in pairs( areasToAdd ) do
    self:addArea( f )
  end

end

function DrawManager:getObjectsFromMap( map )
  local areas = map:getAreas()

  for _,aa in pairs( areas ) do
    local objects = aa:getObjects()

    for _,oo in pairs( objects ) do
      self:addObject( oo, oo:getLayer() )
    end

    for _,ss in pairs( aa:getSpawnPoints() ) do
      self:addSpawnPoint( ss, ss:getLayer() )
    end

    local nm = aa:getNavMesh()

    if ( nm ) then
      self:addNavMesh( nm )
    end
  end
end

function DrawManager:addNavMesh( navmeshToAdd )
  table.insert ( self.navmeshes, navmeshToAdd )
  self.navCount = #self.navmeshes
end

function DrawManager:enableVisibiltyTest( trueToEnable )
  if ( trueToEnable ) then
    self.drawLayerFunction = self.drawLayerNormal
  else
    self.drawLayerFunction = self.drawLayerFull
  end
end

function DrawManager:draw()

  if ( glob.devMode.lightsActive ) then
    --//TODO lights
  end

  for i = 1, #self.layers do

    if ( self.layers[i].visible ) then
      self:drawLayerFunction( self.layers[i] )
    end

  end

  for i = 1, self.spawnCount do
    self.spawns[i]:draw()
  end

  for i = 1, self.navCount do
    self.navmeshes[i]:draw()
  end

  love.graphics.setShader( )

end

function DrawManager:drawLayerFull( layerToDraw )

  for i = 1, #layerToDraw.objects do
    layerToDraw.objects[i]:draw()
  end

end

function DrawManager:drawLayerNormal( layerToDraw )

  for i = 1, #layerToDraw.objects do

    if ( self:isInsideScreen( layerToDraw.objects[i] ) ) then
      layerToDraw.objects[i]:draw()
    end

  end

end

function DrawManager:isInsideScreen( object )
  local camX, camY, camW, camH = self.camera:getVisibleArea(-300, -300, 400, 400) -- arbitrary values?
  local objX, objY, objW, objH = object:getBoundingBox():getBounds()

  --//TODO fix isInside when resolution is changed

  --if ( object:getInstanceName() == "onetree") then
  --  objX = objX * self.scaleX
  --  objY = objY * self.scaleY

    --print(objX .. " " .. objY .. " " .. objW .. " " .. objH)
  --end

  --print(camX .. " " .. camY .. " " .. camW .. " " .. camH)

  --//TODO how to do if object is bigger than screen?
  -- check rectangleOverlap and https://love2d.org/forums/viewtopic.php?f=4&t=9281&hilit=field+of+view&sid=c46504dd91ead64328d64fd0359c84e8

  -- if at least one of the rectangle bounds of the object
  -- is inside the screen, the object is visible
  return (
    isInside( objX, objY, {camX, camY, camW, camH} ) or
    isInside( objX + objW, objY, {camX, camY, camW, camH} ) or
    isInside( objX, objY + objH, {camX, camY, camW, camH} ) or
    isInside( objX + objW, objY + objH, {camX, camY, camW, camH} )
  )

end
