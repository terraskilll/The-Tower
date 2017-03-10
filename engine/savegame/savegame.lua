require("..engine.lclass")
require("..engine.io.io")

class "SaveGame"

function SaveGame:SaveGame( savename )
  self.name = savename

  self.mapname   = nil
  self.areaname  = nil
  self.spawnname = nil

  self.items = {}
end

function SaveGame:getName()
  return self.name
end

function SaveGame:setMapName( mapNameToSet )
  self.mapname = mapNameToSet
end

function SaveGame:getMapName()
  return self.mapname
end

function SaveGame:setAreaName( areaNameToSet )
  self.areaname = areaNameToSet
end

function SaveGame:getAreaName()
  return self.areaname
end

function SaveGame:setSpawnName( spawnNameToSet )
  self.spawnname = spawnNameToSet
end

function SaveGame:getSpawnName()
  return self.spawnname
end

function SaveGame:addItem( itemname, ammount )
  table.insert( self.items, { name = itemname, ammount = ammount } )
end

function SaveGame:clearItems()
  self.items = {}
end

--------------------------------------------------------------------------------
function SaveGame:save()
  local data = {
    mapname   = self.mapname,
    areaname  = self.areaname,
    spawnname = self.spawnname,
    items     = self.items
  }

  saveFile( "__save/" .. self.name, data )
end

function SaveGame:load()
  local data = loadFile( "__save/" .. self.name )

  self.mapname   = data.mapname
  self.areaname  = data.areaname
  self.spawnname = data.spawnname

  self.items = data.items
end
