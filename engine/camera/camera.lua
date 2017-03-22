-- based on http://nova-fusion.com/2011/04/19/cameras-in-love2d-part-1-the-basics/

require("..engine.lclass")

-- no rotation support for camera

local floorfun = math.floor

local camSpeed = 6

class "Camera"

function Camera:Camera()
  self.positionX = 0
  self.positionY = 0
  self.scaleX    = 1
  self.scaleY    = 1

  self.screenw, self.screenh = love.graphics.getDimensions()

  self.target = nil
end

function Camera:update( dt )

  if ( self.target ) then

    local targetPosition = self.target:getPosition()
    local screenWidth, screenHeight = love.graphics.getDimensions()

    -- https://love2d.org/forums/viewtopic.php?f=4&t=2781&start=10
    local ptx = self.positionX - ( self.positionX - ( targetPosition.x - self.screenw * 0.5 ) ) * dt * camSpeed
    local pty = self.positionY - ( self.positionY - ( targetPosition.y - self.screenh * 0.5 ) ) * dt * camSpeed

    self:setPosition( ptx, pty )

  end

end

function Camera:drawPosition( x, y )
  love.graphics.print( "Camera: " .. self.positionX .. "|" .. self.positionY .. " ~ " .. self.scaleX .. "|" .. self.scaleY, x, y )
end

function Camera:setTarget( newTarget )

  if ( newTarget == nil ) then
    self.target = nil
    return
  end

  if ( not newTarget.getPosition ) then
    print("Target has no getPosition method")
    return
  end

  self.target = newTarget
end

function Camera:set()
  love.graphics.push()
  love.graphics.scale( 1.0 * self.scaleX, 1.0 * self.scaleY )
  love.graphics.translate( -self.positionX, - self.positionY )
end

function Camera:unset()
  love.graphics.pop()
end

function Camera:move( incX, incY )
  self.positionX = self.positionX + ( incX or 0 )
  self.positionY = self.positionY + ( incY or 0 )
end

function Camera:scale( changeScaleX, changeScaleY )
  changeScaleX = changeScaleX or 1

  self.scaleX  = self.scaleX * changeScaleX
  self.scaleY  = self.scaleY * ( changeScaleY or changeScaleX )

  self.screenw, self.screenh = love.graphics.getDimensions()
end

function Camera:setPosition( newX, newY )
  self.positionX = newX or self.positionX
  self.positionY = newY or self.positionY
end

function Camera:getPositionXY()
  return self.positionX, self.positionY
end

function Camera:setScale( newScaleX, newScaleY )
  if ( newScaleX < 0.1 ) then
    newScaleX = 0.1
  end

  if ( newScaleY < 0.1 ) then
    newScaleY = 0.1
  end

  self.scaleX = newScaleX or self.scaleX
  self.scaleY = newScaleY or self.scaleY

  self.screenw, self.screenh = love.graphics.getDimensions()
end

function Camera:getScale()
  return self.scaleX, self.scaleY
end

function Camera:mousePosition()
  return love.mouse.getX() * self.scaleX + self.positionX, love.mouse.getY() * self.scaleY + self.positionY
end

function Camera:getVisibleArea( startXOffset, startYOffset, endXOffset, endYOffset )
  startXOffset = startXOffset or 0
  startYOffset = startYOffset or 0
  endXOffset   = endXOffset or 0
  endYOffset   = endYOffset or 0

  return
    ( self.positionX + startXOffset ),
    ( self.positionY + startYOffset ),
    ( self.screenw + endXOffset ),
    ( self.screenh + endYOffset)
end
