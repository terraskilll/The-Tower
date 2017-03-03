--[[

--//TODO load in objectmanager ?

]]

require("../engine.lclass")
require("../engine.animation.frame")

class "Animation"

function Animation:Animation( animationName )
  self.name       = animationName or ""
  self.image      = nil
  self.frames     = {}
  self.frameCount = 0

  self.currentFrame       = nil
  self.currentFrameNumber = 1
  self.currentFrameTime   = 0
end

function Animation:setName( nameToSet )
  self.name = nameToSet
end

function Animation:getName()
  return self.name
end

function Animation:setImage( imageToSet, resourceNameToSet )
  self.image        = imageToSet
  self.resourcename = resourceNameToSet
end

function Animation:update( dt )

  self.currentFrameTime = self.currentFrameTime + dt

  if ( self.currentFrameTime >= self.currentFrame:getDuration() ) then
    self.currentFrameTime = 0

    self.currentFrameNumber = self.currentFrameNumber + 1

    if ( self.currentFrameNumber > self.frameCount ) then
      self.currentFrameNumber = 1
    end

    self.currentFrame = self.frames[self.currentFrameNumber]
  end

end

function Animation:draw( positionX, positionY )
  self.currentFrame:draw( self.image, positionX, positionY )
end

function Animation:start()
  self.currentFrameNumber = 1
  self.currentFrame = self.frames[self.currentFrameNumber]
end

function Animation:addFrame( frameToAdd )
  table.insert( self.frames, frameToAdd )
  self.frameCount = #self.frames
end

function Animation:removeFrame( frameindex )
  table.remove( self.frames, frameindex )
  self.frameCount = #self.frames
end

function Animation:createFrame( frameDuration, quadX, quadY, quadW, quadH, imageW, imageH, offX, offY )

  offX = offX or 0
  offY = offY or 0

  local quad = love.graphics.newQuad( quadX, quadY, quadW, quadH, imageW, imageH )

  local frame = Frame()

  frame:setQuad( quad )
  frame:setDuration( frameDuration )
  frame:setOffset( offX, offY )

  self:addFrame( frame )

end

function Animation:getFrame( index )

  if ( self.frames[index] ) then

    return self.frames[index]

  else

    return nil

  end

end

function Animation:getFrameCount()
  return self.frameCount
end

function Animation:saveToFile( filename )

  local frms = {}

  for i = 1, self.frameCount do
    table.insert( frms, self.frames[i]:getDatAsTable() )
  end

  local animData = {
    name = self.name,
    resourcename = self.resourcename,
    frames = frms
  }

  saveFile( "__animations/" .. filename, animData )
end

function Animation:loadFromFile( filename, resourcemanager )

  local animData, err = loadFile( "__animations/" .. filename )

  if ( err ) then
    print("Failed to load animation from file : " .. filename )
    return
  end

end
