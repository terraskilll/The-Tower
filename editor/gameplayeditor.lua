

require("..engine.lclass")
require("..engine.io.io")

require("..editor.textinput")

local options = {
  "F1 - Set Start Map",
  "F9 - Save",
  "F11 - Back"
}

class "GamePlayEditor"

function GamePlayEditor:GamePlayEditor( ownerEditor, thegame )
  self.game   = thegame
  self.owner  = ownerEditor

  self.gamedata = {}

  self.mode = 0

  self.textInput = nil

  self.updatefunction = self.updategeneral
  self.keypressfunction = self.keypressgeneral
end

function GamePlayEditor:load()
  self.gamedata = loadFile( "__gameplay" )

  if ( self.gamedata == nil ) then

    self.gamedata = {
      startmap   = "",
      startarea  = "",
      startspawn = ""
    }

  end
end

function GamePlayEditor:save()
  saveFile( "__gameplay", self.gamedata )
end

function GamePlayEditor:onEnter()
  print("Entered GamePlayEditor")

  self:load()
end

function GamePlayEditor:onExit()

end

function GamePlayEditor:update( dt )
  self:updatefunction( dt )
end

function GamePlayEditor:draw()

  if ( self.textInput ) then
    self.textInput:draw()
    return
  end

  for i = 1, #options do
    love.graphics.print(options[i], 16, (i * 16) + 40)
  end

  love.graphics.setColor( 0, 255, 100, 255 )
  love.graphics.print( "First Map : ", 200, 50 )
  love.graphics.print( "First Area : ", 200, 70 )
  love.graphics.print( "First Spawn Point :", 200, 90 )
  love.graphics.setColor( glob.defaultColor )

  love.graphics.print( self.gamedata.startmap, 350, 50 )
  love.graphics.print( self.gamedata.startarea, 350, 70 )
  love.graphics.print( self.gamedata.startspawn, 350, 90 )

end

function GamePlayEditor:onKeyPress( key, scancode, isrepeat )
  --//TODO

  if ( self.textInput ) then
    self.textInput:keypressed( key )
    return
  end

  self:keypressfunction( key )

end

function GamePlayEditor:onKeyRelease( key, scancode, isrepeat )

end

function GamePlayEditor:doTextInput( t )

  if ( self.textInput ) then
    self.textInput:input( t )
    return
  end

end

function GamePlayEditor:updategeneral( dt )

end

function GamePlayEditor:keypressgeneral( key )
  if ( key == "f1" ) then
    self.mode = 1

    self.textInput = TextInput( "Map Name: " )

    self.updatefunction = self.updatestartchange
    self.keypressfunction = self.keypressstartchange
  end

  if ( key == "f9" ) then
    self:save()

    return
  end

  if ( key == "f11") then

    self:onExit()
    self.owner:backFromEdit()
    return

  end
end

function GamePlayEditor:updatestartchange( dt )

  if ( self.textInput:isFinished() ) then

    if ( self.mode == 3 ) then
      self.gamedata.startspawn = self.textInput:getText()
      self.mode      = 0
      self.textInput = nil

      self.updatefunction = self.updategeneral
      self.keypressfunction = self.keypressgeneral
    end

    if ( self.mode == 2 ) then
      self.gamedata.startarea = self.textInput:getText()
      self.textInput = TextInput( "Spawn Point Name:" )
      self.mode = 3
    end

    if ( self.mode == 1 ) then
      self.gamedata.startmap = self.textInput:getText()
      self.textInput = TextInput( "Area Name:" )
      self.mode = 2
    end

  end

end

function GamePlayEditor:keypressstartchange( key )

end
