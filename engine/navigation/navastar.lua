--[[

computes the path between points of a map

--//TODO make a thread?

]]

require("../engine/lclass")

require("../engine/globalconf")

local Vec = require("../engine/math/vector")

class "NavaStar"

function NavStar:NavStar()

end

-- try to get a path between 2 points on a navmesh
function NavStar:execute(navmesh, startPoint, endPoint)
  --//TODO
  local arrayPath = {}

  return false, arrayPath
end
