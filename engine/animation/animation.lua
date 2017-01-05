require ("lclass")

require("../resources")
require("../engine/animation/frame")

class "Animation"

function Animation:Animation()
  self.image = nil
  self.frames = {}
  self.frameCount = 0
  self.currentFrame = nil
  self.currentFrameNumber = 1
  self.currentFrameTime = 0
end

function Animation:setImage(newImage)
  self.image = newImage
end

function Animation:addFrame(frameDuration, quadX, quadY, quadW, quadH, imageW, imageH, offX, offY)
  offX = offX or 0
  offY = offY or 0

  local quad = love.graphics.newQuad(quadX, quadY, quadW, quadH, imageW, imageH)

  local frame = Frame()

  frame:setQuad(quad)
  frame:setDuration(frameDuration)
  frame:setOffset(offX, offY)

  table.insert(self.frames, frame)
  self.frameCount = #self.frames
end

function Animation:update(dt)
  self.currentFrameTime = self.currentFrameTime + dt

  if (self.currentFrameTime >= self.currentFrame:getDuration()) then
    self.currentFrameTime = 0

    self.currentFrameNumber = self.currentFrameNumber + 1

    if (self.currentFrameNumber > self.frameCount) then
        self.currentFrameNumber = 1
    end

    self.currentFrame = self.frames[self.currentFrameNumber]
  end
end

function Animation:draw(positionX, positionY)
  self.currentFrame:draw(self.image, positionX, positionY)
end

function Animation:start()
  self.currentFrameNumber = 1
  self.currentFrame = self.frames[self.currentFrameNumber]
end