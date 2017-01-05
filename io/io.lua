
function saveFile(filePath, fileData)
  local fullPath = love.filesystem.getSourceBaseDirectory() .. filePath
	
  err = table.save(fileData, fullPath)
	
  if err then
		print(fullPath .. " :: " .. err)
	end

end

function loadFile(filePath)
  local fullPath = love.filesystem.getSourceBaseDirectory() .. filePath

	data, err = table.load(fullPath)
  
	if err then
		print(fullPath .. " :: " .. err)
    return nil
	end

  return data
end