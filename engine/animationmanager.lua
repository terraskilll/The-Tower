--[[

a animation manager: loads, saves and retrieves

]]

require("..engine.lclass")
require("..engine.io.io")

local basePath = love.filesystem.getSourceBaseDirectory() .. "/__data/"

local allanimations = {}

class "AnimationManager"

function AnimationManager:AnimationManager( thegame )

  self.game = thegame

end

function AnimationManager:load()
  allanimations, err = loadFile("__animationlist")

  if ( allanimations == nil ) then
    allanimations = {}
  end

  return allanimations
end

function AnimationManager:save( animations )
  if ( animations ) then
    allanimations = animations
  end

  saveFile("__animationlist", allanimations)
end

function AnimationManager:getAnimationByIndex( animationindex )
  return allanimations[animationindex][1]
end

function AnimationManager:check( animationname )
  return self:getAnimationByName( animationname ) ~= nil
end

function AnimationManager:getAnimationByName( animationname )

  local animationCount = #allanimations

  for i = 1, animationCount do

    if ( allanimations[i][1] == animationname ) then
      return allanimations[i][1]
    end

  end

end

function AnimationManager:saveAnimation( animationFileName, animation )

  local framecount = animation:getFrameCount()

  local frms = {}

  for i = 1, framecount do
    table.insert( frms, animation:getFrame(i):getDataAsTable() )
  end

  local animData = {
    name = animation:getName(),
    resourcename = animation:getResourceName(),
    frames = frms
  }

  saveFile( "__animations/" .. animationFileName, animData )
end

function AnimationManager:loadAnimData( animationFilename )

  local animData, err = loadFile( "__animations/" .. animationFilename )

  if ( animData ) then

    return animData

  else

    print("Load error for " .. animationFilename)

    return nil

  end

end

function AnimationManager:loadAnimation( animationFilename )

  local animdata = self:loadAnimData( animationFilename )

  if ( animdata == nil ) then
    print( "Failed to load animation data for name " .. animationFilename )
    return nil
  end

  local animation = Animation( animdata.name )

  local resname, restype, respath = self.game:getResourceManager():getResourceByName( animdata.resourcename )

  local image = self.game:getResourceManager():loadImage( respath )

  animation:setImage( image, resname )

  for i=1, #animdata.frames do
    animation:createFrame(
      animdata.frames[i].duration,
      animdata.frames[i].quadx,
      animdata.frames[i].quady,
      animdata.frames[i].quadw,
      animdata.frames[i].quadh,
      animdata.frames[i].imgw,
      animdata.frames[i].imgh,
      animdata.frames[i].offx,
      animdata.frames[i].offy
    )

  end

  return animation, image

end
