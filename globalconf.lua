
glob = {
  defaultFontSize = 12,
  defaultColor    = {255,255,255,255},

  devMode = {
    active = false,
    drawColliders = true,
    disableDamage = false,
    disableNormalMap = false
  }
}

function activateDevMode()
  if ( glob.devMode.active ) then
    glob.devMode.active = false
  else
    glob.devMode.active = true
  end
end

function devModeCheck( key )
  if ( key == "f12" ) then
    activateDevMode()
  end

  if ( glob.devMode.active ) then
    devModeCheckKey( key )
  end
end

function devModeCheckKey( key )
  if ( key == "kp1" ) then
    glob.devMode.drawColliders = not glob.devMode.drawColliders
  end
end