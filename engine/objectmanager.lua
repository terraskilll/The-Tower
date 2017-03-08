require("../engine/lclass")
require("../engine/io/io")
require("../engine.gameobject.simpleobject")
require("../engine.animation.animation")
require("../engine.animation.frame")

local basePath = love.filesystem.getSourceBaseDirectory() .. "/__data/"

local allObjects = {}

class "ObjectManager"

function ObjectManager:ObjectManager( thegame )
  self.game = thegame
end

function ObjectManager:save( objects )

  if ( objects ) then
    allObjects = objects
  end

  saveFile( "__objectlist", allObjects )
end

function ObjectManager:load()

  allObjects, err = loadFile( "__objectlist" )

  if ( allObjects == nil ) then
    allObjects = {}
  end

  return allObjects

end

function ObjectManager:loadObjectData( objectFileName )

  local objectData, err = loadFile( "__objects/" .. objectFileName )

  if ( objectData ) then

    return objectData

  else

    print("Load error for " .. objectFileName)

    return nil

  end

end

function ObjectManager:loadObject( objectName, instanceName, posx, posy )

  local objdata = self:loadObjectData( objectName )

  if ( objdata == nil ) then
    print( "Failed to load object data for name " .. objectName )
    return nil
  end

  local resname, restype, respath = self.game:getResourceManager():getResourceByName( objdata.resourcename )

  local sprite = self.game:getResourceManager():loadImage( respath )

  local quad = nil

  if ( objdata.quaddata ) then

    local qd = objdata.quaddata

    quad = love.graphics.newQuad( qd[1], qd[2], qd[3], qd[4], qd[5], qd[6] )

  else

    quad = nil

  end

  local object = SimpleObject( instanceName, posx, posy, sprite, quad, 1 )

  ------

  if ( objdata.bboxdata ) then

    local bb = objdata.bboxdata

    local boundingbox = BoundingBox( posx, posy, bb[3], bb[4], bb[5], bb[6], bb[7], bb[8] )

    object:setBoundingBox( boundingbox )

  end

  if ( objdata.navboxdata ) then

    local bb = objdata.navboxdata

    local navbox = NavBox( posx, posy, bb[3], bb[4], bb[5], bb[6], bb[7] )

    object:setNavBox( navbox )

  end

  if ( objdata.colldata ) then

    local collider = nil

    local cd = objdata.colldata

    if ( objdata.colltype == "box" ) then
      collider = BoxCollider( posx, posy, cd[3], cd[4], cd[5], cd[6], cd[7] )
    else
      collider = CircleCollider( posx, posy, cd[2], cd[8], cd[5], cd[6], cd[7] )
    end

    object:setCollider( collider )

  end

  --//TODO load animation

  return object
end
