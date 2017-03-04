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

--//TODO method to remove spawn points, lights and moving objects

--//TODO use skiplist

]]--

require("../engine/lclass")

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

  self.scaleX = 1
  self.scaleY = 1

  self.lightCount  = 0
  self.lights      = {} -- lights in map

  self.objectCount = 0
  self.objects     = {} -- objects currently being managed

  self.movingCount   = 0
  self.movingObjects = {} -- moving objects

  self.areaCount  = 0
  self.areas      = {} -- areas

  self.groundCount  = 0
  self.grounds      = {} -- grounds

  self.spawnCount  = 0
  self.spawns      = {} -- spawn points

  self.navCount   = 0
  self.navmeshes  = {}

  self.groundVisible  = true
  self.objectsVisible = true
end

function DrawManager:setScale( newScaleX, newScaleY )
  self.scaleX = newScaleX or 1
  self.scaleY = newScaleY or 1
end

function DrawManager:clear()
  -- removes all objects in lists
  --// TODO check if this is expensive

  self.lightCount  = 0
  self.objectCount = 0
  self.movingCount = 0
  self.areaCount   = 0
  self.groundCount = 0
  self.spawnCount  = 0
  self.navCount    = 0

  self.objects       = {}
  self.lights        = {}
  self.movingObjects = {}
  self.areas         = {}
  self.grounds       = {}
  self.spawnPoints   = {}
  self.navmeshes     = {}
end

function DrawManager:update( dt )
  --//TODO sort less times, use skiplist
  table.sort( self.objects, sortByY )
end

function DrawManager:forceUpdate()
  table.sort( self.objects, sortByY )
  table.sort( self.grounds, sortByY )
end

function DrawManager:toogleGroundVisible( )
  self.groundVisible = not self.groundVisible

  print( "Ground visibility changed to " .. tostring( self.groundVisible ) )
end

function DrawManager:toogleObjectsVisible( )
  self.objectsVisible = not self.objectsVisible

  print( "Objects visibility changed to " .. tostring( self.objectsVisible ) )
end

function DrawManager:addObject( objectToAdd )
  table.insert( self.objects, objectToAdd )
  self.objectCount = #self.objects
end

function DrawManager:removeObject( objectName )
  local index = 0

  for i = 1, #self.objects do

    if ( self.objects[i]:getName() == objectName ) then
      index = i
    end

  end

  if ( index > 0 ) then
    table.remove( self.objects, index )
  end

  self.objectCount = #self.objects

end

function DrawManager:addLight( lightToAdd )
  table.insert ( self.lights, lightToAdd )
  self.lightCount = #self.lights
end

function DrawManager:addMovingObject ( objectToAdd )
  table.insert( self.movingObjects, objectToAdd )
  self.movingCount = #self.movingObjects
end

function DrawManager:addAllMovingObjects( objectsToAdd )

  for _,o in pairs( objectsToAdd ) do
    self:addMovingObject( o )
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

function DrawManager:addGround( groundToAdd )
  table.insert( self.grounds, groundToAdd )

  self.groundCount = #self.grounds

  table.sort( self.grounds, sortByY )
end

function DrawManager:addAllGrounds( groundsToAdd )

  for _,g in pairs( groundsToAdd ) do
    self:addGround( g )
  end

end

function DrawManager:removeGround( groundName )
  local index = 0

  for i = 1, #self.grounds do

    if ( self.grounds[i]:getName() == groundName ) then
      index = i
    end

  end

  if ( index > 0 ) then
    table.remove(self.grounds, index)
  end

  self.groundCount = #self.grounds
end

function DrawManager:addArea( areaToAdd )
  table.insert( self.areas, areaToAdd )
  self.areaCount = #self.areas

  self:addAllGrounds( areaToAdd:getGrounds() )
  self:addAllSpawns( areaToAdd:getSpawnPoints() )
end

function DrawManager:addAllAreas( areasToAdd )

  for _,f in pairs( areasToAdd ) do
    self:addArea( f )
  end

end

function DrawManager:addNavMesh( navmeshToAdd )
  table.insert ( self.navmeshes, navmeshToAdd )
  self.navCount = #self.navmeshes
end

function DrawManager:sortObjects()

end

function DrawManager:draw()

  if ( glob.devMode.lightsActive ) then

    for i = 1, self.lightCount do

      self.lights[i]:apply( lightShader )

    end

    if ( self.lightCount > 0 ) then
      love.graphics.setShader( lightShader )
    end

  end

  if ( self.groundVisible ) then
    for i = 1, self.groundCount do
      self.grounds[i]:draw() -- todo chek if it is inside screen
    end
  end

  if ( self.objectsVisible ) then

    for i = 1, self.movingCount do
      self.movingObjects[i]:draw()
    end

    for i = 1, self.objectCount do
      if ( self:isInsideScreen( self.objects[i] ) ) then
        self.objects[i]:draw()
      end
    end

  end

  for i = 1, self.lightCount do

    --if (self:isInsideScreen(self.areas[i])) then
      self.lights[i]:draw()
    --end

  end

  for i = 1, self.spawnCount do

    self.spawns[i]:draw()

  end

  for i = 1, self.navCount do

    self.navmeshes[i]:draw()

  end

  love.graphics.setShader( )

end

function DrawManager:isInsideScreen( object )
  local camX, camY, camW, camH = self.camera:getVisibleArea(-300, -300, 400, 400) -- arbitrary values?
  local objX, objY, objW, objH = object:getBoundingBox():getBounds()

  --//TODO fix isInside when changed resolution

  if ( object:getName() == "onetree") then
    objX = objX * self.scaleX
    objY = objY * self.scaleY

    --print(objX .. " " .. objY .. " " .. objW .. " " .. objH)
  end

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
