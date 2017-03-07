
--[[

a spawn point in a map->area->floor that can be  refered by name

]]

require("../engine/lclass")

local Vec = require("../engine.math.vector")

class "SpawnPoint" ("GameObject")

function SpawnPoint:SpawnPoint( spawnPointName , positionX, positionY )
  self.name     = spawnPointName
  self.position = Vec( positionX, positionY )

  self.width  = 10
  self.height = 10
end

function SpawnPoint:setPosition(newX, newY)
  self.position:set(newX, newY)
end

function SpawnPoint:changePosition( movementVector )
  self.position = self.position + movementVector
end

function SpawnPoint:draw()
  if ( glob.devMode.drawNavMesh ) then
    love.graphics.setColor(255, 0, 255)

    love.graphics.line( self.position.x - 8, self.position.y, self.position.x + 8, self.position.y)
    love.graphics.line( self.position.x - 8, self.position.y, self.position.x, self.position.y - 8)
    love.graphics.line( self.position.x + 8, self.position.y, self.position.x, self.position.y - 8)

    love.graphics.setColor(glob.defaultColor)
  end
end
