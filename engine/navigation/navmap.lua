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

class "NavMap"

function NavMap:NavMap(mapOwner, agentRadius)
  self.owner  = mapOwner
  self.radius = agentRadius
  self.cells  = {}

  self.positionx = 0
  self.positiony = 0
end

function NavMap:clear()
  self.cells = {}
end

function NavMap:addCell(ccol, crow, cx, cy, cw, ch)
  table.insert( self.cells, { ccol, crow, cx, cy, cw, ch, true } )
end

function NavMap:generateFromNavMesh(navmesh, radius)
  self:clear()

  local obstacles = navmesh:getObstacles()
  local bounds = navmesh:getBounds()

  self.positionx = bounds[1] - radius
  self.positiony = bounds[2] - radius

  for i = self.positionx, bounds[3], radius do

    for j = self.positiony, bounds[4], radius do

      table.insert( self.cells, {i, j, i + radius, j + radius} )

    end

  end

  --//TODO add obstacles

end

function NavMap:getAgentCurrentCell(agentPosition, agentRadius)
  print(self.positionx)
  print(self.positiony)
  print(agentPosition.x)
  print(agentPosition.y)
  print(agentRadius)
  local xp = (agentPosition.x - self.positionx) / agentRadius
  local yp = (agentPosition.y - self.positiony) / agentRadius

  return xp, yp
end

function NavMap:getPathTo(fromX, fromY, toX, toY)

end

function NavMap:draw()

  --//TODO remove or comment
  --[[
    for i = 1, #self.cells do
    love.graphics.rectangle("line",
        self.cells[i][1],
        self.cells[i][2],
        self.cells[i][3] - self.cells[i][1] ,
        self.cells[i][4] - self.cells[i][2])
  end
  ]]--

end
