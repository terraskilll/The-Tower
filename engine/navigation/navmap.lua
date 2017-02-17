--[[

a navmap is a navigation map for a specific actor (player, enemy)

each cell is based on the navagent radius, so it defines if a actor can or
cannot pass through certain places (corridors, for example)

--//TODO test calculation efficiency

measuring time: https://love2d.org/wiki/love.timer.getTime

WISHLIST: use threads for parallel A star search

]]

require("../engine/lclass")

require("../engine/globalconf")

local Vec = require("../engine/math/vector")

local absfun = math.abs
local floorfun = math.floor
local ceilfun = math.ceil
local maxfun = math.max
local minfun = math.min

class "NavMap"

function NavMap:NavMap( mapOwner, agentRadius )
  self.owner  = mapOwner
  self.radius = agentRadius
  self.cells  = {}
  self.grid   = {}

  self.bounds = nil

  self.colCount = 0
  self.rowCount = 0
end

function NavMap:getRadius()
  return self.radius
end

function NavMap:addCell( ccol, crow, cx, cy, cw, ch )
  -- column, line, x, y, width, height, iswalkable, f, g, h
  table.insert( self.cells, { col = ccol, row = crow, x = cx, y = cy, w = cw, h = ch, walkable = true } )

end

function NavMap:generateFromNavMesh( navmesh, radius )
  self.grid = {}

  local obstacles = navmesh:getObstacles()
  self.bounds = navmesh:getBounds()

  local cols = ceilfun( ( self.bounds[3] - self.bounds[1]) / radius )
  local rows = ceilfun( ( self.bounds[4] - self.bounds[2]) / radius )

  for j = 1, rows do

    self.grid[j] = {}

    for i = 1, cols do

      self.grid[j][i] = 0

    end

  end

  --//TODO add obstacles, mark places as unwalkable
end

function NavMap:getAgentCurrentCell( agentX, agentY, agentRadius )
  --//TODO refactor

  local col = maxfun ( absfun( ceilfun( ( agentX - self.bounds[1] ) / agentRadius ) ), 1 )
  local row = maxfun ( absfun( ceilfun( ( agentY - self.bounds[2] ) / agentRadius ) ), 1 )

  return row, col
end

function NavMap:getGrid()
  return self.grid
end

function NavMap:getColAndRowCount()
  return self.colCount, self.rowCount
end

function NavMap:draw()

  --//TODO remove or comment

  for i = 1, #self.grid do
    for j = 1, #self.grid[i] do
      --[[
      love.graphics.rectangle("line",
          self.bounds[1] + ((i - 1) * self.radius),
          self.bounds[2] + ((j - 1) * self.radius),
          self.radius,
          self.radius)
          ]]
    end
  end

end
