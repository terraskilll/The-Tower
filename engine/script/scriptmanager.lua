--[[

a script manager

]]

require("..engine.lclass")
require("..engine.io.io")

local basePath = love.filesystem.getSourceBaseDirectory() .. "/__data/"

local allscripts = {}

class "ScriptManager"

function ScriptManager:ScriptManager( thegame )

  self.game = thegame

end

function ScriptManager:load()
  allscripts, err = loadFile("__scriptlist")

  if ( allscripts == nil ) then
    allscripts = {}
  end

  return allscripts
end

function ScriptManager:save( scripts )
  if ( scripts ) then
    allscripts = scripts
  end

  saveFile( "__scriptlist", allscripts )
end

function ScriptManager:getScriptByIndex( scriptindex )
  return scriptindex[animationindex][1]
end

function ScriptManager:check( animationname )
  return self:getScriptByName( animationname ) ~= nil
end

function ScriptManager:loadScript( scriptname )
  --local scname, scpath = self:getScriptByName( scriptname )

  --local load = require()
end

function ScriptManager:getScriptByName( scriptname, fullpath )

  local scriptCount = #allscripts

  for i = 1, scriptCount do

    if ( allscripts[i][1] == scriptname ) then
      if ( fullpath ) then
        return allscripts[i][1], "..game.scripts." .. allscripts[i][2]
      else
        return allscripts[i][1], allscripts[i][2]
      end
    end

  end

end
