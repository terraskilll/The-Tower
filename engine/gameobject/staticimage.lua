-------------------------------------------------------------------------------
-- simple static image
-------------------------------------------------------------------------------
require("../engine/lclass")

require ("../engine/gameobject/gameobject")
require ("../engine/materials/normalmaterial")

class "StaticImage" ("GameObject")

function StaticImage:StaticImage()
  self.image = nil
  self.material = NormalMapMaterial()
end

function StaticImage:draw(light)
  light:apply(self.material:getShader())

  self.material:apply()

  love.graphics.setShader(self.material:getShader())
  love.graphics.draw(self.image, self.position.x, self.position.y)
  love.graphics.setShader()
end

function StaticImage:getKind()
  return "StaticImage"
end

function StaticImage:update(dt)

end

function StaticImage:setImage(newImage)
  self.image = newImage
  self.material:setTextureImage(newImage)
end

function StaticImage:setMaterial(newMaterial)
  self.material = newMaterial
end

function StaticImage:getMaterial()
  return self.material
end
