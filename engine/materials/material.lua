
Material = {}

function Material:new(o, newImageTexture)
  o = o or {
    imageTexture = newImageTexture
  }

  setmetatable(o, self)
  self.__index = self
  return o
end

function Material:setImageTexture(newImageTexture)
  self.imageTexture = newImageTexture
end