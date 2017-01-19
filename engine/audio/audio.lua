--[[

an audio manager class

]]

require("../engine/lclass")

class "Audio"

function Audio:Audio()
  self.volume = 50
  self.sfxVolume = 50
  self.musics = {}
  self.sounds = {}
end

function Audio:addMusic(musicName, newMusic)
  self.musics[musicName] = newMusic
end

function Audio:addSound(soundName, newSound)
  self.sounds[soundName] = newSound
end

function Audio:playMusic(musicName)
  love.audio.play(self.musics[musicName])
end
