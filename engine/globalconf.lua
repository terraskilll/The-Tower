
glob = {
  defaultFontSize = 12,
  defaultColor    = {255,255,255,255},

  --//TODO revisit default configurations
  devMode = {
    active           = false,
    showFPS          = true,
    drawColliders    = true,
    drawNavMesh      = true,
    drawBoundingBox  = true,
    disableDamage    = false,
    disableNormalMap = false,
    editorEnabled    = true,

    check = function ( key )
      if ( key == "f12" ) then
        glob.devMode.active = not glob.devMode.active
        print(" DEV:: Dev Mode active = " .. tostring(glob.devMode.active))
      end

      if ( glob.devMode.active ) then
        glob.devMode.keypress( key )
      end
    end,

    keypress = function ( key )
      if ( key == "kp1" ) then
        glob.devMode.drawColliders = not glob.devMode.drawColliders
        print(" DEV:: Draw Colliders = " .. tostring(glob.devMode.drawColliders))
      end

      if ( key == "kp2" ) then
        glob.devMode.drawNavMesh = not glob.devMode.drawNavMesh
        print(" DEV:: Draw NavMesh = " .. tostring(glob.devMode.drawNavMesh))
      end

      if ( key == "kp3" ) then
        glob.devMode.drawBoundingBox = not glob.devMode.drawBoundingBox
        print(" DEV:: Draw BoundingBox = " .. tostring(glob.devMode.drawBoundingBox))
      end
    end

  }
}
