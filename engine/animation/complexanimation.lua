require("../engine/lclass")

class "ComplexAnimation"

function ComplexAnimation:ComplexAnimation()
  self.currentAnimation = nil
  self.animations       = {}
end

function ComplexAnimation:update( dt )
  self.currentAnimation:update( dt )
end

function ComplexAnimation:draw( positionX, positionY )
  self.currentAnimation:draw( positionX, positionY )
end

function ComplexAnimation:addAnimation( newAnimation )
  table.insert( self.animations, newAnimation )
end

function ComplexAnimation:start()
  self.currentAnimation:start()
end

function ComplexAnimation:setCurrentAnimation( index, start )
  start = start or false

  self.currentAnimation = self.animations[index]

  if (start) then
    self.currentAnimation:start()
  end
end

function ComplexAnimation:setImage( newImage )

  for _,v in ipairs( self.animations ) do
    v:setImage( newImage )
  end

end
