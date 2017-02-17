

require("../engine/lclass")
require("../engine/gameobject/gameobject")

local Vec = require("../engine/math/vector")

class "Light" ("GameObject") --//TODO make a simpleobject?

function Light:Light( lightName, positionX, positionY, lightRadius, colorR, colorG, colorB )
  self.name     = lightName or "__light__"
  self.position = Vec( positionX or 0, positionY or 0 )
  self.radius   = lightRadius or 10
  self.color    = { colorR or 255, colorG or 255, colorB or 255 }

  self.image = nil
end

function Light:setImage( newImage )
  self.image = newImage
end

function Light:update( dt )
  --TODO add flicker?
end

function Light:draw()

  if ( self.image ~= nil ) then
    love.graphics.draw(self.image, self.position.x, self.position.y, 0, 1, 1)
  end

end

function Light:apply( lightShader )
  lightShader:send( "uLightX", self.position.x )
  lightShader:send( "uLightY", self.position.y )
  lightShader:send( "uSize", self.radius )
end
