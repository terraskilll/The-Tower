require("..engine.lclass")

require("..engine.io.io")

class "SaveManager"

function SaveManager:SaveManager( thegame )
  self.game = thegame

  self.saves = {}

  self:load()
end

function SaveManager:addSave( saveName, saveToAdd )
  table.insert( self.saves, { name = saveName, save = saveToAdd } )
end

function SaveManager:getSaves()
  return self.saves
end

function SaveManager:getSave( saveName )
  for i = 1, #self.saves do
    if ( savename == self.saves[i].name ) then
      return self.saves[i].saves
    end
  end

  return nil
end

function SaveManager:getSaveCount()
  return #self.saves
end

function SaveManager:load()
  self.saves = loadFile( "__saves" )

  if ( self.saves == nil ) then
    self.saves = {}

    self:save()
  end

end

function SaveManager:save()
  saveFile( "__saves", self.saves )
end
