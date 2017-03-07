
glob = {
  engineVersion   = 120, --//TODO note: change this at each commit
  defaultFontSize = 12,
  defaultColor    = {255,255,255,255},

  --//TODO revisit default configurations
  devMode = {
    active           = false,
    showFPS          = false,
    drawColliders    = true,
    drawNavMesh      = false,
    drawNavMap       = false,
    drawBoundingBox  = true,
    drawFov          = false,
    lightsActive     = false,
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
      if ( key == "kp0" ) then
        glob.devMode.showFPS = not glob.devMode.showFPS
        print(" DEV:: Show FPS = " .. tostring(glob.devMode.showFPS))
      end

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

      if ( key == "kp4" ) then
        glob.devMode.lightsActive = not glob.devMode.lightsActive
        print(" DEV:: Lights are active = " .. tostring(glob.devMode.lightsActive))
      end

      if ( key == "kp5" ) then
        glob.devMode.drawNavMap = not glob.devMode.drawNavMap
        print(" DEV:: Draw NavMap = " .. tostring(glob.devMode.drawNavMap))
      end

      if ( key == "kp6" ) then
        glob.devMode.drawFov = not glob.devMode.drawFov
        print(" DEV:: Draw FOV = " .. tostring(glob.devMode.drawFov))
      end

    end

  }
}
