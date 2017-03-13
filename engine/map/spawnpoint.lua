
--[[

a spawn point in a map->area->floor that can be  refered by name

]]

require("..engine.lclass")

local Vec = require("..engine.math.vector")

class "SpawnPoint" ("GameObject")

function SpawnPoint:SpawnPoint( spawnPointName , positionX, positionY )
  self.instancename = spawnPointName
  self.name         = "SpawnPoint"
  self.position     = Vec( positionX, positionY )

  self.layer  = 1

  self.width  = 20
  self.height = 20
end

function SpawnPoint:getKind()
  return "SpawnPoint"
end

function SpawnPoint:setPosition( newX, newY )
  self.position:set( newX, newY )
end

function SpawnPoint:changePosition( movementVector )
  self.position = self.position + movementVector
end

function SpawnPoint:draw()
  if ( glob.devMode.drawNavMesh ) then
    love.graphics.setColor(255, 0, 255)

    love.graphics.line( self.position.x - 10, self.position.y, self.position.x + 10, self.position.y)
    love.graphics.line( self.position.x - 10, self.position.y, self.position.x, self.position.y - 10)
    love.graphics.line( self.position.x + 10, self.position.y, self.position.x, self.position.y - 10)

    love.graphics.setColor(glob.defaultColor)
  end
end
