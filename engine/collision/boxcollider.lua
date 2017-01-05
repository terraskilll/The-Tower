--https://love2d.org/wiki/PointWithinShape

require("lclass")
require("../globalconf")

class "BoxCollider"

function BoxCollider:BoxCollider(x, y, w, h, offX, offY)
  self.positionX = x
  self.positionY = y
  self.width     = w
  self.height    = h
  self.offsetX   = offX
  self.offsetY   = offY
  self.kind      = "box"

  --self.notifyList= {}
end

function BoxCollider:update(dt, ownerX, ownerY)
  self.positionX = ownerX
  self.positionY = ownerY
end

function BoxCollider:draw()
  if ( glob.devMode.drawColliders ) then
    love.graphics.setColor(0, 255, 0) 
    
    love.graphics.rectangle("line", 
      self.positionX + self.offsetX, 
      self.positionY + self.offsetY,
      self.width,
      self.height)
    
    love.graphics.setColor(glob.defaultColor)
  end
end

function BoxCollider:getKind()
  
end

function BoxCollider:getBounds()
  return self.positionX, self.positionY, self.width, self.height
end

function BoxCollider:addTrigger(newTrigger)
  table.insert(self.notifyList, newTrigger)
end

function BoxCollider:notifyAll()
  --for _,v in ipairs(self.notifyList) do
    --v:notify()
  --end
end