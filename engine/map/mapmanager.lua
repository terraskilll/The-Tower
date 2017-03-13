--[[

this class manages all maps of the game, checking for load, transition,
creation, etc

]]

require("..engine.lclass")
require("..engine.map.map")

local Vec = require("..engine.math.vector")

class "MapManager"

function MapManager:MapManager( thegame )
  self.game = thegame

  self.maplist = {}

  self.maps = {}
end

function MapManager:saveList( list )
  if ( list ) then
    self.maplist = list
  end

  saveFile( "__maplist", self.maplist )
end

function MapManager:loadList()
  self.maplist, err = loadFile( "__maplist" )

  if ( not self.maplist ) then
    self.maplist = {}
  end

  return self.maplist
end

function MapManager:loadMap( mapName, mapFileName )
  --//TODO fill CollisionManager

  if ( mapName == nil ) then

    for i = 1, #self.maplist do
      if ( self.maplist[i][2] == mapFileName ) then
        mapName = self.maplist[i][1]
      end
    end

  end

  local mapdata = loadFile( "__maps/" .. mapFileName, mapdata )

  if ( not mapdata ) then
    print( "Error loading map data for map " .. mapName )
    return nil
  end

  local map = Map( mapName, mapFileName )

  map:setNameIndex( mapdata.nameindex )

  local layers  = mapdata.layers
  local library = mapdata.library
  local areas   = mapdata.areas

  --- LAYERS ---
  for i = 1, #layers do
    map:addLayer( layers[i].name, layers[i].index )

    map:enableCollisionForLayer( layers[i].index, layers[i].collision == 1 )
  end

  --- LIBRARY ---
  for i = 1, #library do
    local object = self.game:getObjectManager():loadObject( library[i].name, library[i].instname, 0, 0 )

    object:setLayer( 1 )

    map:addToLibrary( library[i].name, object )
  end

  --- AREAS ---
  for i = 1, #areas do
    local area = Area( areas[i].name )

    --- OBJECTS ---
    local objects = areas[i].objects

    for i = 1, #objects  do
      local object = map:getObjectFromLibrary( objects[i].name ):clone( objects[i].name, objects[i].instname )

      if ( object ) then
        object:setPosition( Vec( objects[i].posx, objects[i].posy ) )
        object:setLayer( objects[i].layer )

        local colld = object:getCollider()

        if ( colld ) then
          object:getCollider():setSolid( objects[i].solidcollider == 1 )
        end

        if ( ( objects[i].script ~= nil ) and ( objects[i].script ~= "" ) ) then
          local scname, scpath = self.game:getScriptManager():getScriptByName( objects[i].script, true )
          object:setScript( scname, scpath )
          object:loadScript()
        end

        area:addObject( object )
      end
    end

    --- SPAWN POINTS ---
    local spawns = areas[i].spawns

    for i = 1, #spawns  do
      local spawn = SpawnPoint( spawns[i].instname, spawns[i].posx, spawns[i].posy )

      spawn:setLayer( spawns[i].layer )

      area:addSpawnPoint( spawn )
    end

    --- NAVMESH ---
    local navmeshdata = areas[i].navmeshdata

    if ( navmeshdata ) then
      local navmesh = NavMesh()
      navmesh:addAllPoints( areas[i].navmeshdata.points )
      navmesh:setMobile( areas[i].mobile == 1 )

      area:setNavMesh( navmesh )
    end

    --- FINALLY ---
    map:addArea( area )
  end

  return map
end

function MapManager:saveMap( mapName, mapFileName, map )
  local maplayers  = map:getLayers()
  local maplibrary = map:getLibrary()
  local mapareas   = map:getAreas()

  local layers   = {}
  local library  = {}
  local areas    = {}

  --- LAYERS ---
  for _,ll in pairs( maplayers ) do
    local cll = 1

    if ( ll.collision == false ) then
      cll = 0
    end

    table.insert( layers, { name = ll.name, index = ll.index, collision = cll } )
  end

  --- LIBRARY ---
  for _,oo in pairs( maplibrary ) do
    table.insert( library, { name = oo:getName(), instname = oo:getInstanceName() } )
  end

  --- AREAS ---
  for _,aa in pairs( mapareas ) do

    --- OBJECTS ---
    local areaobjects = {}
    local aaobjects   = aa:getObjects()

    for _,oo in pairs( aaobjects ) do
      local px, py = oo:getPositionXY()

      local objdata = {
          name     = oo:getName(),
          instname = oo:getInstanceName(),
          posx     = px,
          posy     = py,
          layer    = oo:getLayer(),
          script   = oo:getScript()
      }

      local colld = oo:getCollider()

      if ( colld ) then
        if ( colld:isSolid() ) then
          objdata.solidcollider = 1
        else
          objdata.solidcollider = 0
        end
      end

      table.insert( areaobjects, objdata )
    end

    --- SPAWN POINTS ---
    local areaspawns = {}
    local aaspawns   = aa:getSpawnPoints()

    for _,ss in pairs( aaspawns ) do
      local px, py = ss:getPositionXY()

      table.insert( areaspawns, {
          name     = ss:getName(),
          instname = ss:getInstanceName(),
          posx     = px,
          posy     = py,
          layer    = ss:getLayer()
      })
    end

    --- NAVMESH ---
    local navmeshdata = nil

    local nm = aa:getNavMesh()

    if ( nm ) then
      navmeshdata = {
        points = nm:getPoints()
      }

      if ( nm:isMobile() == true ) then -- savetable does not support boolean :(
        navmeshdata.mobile = 1
      else
        navmeshdata.mobile = 0
      end

    end

    --- HERE WE GO ---
    table.insert( areas, { name = aa:getName(), objects = areaobjects, spawns = areaspawns, navmeshdata = navmeshdata } )
  end

  local mapdata = {
    nameindex = map:getNameIndex(),
    layers    = layers,
    library   = library,
    areas     = areas
  }

  table.insert( mapdata, libr )

  saveFile( "__maps/" .. mapFileName, mapdata )

end
