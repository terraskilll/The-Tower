-- http://blog.wolfire.com/2009/07/linear-algebra-for-game-developers-part-2/     helped

--//TODO  check later http://www.gamasutra.com/blogs/SundaramRamaswamy/20161117/285708/Efficient_Field_of_View_and_Line_of_Sight_for_strategy_games.php

require("../engine/lclass")

require("../engine/utl/funcs")

local Vec = require("../engine/math/vector")

local atan2fun = math.atan2
local degfun   = math.deg
local radfun   = math.rad
local sinfun   = math.sin
local cosfun   = math.cos

class "FieldOfView"

function FieldOfView:FieldOfView( positionX, positionY, viewAngle, viewDistance )
  self.position      = Vec( positionX, positionY )
  self.viewDirection = Vec( 1, 0 )
  self.angle         = viewAngle
  self.distance      = viewDistance

  self.tr = Vec( 0, 0 )
  self.tl = Vec( 0, 0)
end

function FieldOfView:changePosition( movementVector )
  self.position = self.position + movementVector
end

function FieldOfView:setPosition( newX, newY )
  self.position:set( newX, newY )
end


function FieldOfView:setAngle( newAngle )
  self.angle = newAngle
end

function FieldOfView:setViewDirection( directionVector )
  self.viewDirection = directionVector

  self.viewDirection:normalize()
end

function FieldOfView:check( targetPosition )
  -- checks if the target is in the field of view
end

function FieldOfView:update( dt )
  local r = radfun( self.angle ) / 2

  self.tl = rotateVec( self.viewDirection, -r ):normalize() * self.distance + self.position
  self.tr = rotateVec( self.viewDirection, r ):normalize() * self.distance + self.position

end

function FieldOfView:draw()
  love.graphics.line( self.position.x, self.position.y, self.tl.x, self.tl.y )
  love.graphics.line( self.position.x, self.position.y, self.tr.x, self.tr.y )

  --love.graphics.line( self.position.x, self.position.y, xk + self.position.x , yk + self.position.y )
end
