require("..engine.lclass")

require("..engine.input")
require("..engine.utl.funcs")
require("..engine.screen.screen")

local floorfun = math.floor

class "SplashScreen" ("Screen")

function SplashScreen:SplashScreen( theGame )
  self.screenmusicname = "mainmenumusic"

  self.game = theGame
end

function SplashScreen:onEnter()
  self.image = love.graphics.newImage( "res/terrabits.png" )

  self.ww = self.image:getWidth()
  self.hh = self.image:getHeight()

  self.sw, self.sh = love.graphics.getDimensions()

  self.cx = self.sw / self.ww
  self.cy = self.sh / self.hh

  self.timer = 0.5 --//TODO change to 6

  self.alphain  = 0
  self.alphaout = 255

  local resname, restype, respath = self.game:getResourceManager():getResourceByName( self.screenmusicname )

  if ( respath ) then
    local music = self.game:getResourceManager():loadAudio( respath )

    self.game:getAudioManager():addMusic( resname, music, tonumber( 0.3 ) )
    self.game:getAudioManager():playMusic( resname )

    self.music = music
  end
end

function SplashScreen:onExit()
  self.image = nil
end

function SplashScreen:update( dt )
  self.timer = self.timer - dt

  if ( self.timer <= 0 ) then
    self:openMenuScreen()
  end

  self.alphain   = 255 - floorfun ( ( self.timer - 5 ) * 255 )
  self.alphaout  = 255 - floorfun ( ( 1 - self.timer ) * 255 )
end

function SplashScreen:draw()
  if ( self.timer > 5 ) then
    love.graphics.setColor( 255, 255, 255, self.alphain )
  elseif ( self.timer < 1 ) then
    love.graphics.setColor( 255, 255, 255, self.alphaout )
  else
    love.graphics.setColor( 255, 255, 255, 255 )
  end

  love.graphics.draw( self.image, 0, 0, 0, self.cx, self.cy )
end

function SplashScreen:onKeyPress( key, scancode, isrepeat )

end

function SplashScreen:onKeyRelease( key, scancode, isrepeat )

end

function SplashScreen:openMenuScreen()
  self.game:setCurrentScreen( "MenuScreen" )
end
