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

]]--

require("../engine/lclass")

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

function DrawManager:DrawManager(gameCamera)
  self.camera      = gameCamera

  self.objectCount = 0
  self.objects     = {} -- objects currently being managed

  self.floorCount  = 0
  self.floors      = {}
end

function DrawManager:clear()
  -- removes all objects in list
  --// TODO is this expensive?
  self.objects = {}
end

function DrawManager:update(dt)
  --//TODO sort less times
  table.sort(self.objects, sortByY)
end

function DrawManager:addObject(objectToAdd)
  table.insert(self.objects, objectToAdd)
  self.objectCount = #self.objects
end

function DrawManager:addFloorObject(objectToAdd)
  table.insert(self.floors, objectToAdd)
  self.floorCount = #self.floors
end

function DrawManager:addAllFloors(floorToAdd)
  for _,f in ipairs(floorToAdd) do
    self:addFloorObject(f)
  end
end

function DrawManager:sortObjects()

end

function DrawManager:draw()

  for i = 1, self.floorCount do

    --if (self:isInsideScreen(self.floors[i])) then
      self.floors[i]:draw()
    --end

  end

  for i = 1, self.objectCount do

    if (self:isInsideScreen(self.objects[i])) then
      self.objects[i]:draw()
    end

  end

end

function DrawManager:isInsideScreen(object)
  local camX, camY, camW, camH = self.camera:getVisibleArea(-300, -300, 400, 400) -- arbitrary values?
  local objX, objY, objW, objH = object:getBoundingBox():getBounds()

  --//TODO how to do if object is bigger than screen?

  -- if at least one of the rectangle bounds of the object
  -- is inside the screen, the object is visible
  return (
    isInside(objX, objY, {camX, camY, camW, camH}) or
    isInside(objX + objW, objY, {camX, camY, camW, camH}) or
    isInside(objX, objY + objH, {camX, camY, camW, camH}) or
    isInside(objX + objW, objY + objH, {camX, camY, camW, camH})
  )

end
