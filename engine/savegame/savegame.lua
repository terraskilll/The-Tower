require("..engine.lclass")
require("..engine.io.io")

class "SaveGame"

function SaveGame:SaveGame( savename )
  self.name = savename

  self.mapname     = nil
  self.areaname    = nil
  self.spawnname   = nil
  self.description = nil
  self.used        = false

  self.items = {}
end

function SaveGame:getName()
  return self.name
end

function SaveGame:setName( nameToSet )
  self.name = nameToSet
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

function SaveGame:setDescription( descriptionToSet )
  self.description = descriptionToSet
end

function SaveGame:getDescription()
  return self.description
end

function SaveGame:setUsed( trueToUse )
  self.used = trueToUse
end

function SaveGame:isUsed()
  return self.used
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
    mapname     = self.mapname,
    areaname    = self.areaname,
    spawnname   = self.spawnname,
    description = self.description,
    items       = self.items
  }

  if ( self.used ) then
    data.used = 1
  else
    data.used = 0
  end

  saveFile( "__save/" .. self.name, data )
end

function SaveGame:load()
  local data = loadFile( "__save/" .. self.name )

  if ( data ) then
    self.mapname     = data.mapname
    self.areaname    = data.areaname
    self.spawnname   = data.spawnname
    self.description = data.description
    self.used        = data.used == 1
    self.items       = data.items

    return true
  else
    self.mapname     = nil
    self.areaname    = nil
    self.spawnname   = nil
    self.description = nil
    self.used        = false

    return false
  end

end
