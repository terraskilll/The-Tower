--[[

io table operations simplified.

this is used to load and save resources names and paths, maps, static objects, etc

]]
require("../engine/io/savetable")

local basePath = love.filesystem.getSourceBaseDirectory() .. "/__data/"

function saveFile(filePath, fileData)
  local fullPath = basePath .. filePath

  print(fullPath)

  err = table.save(fileData, fullPath)

  if err then
		print(fullPath .. " :: " .. err)
	end

end

function loadFile(filePath)
  local fullPath = basePath .. filePath

	data, err = table.load(fullPath)

	if err then
		print(fullPath .. " :: " .. err)
    return nil
	end

  return data
end
