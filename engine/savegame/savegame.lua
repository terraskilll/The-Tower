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

  self.items     = {}
  self.eventkeys = {}
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

----- ITEM STORAGING -----

function SaveGame:addItem( itemname, ammount )
  table.insert( self.items, { name = itemname, ammount = ammount } )
end

function SaveGame:getItem( itemname )
  local index = 0

  for i = 1, #self.items do
    if ( self.items[i].name == itemname ) then
      index = i
    end
  end

  if ( index > 0 ) then
    return index, self.items[index].name, self.items[index].ammount
  else
    return 0, nil, nil
  end
end

function SaveGame:removeItem( itemname )
  local index = self:getItem( itemname )

  if ( index > 0 ) then
    table.remove( self.items, index )
  end
end

function SaveGame:clearItems()
  self.items = {}
end

----- EVENT KEYS FOR MAPS AND SO ON -----

function SaveGame:addEventKey( eventname, keyvalue )
  table.insert( self.eventkeys, { eventname = eventname, keyvalue = keyvalue } )
end

function SaveGame:getEventKey( eventname )
  local index = 0

  for i = 1, #self.eventkeys do
    if ( self.eventkeys[i].eventname == eventname ) then
      index = i
    end
  end

  if ( index > 0 ) then
    return index, self.eventkeys[index].eventname, self.eventkeys[index].keyvalue
  else
    return 0, nil, nil
  end
end

function SaveGame:removeEventKey( eventname )
  local index = self:getEventKey( eventname )

  if ( index > 0 ) then
    table.remove( self.eventkeys, index )
  end
end

function SaveGame:clearEventKeys()
  self.eventkeys = {}
end

--------------------------------------------------------------------------------
function SaveGame:save()
  local data = {
    mapname     = self.mapname,
    areaname    = self.areaname,
    spawnname   = self.spawnname,
    description = self.description,
    items       = self.items,
    eventkeys   = self.eventkeys
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
    self.eventkeys   = data.eventkeys

    return true
  else
    self.mapname     = nil
    self.areaname    = nil
    self.spawnname   = nil
    self.description = nil
    self.used        = false
    self.items       = {}
    self.eventkeys   = {}

    return false
  end

end
