--[[

manages the savegames: load and save files

--//TODO add integrity check / anticheat ( hash field )
--//TODO simplify slot selection / use array/table

]]

require("..engine.lclass")
require("..engine.io.io")

class "SaveManager"

function SaveManager:SaveManager( thegame )
  self.game = thegame

  self.slot1 = nil
  self.slot2 = nil
  self.slot3 = nil
end

function SaveManager:createEmptySave()
  local gamedata = loadFile( "__gameplay" )

  local savegame = SaveGame( "SLOT 0" )

  savegame:setMapName( gamedata.startmap )
  savegame:setAreaName( gamedata.startarea )
  savegame:setSpawnName( gamedata.startspawn )
  savegame:setDescription( "Game Started" )

  return savegame
end

function SaveManager:load()
  local save1 = SaveGame( "SLOT 1" )
  local save2 = SaveGame( "SLOT 2" )
  local save3 = SaveGame( "SLOT 3" )

  if ( save1:load() ) then
    self.slot1 = save1
  else
    self.slot1 = self:createEmptySave()
    self.slot1:setName("SLOT 1")
    self.slot1:save()
  end

  if ( save2:load() ) then
    self.slot2 = save2
  else
    self.slot2 = self:createEmptySave()
    self.slot2:setName("SLOT 2")
    self.slot2:save()
  end

  if ( save3:load() ) then
    self.slot3 = save3
  else
    self.slot3 = self:createEmptySave()
    self.slot3:setName("SLOT 3")
    self.slot3:save()
  end

end

function SaveManager:setSaveToSlot( savegame, slotNumber )

  savegame:setUsed( true )

  savegame:setName( "SLOT " .. slotNumber )

  if ( slotNumber == 1 ) then
    self.slot1 = savegame
  elseif ( slotNumber == 2 ) then
    self.slot2 = savegame
  elseif ( slotNumber == 3 ) then
    self.slot3 = savegame
  end

end

function SaveManager:getSaveSlot( slotNumber )

  if ( slotNumber == 1 ) then
    return self.slot1
  elseif ( slotNumber == 2 ) then
    return self.slot2
  elseif ( slotNumber == 3 ) then
    return self.slot3
  end

  return nil
end

function SaveManager:usedSlots()
  local c = 0

  if ( self.slot1:isUsed() ) then
    c = c + 1
  end

  if ( self.slot2:isUsed() ) then
    c = c + 1
  end

  if ( self.slot3:isUsed() ) then
    c = c + 1
  end

  return c
end

function SaveManager:saveGame( slotNumber )
  if ( slotNumber == 1 ) then
    self.slot1:save()
  elseif ( slotNumber == 2 ) then
    self.slot2:save()
  elseif ( slotNumber == 3 ) then
    self.slot3:save()
  end
end
