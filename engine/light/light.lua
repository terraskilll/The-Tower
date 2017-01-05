
Light = {}

function Light:new(o)
  o = o or {
    direction = {},
    position = {},
    ambient = {1, 1, 1},
    diffuse = {},
    specular = {}
  }

  setmetatable(o, self)
  self.__index = self
  return o
end

function Light:setPosition(newPosition)
  self.position = newPosition
end

function Light:setDirection(newDirection)
  self.direction = newDirection
end

function Light:configure(ambientValues, diffuseValues, specularValues)
  self.ambient = ambientValues
  self.diffuse = diffuseValues
  self.specular = specularValues
end

function Light:apply(shader)
  shader:send("uLightPosition", self.position)
  --shader:send("uLightDirection", self.direction)
  shader:send("uAmbientLight", self.ambient)
  shader:send("uDiffuseLight", self.diffuse)
  shader:send("uSpecularLight", self.specular)
end