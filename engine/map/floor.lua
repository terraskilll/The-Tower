--[[

a floor is a part of an map, divided in areas

]]

require("../engine/lclass")

require("../engine/input")

class "Floor"

function Floor:Floor( floorName )

  self.name          = floorName
  self.areas         = {}
  self.areaCount     = 0
  self.movingObjects = {}

end

function Floor:getName()
  return self.name
end

function Floor:draw()

  for _,fl in pairs( self.areas ) do
    fl:draw()
  end

end

function Floor:update( dt )

  for _,mo in pairs( self.movingObjects ) do
    mo:update( dt )
  end

end

function Floor:addArea( area )
  self.areas[area:getName()] = area
  self.areaCount = self.areaCount + 1
end

function Floor:getAreas()
  return self.areas
end

function Floor:getAreaCount()
  return self.areaCount
end

function Floor:getAreaByName ( areaName )
  return self.areas[areaName]
end

function Floor:addMovingObject( objectToAdd )
  self.movingObjects[objectToAdd:getName()] = objectToAdd
end

function Floor:getMovingObjects()
  return self.movingObjects
end

function Floor:getMovingObjectByName( objectName )
  return self.movingObjects[objectName]
end

function Floor:checkChangedNavMesh( objectPosition, objectMovement )
  local pos = objectPosition + objectMovement

  local nav = nil

  local isIn = false

  for i, fl in pairs( self.areas ) do

    isIn = fl:getNavMesh():isInside( pos.x, pos.y )

    if (isIn) then
      nav = fl:getNavMesh()
    end

  end

  for _,mo in pairs( self.movingObjects ) do
    if ( mo:isWalkable() ) then

      isIn = mo:getNavMesh():isInside( pos.x, pos.y )

      if (isIn) then
        nav = mo:getNavMesh()
      end

    end
  end

  return nav
end
