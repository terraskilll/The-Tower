--[[

this class manages all maps of the game, checking for load, transition,
creation, etc

]]

require ("../engine/lclass")
require("../engine/map/map")

class "MapManager"

function MapManager:MapManager()
  self.maps = {}
end

function MapManager:addMap(mapName, mapFile)
  self.maps[mapName] = {
    file   = mapFile,
    loaded = false,
    mapData = nil
  }
end

function MapManager:loadMap( mapName )
  local map = Map()
  local loadOk = map:loadFromFile( self.maps[mapName].file )

  if ( loadOk ) then
    self.maps[mapName].loaded = true
    self.map[mapName].mapData = map
  end

  return map
end

function MapManager:getMap( mapName )
  if ( not self.maps[mapName].loaded ) then
    self:loadMap(mapName)
  end

  return self.maps[mapName].mapData
end
