--[[

a in-game and editor resource manager

]]

require("..engine.lclass")
require("..engine.io.io")

local basePath = love.filesystem.getSourceBaseDirectory() .. "/__data/"

local allResources = {}

class "ResourceManager"

function ResourceManager:ResourceManager( thegame )
  self.game = thegame

  self:load()
end

function ResourceManager:load()
  allResources, err = loadFile("__resourcelist")

  if (allResources == nil) then
    allResources = {}
  end

  return allResources
end

function ResourceManager:save( resources )
  if ( resources ) then
    allResources = resources
  end

  saveFile("__resourcelist", allResources)
end

function ResourceManager:getResourceByIndex( resourceIndex )
  return allResources[resourceIndex][1], allResources[resourceIndex][2], allResources[resourceIndex][3]
end

function ResourceManager:getResourceByName( wantedResourceName )

  local resourceCount = #allResources

  for i = 1, resourceCount do

    if ( allResources[i][1] == wantedResourceName ) then
      return allResources[i][1], allResources[i][2], allResources[i][3]
    end

  end

end

function ResourceManager:loadImage( filePath )
  return love.graphics.newImage( filePath )
end

function ResourceManager:loadSound( filepath )

end
