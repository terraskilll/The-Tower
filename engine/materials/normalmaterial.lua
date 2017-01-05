require ("../engine/materials/material")
require ("../engine/light/light")

NormalMapMaterial = {}

function NormalMapMaterial:new(o)
  o = o or {
    ambientColor = {1, 1, 1},
    diffuseColor = {1, 1, 1},
    specularColor = {1, 1, 1},
    specularIntensity = 0,
    textureImage = newTextureImage,
    normalMapImage = newNormalMapImage,
    shader = love.graphics.newShader("shaders/normal.glsl")
  }

  setmetatable(o, self)
  self.__index = self

  return o
end

function NormalMapMaterial:configure(newAmbientColor, newDiffuseColor, newSpecularColor, newSpecularIntensity)
  self.ambientColor = newAmbientColor
  self.diffuseColor = newDiffuseColor
  self.specularColor = newSpecularColor
  self.specularIntensity = newSpecularIntensity
end

function NormalMapMaterial:setNormalMapImage(newNormalMapImage)
  self.normalMapImage = newNormalMapImage
end

function NormalMapMaterial:setTextureImage(newTextureImage)
  self.textureImage = newTextureImage
end

function NormalMapMaterial:apply()
  self.shader:send("uTexture", self.textureImage)

  if (self.normalMapImage) then
    self.shader:send("uNormalMap", self.normalMapImage)
  end

  self.shader:send("uAmbientMaterial", self.ambientColor)
  self.shader:send("uDiffuseMaterial", self.diffuseColor)
  self.shader:send("uSpecularMaterial", self.specularColor)
  self.shader:send("uSpecularIntensity", self.specularIntensity)
  self.shader:send("uInvertY", false)
  self.shader:send("uUseShadow", true)
  self.shader:send("uUseNormals", true)
  self.shader:send("uMapStrength", 1.0)
  self.shader:send("uAttenuation", {1.0, 1.0, 1.0})
end

function NormalMapMaterial:setTextureImage(newImage)
  self.textureImage = newImage
end

function NormalMapMaterial:setNormalMapImage(newImage)
  self.normalMapImage = newImage
end

function NormalMapMaterial:getShader()
    return self.shader
end

function NormalMapMaterial:setShader(newShader)
  if (newShader) then
    self.shader = newShader
  else
    print("Shader cannot be null")
  end
end