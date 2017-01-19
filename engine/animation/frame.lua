require("../engine/lclass")

class "Frame"

function Frame:Frame()
  self.duration = 1
  self.offsetX = 0
  self.offsetY = 0
  self.framequad = nil
end

function Frame:setQuad(newQuad)
  self.framequad = newQuad
end

function Frame:getQuad()
  return self.framequad
end

function Frame:setDuration(newDuration)
  self.duration = newDuration
end

function Frame:setOffset(newOffSetX, newOffSetY)
  self.offsetX = newOffSetX or 0
  self.offsetY = newOffSetY or 0
end

function Frame:getDuration()
  return self.duration
end

function Frame:draw(image, positionX, positionY)
  love.graphics.draw(image, self.framequad, positionX + self.offsetX, positionY + self.offsetY)
end