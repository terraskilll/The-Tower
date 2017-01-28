--[[

an area is a isolated part of a map (a room, for example)

only one area is rendered at a time, instead of the whole map

]]

require("../engine/lclass")

require("../engine/input")

class "Area"

function Area:Area( areaName )
  self.name          = areaName
  self.floors        = {}
  self.movingObjects = {}
end

function Area:getName()
  return self.name
end

function Area:update(dt)

  for _,mo in pairs(self.movingObjects) do
    mo:update(dt)
  end

end

function Area:draw()

  for i, fl in pairs(self.floors) do
    fl:draw()
  end

end

function Area:addFloor( floorName, floor )
  self.floors[floorName] = floor
end

function Area:getFloors()
  return self.floors
end

function Area:getFloorByName ( floorName )
  return self.floors[floorName]
end

function Area:addMovingObject( objectName, objectToAdd )
  self.movingObjects[objectName] = objectToAdd
end

function Area:getMovingObjects()
  return self.movingObjects
end

function Area:getMovingObjectByName( objectName )
  return self.movingObjects[objectName]
end

function Area:checkChangedNavMesh( objectPosition, objectMovement )
  local pos = objectPosition + objectMovement

  local nav = nil

  local isIn = false

  for i, fl in pairs(self.floors) do
    isIn = fl:getNavMesh():isInside( pos.x, pos.y )

    if (isIn) then
      nav = fl:getNavMesh()
    end
  end

  for _,mo in pairs(self.movingObjects) do
    if ( mo:isWalkable() ) then

      isIn = mo:getNavMesh():isInside( pos.x, pos.y )

      if (isIn) then
        nav = mo:getNavMesh()
      end

    end
  end

  return nav
end
