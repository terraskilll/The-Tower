-- based on http://nova-fusion.com/2011/04/19/cameras-in-love2d-part-1-the-basics/

require("..engine.lclass")

-- no rotation support for camera

class "Camera"

function Camera:Camera()
  self.positionX = 0
  self.positionY = 0
  self.scaleX    = 1
  self.scaleY    = 1

  self.target = nil
end

function Camera:update( dt )

  if ( self.target ) then

    local targetPosition = self.target:getPosition()
    local screenWidth, screenHeight = love.graphics.getDimensions()

    --//TODO store screen width, use multiplication
    self:setPosition( ( targetPosition.x ) - screenWidth / self.scaleX / 2, ( targetPosition.y ) - screenHeight / self.scaleY / 2 )

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
  self.scaleY  = self.scaleY * (changeScaleY or changeScaleX)
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

  --//TODO store screen dimensions
  local screenWidth, screenHeight = love.graphics.getDimensions()

  return
    ( self.positionX + startXOffset ),
    ( self.positionY + startYOffset ),
    ( screenWidth + endXOffset ),
    ( screenHeight + endYOffset)

    -- ( self.positionX + startXOffset * self.scaleX ),
    -- ( self.positionY + startYOffset * self.scaleY ),
    -- ( ( screenWidth + endXOffset ) / self.scaleX ),
    -- ( ( screenHeight + endYOffset) / self.scaleY )
end
