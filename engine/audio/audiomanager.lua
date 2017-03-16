--[[

an audio manager class

]]

require("..engine.lclass")

class "AudioManager"

function AudioManager:AudioManager( thegame )
  self.game = thegame

  self.volume    = 1
  self.sfxVolume = 1
  self.musics    = {}
  self.sounds    = {}
end

---- MUSIC ---------------------------------------------------------------------

function AudioManager:addMusic( musicName, audioToAdd, volume )
  volume = volume or self.volume

  if ( volume > 1 ) then
    volume = 1
  end

  self.musics[musicName] = { audio = audioToAdd, volume = volume }
end

function AudioManager:changeMusicVolume( musicName, newVolume )
  newVolume = newVolume or self.volume

  if ( newVolume > 1 ) then
    newVolume = 1
  end

  self.musics[musicName].volume = newVolume
end

function AudioManager:playMusic( musicName )
  self.musics[musicName].audio:setVolume( self.musics[musicName].volume )
  love.audio.play( self.musics[musicName].audio )
end

function AudioManager:stopMusic( musicName )
  if ( musicName ) then
    love.audio.stop( musicName )
  else
    love.audio.stop()
  end
end

---- AUDIO SFX -----------------------------------------------------------------

function AudioManager:addSound( soundName, audioToAdd, volume )
  volume = volume or self.sfxVolume

  if ( volume > 1 ) then
    volume = 1
  end

  self.sounds[soundName] = { audio = audioToAdd, volume = volume }
end

function AudioManager:changeMusicVolume( soundName, newVolume )
  newVolume = newVolume or self.sfxVolume

  if ( newVolume > 1 ) then
    newVolume = 1
  end

  self.sounds[soundName].volume = newVolume
end

function AudioManager:playSound( soundName, volume )
  self.sounds[soundName].audio:setVolume( self.sounds[soundName].volume )
  love.audio.play( self.sounds[soundName].audio )
end
