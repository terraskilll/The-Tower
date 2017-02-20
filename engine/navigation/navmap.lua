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
local ceilfun = math.ceil
local maxfun = math.max

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

function NavMap:generateFromNavMesh( navmesh, radius )
  self.grid = {}

  local obsColliders = navmesh:getObstacleColliders()
  self.bounds = navmesh:getBounds()

  local cols = ceilfun( ( self.bounds[3] - self.bounds[1]) / radius )
  local rows = ceilfun( ( self.bounds[4] - self.bounds[2]) / radius )

  for j = 1, rows do

    self.grid[j] = {}

    for i = 1, cols do

      self.grid[j][i] = 0

    end

  end

  --//TODO remove
  self.grid[7][5] = 1
  self.grid[7][6] = 1
  self.grid[7][7] = 1
  self.grid[7][8] = 1
  self.grid[7][9] = 1
  self.grid[7][10] = 1

  self.grid[8][5] = 1
  self.grid[8][6] = 1
  self.grid[8][7] = 1
  self.grid[8][8] = 1
  self.grid[8][9] = 1
  self.grid[8][10] = 1

  self.grid[9][5] = 1
  self.grid[9][6] = 1
  self.grid[9][7] = 1
  self.grid[10][5] = 1
  self.grid[10][6] = 1
  self.grid[10][7] = 1

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

  if ( not glob.devMode.drawNavMap ) then
    return
  end

  --//TODO remove or comment

  for i = 1, #self.grid do

    for j = 1, #self.grid[i] do

      love.graphics.rectangle("line",
          self.bounds[1] + ((j - 1) * self.radius),
          self.bounds[2] + ((i - 1) * self.radius),
          self.radius,
          self.radius)

      if ( self.grid[i][j] == 1 ) then
        love.graphics.line(
          self.bounds[1] + ((j - 1) * self.radius),
          self.bounds[2] + ((i - 1) * self.radius),
          self.bounds[1] + ((j - 1) * self.radius) + self.radius,
          self.bounds[2] + ((i - 1) * self.radius) + self.radius
        )
      end

    end

  end

end
